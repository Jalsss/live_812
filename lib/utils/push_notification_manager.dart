import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/model/user/user_info.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:provider/provider.dart';

enum PushAction {
  MESSAGE,
  RESUME,
}

class PushNotificationHandler {
  final void Function(PushAction, dynamic) onReceive;

  const PushNotificationHandler({this.onReceive});
}

class PushNotificationManager {
  static PushNotificationManager _instance;
  static PushNotificationManager instance() {
    if (_instance == null)
      _instance = PushNotificationManager._internal();
    return _instance;
  }

  // 外部からインスタンスが作られないようにする
  factory PushNotificationManager() => instance();

  // 内部から呼び出してインスタンスを作る為のコンストラクタ
  PushNotificationManager._internal();

  final _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;
  final _handlers = List<PushNotificationHandler>();
  dynamic _launchMessage;

  // ローカル通知用
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  NotificationDetails platformChannelSpecifics;

  var _fcmTokenUploading = false;  // FCMトークンアップロード中
  String _fcmTokenUploadReserved;  // アップロード中にリフレッシュされたらためておく

  String _firebaseToken;  // 端末のFCMトークン

  dynamic get launchMessage => _launchMessage;

  void clearLaunchMessage() {
    _launchMessage = null;
  }

  Future<void> setUp(BuildContext context) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel?.token == null) {
      // ログイン前には処理しない
      return;
    }

    // シミュレータはFirebaseMessagingを受け取れないので、初期化しない。
    if (Platform.isIOS) {
      final info = await DeviceInfoPlugin().iosInfo;
      if (!info.isPhysicalDevice)
        return;
    } else if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (!info.isPhysicalDevice)
        return;
    }

    if (_initialized) {
      // ログアウトして別アカウントでログインした場合の対策
      _uploadFcmToken(context, _firebaseToken);
      return;
    }
    _initialized = true;

    if (Platform.isAndroid) {
      // ローカル通知を使うのはAndroidだけ。
      await _initLocalNotification();
    }

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        final data = Platform.isAndroid ? message['data'] : message;
        if (Platform.isAndroid) {
          // Androidの場合、アプリがフォアグラウンド時にプッシュ通知を受け取ると
          // システムトレイ＆ポップアップでの通知が自動的には行われない。
          // なのでローカル通知で表示してやる。
          final payload = data;
          showLocalNotification(
              0, message['notification']['title'], message['notification']['body'], payload);
        } else {
          _onReceive(PushAction.MESSAGE, data);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        final data = Platform.isAndroid ? message['data'] : message;
        _launchMessage = data;
      },
      onResume: (Map<String, dynamic> message) async {
        final data = Platform.isAndroid ? message['data'] : message;
        _onReceive(PushAction.RESUME, data);
      },
    );

    Stream<String> fcmStream = _firebaseMessaging.onTokenRefresh;
    fcmStream.listen((firebaseToken) {
      _firebaseToken = firebaseToken;
      _uploadFcmToken(context, firebaseToken);
    });

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print('Settings registered: $settings');
    });

    _firebaseToken = await _firebaseMessaging.getToken();
    if (userModel.registrationId != _firebaseToken) {
      _uploadFcmToken(context, _firebaseToken);
    }
  }

  Future<void> _uploadFcmToken(BuildContext context, String firebaseToken) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel.registrationId == firebaseToken || _fcmTokenUploadReserved == firebaseToken)
      return;
    if (_fcmTokenUploading) {
      _fcmTokenUploadReserved = firebaseToken;
      return;
    }
    _fcmTokenUploading = true;

    final service = BackendService(context);
    final response = await service.putUser(
        UserInfoModel(registrationId: firebaseToken),
        ignoreServerError: true);
    print('register firebaseToken: result=$response, firebaseToken=$firebaseToken');
    if (response?.result == true) {
      userModel.setRegistrationId(firebaseToken);
      userModel.saveToStorage();
    }
    if (_fcmTokenUploadReserved != null) {
      firebaseToken = _fcmTokenUploadReserved;
      _fcmTokenUploadReserved = null;
      _uploadFcmToken(context, firebaseToken);
      return;
    }
    _fcmTokenUploading = false;
  }

  void pushHandler(PushNotificationHandler callback) {
    _handlers.add(callback);
  }

  void popHandler() {
    _handlers.removeLast();
  }

  void _onReceive(PushAction action, /*Map<String, dynamic>*/ dynamic map) {
    if (_handlers.isNotEmpty) {
      _handlers.last.onReceive(action, map);
    } else {
      debugPrint('No push notification handler');
    }
  }

  Future<void> _initLocalNotification() async {
    if (flutterLocalNotificationsPlugin == null) {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
      var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/launcher_icon');
      var initializationSettingsIOS = IOSInitializationSettings(
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification);
      var initializationSettings = InitializationSettings(
          initializationSettingsAndroid, initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: _onSelectNotification);
    }
    if (platformChannelSpecifics == null) {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'works.live812.app.channel', 'LIVE812 channel', 'This is a channel for LIVE812',
          importance: Importance.Max, priority: Priority.High /*, ticker: 'ticker'*/);
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    }
  }

  void showLocalNotification(int id, String title, String body, dynamic payload) async {
    await _initLocalNotification();

    final encodedPayload = jsonEncode(payload);

    await flutterLocalNotificationsPlugin.show(
        id, title, body, platformChannelSpecifics,
        payload: encodedPayload);
  }

  Future _onSelectNotification(String encodedPayload) async {
    dynamic payload;
    if (encodedPayload != null) {
      try {
        payload = jsonDecode(encodedPayload);
      } catch (e) {
        debugPrint('jsonDecode failed: ${e?.toString()}');
      }
    }
    if (_handlers.isNotEmpty) {
      // Resumeとして扱う
      _onReceive(PushAction.RESUME, payload);
    } else {
      // Launchとして扱う
      _launchMessage = payload;
    }
  }
  Future _onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    print('onDidReceiveLocalNotification: id=$id, title=$title, body=$body, payload=$payload');
  }
}
