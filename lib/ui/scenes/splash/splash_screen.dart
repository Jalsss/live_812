import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/repository/event_logger_repository.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/user_info_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/maintenance/maintenance_page.dart';
import 'package:live812/ui/scenes/register/missing_symbol_page.dart';
import 'package:live812/ui/scenes/user/purchase_chat_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/deep_link_handler.dart';
import 'package:live812/utils/push_notification_manager.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _assetName = 'assets/svg/logo.svg';

  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1400));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut);

    _animation.addListener(() => this.setState(() {}));
    _animationController.forward();

    _startTime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    KeyboardUtil.close(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorLive.background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: SvgPicture.asset(
              _assetName,
              semanticsLabel: 'Live 812 Logo',
            ),
          ),
        ],
      ),
    );
  }

  void _startTime() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    await userModel.loadFromStorage();
    BackendService.setApiToken(userModel.token);

    await PushNotificationManager.instance().setUp(context);

    // Attach a listener to the stream
    getUriLinksStream().listen((Uri uri) {
      _handleDeepLink(context, uri);
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      print('getUriLinksStream: err=$err');
    });

    final initialUri = await initUniUri();
    if (initialUri != null) {
      if (await _handleDeepLink(context, initialUri, initial: true)) {
        return;
      }
    }

    bool wait = true;
    if (PushNotificationManager.instance().launchMessage != null) {
      wait = false;
    }

    if (wait) {
      await Future.delayed(Duration(milliseconds: 1400));
    }

    // イベントロガーを起動させるために呼び出す。
    Injector.getInjector().get<EventLoggerRepository>();

    if (await MaintenancePage.checkMaintenanceMode(context)) {
      // メンテナンスページへの遷移は行われているので、ここでは単に抜けるだけ
      return;
    }

    if (userModel != null && userModel.token != null && userModel.id != null) {
      if (await _updateMyInfoUntilSuccess()) {
        if (userModel.symbol == null || userModel.symbol == '') {
          Navigator.of(context).pushReplacement(
              FadeRoute(builder: (context) => MissingSymbolPage()));
          return;
        }

        Navigator.of(context).pushReplacementNamed("/bottom_nav");
      }
    } else {
      Navigator.of(context).pushReplacementNamed("/walk_through");
    }
  }

  Future<Uri> initUniUri() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialUri = await getInitialUri();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      return initialUri;
    } on PlatformException catch (e) {
      // Handle exception by warning the user their action did not succeed
      // return?
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> _updateMyInfoUntilSuccess() async {
    for (;;) {
      final result = await UserInfoUsecase.updateMyInfo(context);
      switch (result.item1) {
        case UpdateMyInfoResult.SUCCESS:
          return true;
        case UpdateMyInfoResult.NETWORK_ERROR:
          await showNetworkErrorDialog(context, msg: result.item2?.getByKey('msg'));
          break;
        case UpdateMyInfoResult.UNAUTHENTICATED:
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
          return false;
      }
    }
  }

  static Future<bool> _handleDeepLink(BuildContext context, Uri uri, {bool initial = false}) async {
    // 起動時、UserModelの生成がまだ完了してないことがあるので、ループさせる。
    if (uri.host == 'share.live812.works') {
      final m = RegExp(r'^/user/([\w\-_]+)$').firstMatch(uri.path);
      if (m != null) {
        final targetUserId = m.group(1);
        // User詳細画面に遷移
        if (initial) {
          UserModel userModel;
          for (int i = 0; i < 10; ++i) {
            userModel = Provider.of<UserModel>(context, listen: false);
            if (userModel != null)
              break;
            await Future.delayed(Duration(milliseconds: 100));
          }
          // ユーザがログインしてなかったらページ遷移させられない
          if (userModel == null || userModel.token == null || userModel.id == null)
            return false;

          Navigator.of(context).pushReplacementNamed("/bottom_nav");
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProfileViewPage(userId: targetUserId)));
          return true;
        } else {
          DeepLinkHandlerStack.instance().showLiverProfile(targetUserId);
        }
      }
      final m2 = RegExp(r'^/item_chat/([\w\-_]+)$').firstMatch(uri.path);
      if (m2 != null) {
        final targetOrderId = m2.group(1);
        // チャット画面に遷移
        if (initial) {
          UserModel userModel;
          for (int i = 0; i < 10; ++i) {
            userModel = Provider.of<UserModel>(context, listen: false);
            if (userModel != null)
              break;
            await Future.delayed(Duration(milliseconds: 100));
          }
          // ユーザがログインしてなかったらページ遷移させられない
          if (userModel == null || userModel.token == null || userModel.id == null)
            return false;

          Navigator.of(context).pushReplacementNamed("/bottom_nav");
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PurchaseChatPage(orderId: targetOrderId)));
          return true;
        } else {
          DeepLinkHandlerStack.instance().showChat(targetOrderId);
        }
      }
    }
    return false;
  }
}
