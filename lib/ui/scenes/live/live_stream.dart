import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart' as Agora;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:darq/darq.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_indicator/home_indicator.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/ec/store_profile.dart';
import 'package:live812/domain/model/live/broadcast_info.dart';
import 'package:live812/domain/model/live/gift_info.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/beautification_usecase.dart';
import 'package:live812/ui/dialog/disconnect_dialog.dart';
import 'package:live812/ui/dialog/gift_ranking_dialog.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_audience.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_chat_input.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_gift.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_product.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_product_add_edit.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_sound_effect.dart';
import 'package:live812/ui/scenes/live/apply_jasrac.dart';
import 'package:live812/ui/scenes/live/live_message.dart';
import 'package:live812/ui/scenes/live/widget/like_particles.dart';
import 'package:live812/ui/scenes/live/widget/live_close_button.dart';
import 'package:live812/ui/scenes/live/widget/live_gift_point_view.dart';
import 'package:live812/ui/scenes/live/widget/live_mute_mic_mark.dart';
import 'package:live812/ui/scenes/live/widget/live_next_liver_board.dart';
import 'package:live812/ui/scenes/live/widget/live_relay_timer_widget.dart';
import 'package:live812/ui/scenes/live/widget/live_start_countdown_widget.dart';
import 'package:live812/ui/scenes/live/widget/live_timer_widget.dart';
import 'package:live812/ui/scenes/live/widget/liver_profile_background.dart';
import 'package:live812/ui/scenes/live/widget/show_beauty_bottom_sheet.dart';
import 'package:live812/utils/agora_rtc_faceunity.dart';
import 'package:live812/utils/agora_rtc_helper.dart';
import 'package:live812/utils/anim/gift_animation_widget.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/deep_link_handler.dart';
import 'package:live812/utils/image_util.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/ng_filter.dart';
import 'package:live812/utils/push_notification_manager.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/route/transparent_bottom_sheet_route.dart';
import 'package:live812/utils/se_player.dart';
import 'package:provider/provider.dart';
import 'package:screen/screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tuple/tuple.dart';

enum CameraType {
  InCamera,
  OutCamera,
  MicOnly,
}

class LiveStreamPage extends StatefulWidget {
  LiveStreamPage({
    this.broadcastInfo,
    this.liveId,
    this.cameraType,
    this.isPortrait,
    this.enableBeautification,
  });

  final BroadcastInfo broadcastInfo;
  final String liveId;
  final CameraType cameraType;
  final bool isPortrait;
  final bool enableBeautification;

  @override
  _LiveStreamPageState createState() => _LiveStreamPageState(cameraType);
}

class _LiveStreamPageState extends State<LiveStreamPage>
    with WidgetsBindingObserver {
  TextEditingController _chatTextController = TextEditingController();

  String _token;
  String _userId;
  CameraType _cameraType;
  DateTime _startTime = DateTime.now();

  bool _isChat = true;
  bool _isChatBottomSheet = false;
  bool _checkStart = false;
  IO.Socket _socket;
  SePlayer _sePlayer;
  bool _cameraOff = false;
  bool _micOn = true;

  /// 離席状況.
  bool _isLeave = false;
  int _giftPoint = 0;
  void Function() _spawnLikeParticle;

  List<GiftInfoModel> _giftInfoList;
  final List<int> _giftAnimationQueue = [];

  int _audienceCount = 0;
  bool _quitting = false;
  bool _isAppBackground = false;
  bool _isBeautifyEffect = false;
  bool _initializedBeautification = false;

  // Agora
  Agora.RtcEngine _engine;
  final _users = <int>[];
  int _myId;

  /// イベント用.
  /// イベントID.
  String _eventId = '';

  /// リレーイベント時の自身の配信開始時間.
  DateTime _relayStartDate;

  /// リレーイベント時の自身の配信終了時間.
  DateTime _relayEndDate;

  /// 次の配信者のID.
  String _relayNextLiverId = '';

  /// 次の配信者の名前.
  String _relayNextLiverName = '';

  /// 次の配信者の配信開始時間.
  DateTime _relayNextStartDate;

  // コンストラクタ
  _LiveStreamPageState(this._cameraType);

  @override
  void dispose() {
    //念のためdisposeでも切断処理をする
    _stopLive();

    //ステータスバー表示
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    //ホームインジケーター表示
    HomeIndicator.show();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _chatTextController.dispose();

    Screen.keepOn(false);

    DeepLinkHandlerStack.instance().pop();
    PushNotificationManager.instance().popHandler();

    WidgetsBinding.instance.removeObserver(this);
    _engine?.leaveChannel();
    _engine?.destroy();
    super.dispose();
  }

  Future<void> _disconnect() async {
    setState(() {
      _cameraOff = true;
      _micOn = false;
      _startTime = null;
    });
    if (_socket != null) {
      _socket.clearListeners();
      _socket.close();
      setState(() => _socket = null);
    }

    _sePlayer.dispose();
    // destroy sdk
    if (_enableBeautification()) {
      await AgoraRtcFaceUnity.unregisterAudioFrameObserver();
      await AgoraRtcFaceUnity.unregisterVideoFrameObserver();
    }
    await _engine.leaveChannel();
    await _engine.destroy();
  }

  @override
  void initState() {
    super.initState();

    //ホームインジケーター非表示
    HomeIndicator.hide();
    WidgetsBinding.instance.addObserver(this);

    Screen.keepOn(true);

    if (widget.isPortrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      //ステータスバー非表示
      SystemChrome.setEnabledSystemUIOverlays([]);

      // 右向きを優先させるため、いったん右向きだけを有効にして、ちょっと立った後に両方有効にする
      // iOSとAndroidで逆向きっぽい
      SystemChrome.setPreferredOrientations([
        Platform.isIOS
            ? DeviceOrientation.landscapeRight
            : DeviceOrientation.landscapeLeft,
      ]);
      Timer(Duration(seconds: 1), () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      });
    }

    final userModel = Provider.of<UserModel>(context, listen: false);
    _token = userModel.token;
    _userId = userModel.id;

    _cameraOff = _cameraType == CameraType.MicOnly;

    _initializeAgoraSdk();
    DeepLinkHandlerStack.instance()
        .push(DeepLinkHandler(showLiverProfile: (liverId) {
      // ライブ中はプロフィール画面に遷移させない
    }, showChat: (orderIc) {
      // ライブ中はチャット画面に遷移させない
    }));
    _resetRelayNextInfo();
    _socketConnect();
    _setLike();
    _requestGiftInfo();
    PushNotificationManager.instance().pushHandler(PushNotificationHandler(
      onReceive: (action, message) {
        // ライブ中は遷移させない
      },
    ));
  }

  void saveBroadcasting() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    userModel.setIsBroadcasting(true);
    userModel.saveToStorage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        if (!ImageUtil.isPickingImage) {
          _isAppBackground = true;
          if (!_quitting) {
            _sendLeave(true);
            _engine.muteLocalVideoStream(true);
            _engine.muteLocalAudioStream(true);
          }
        }
        break;
      case AppLifecycleState.resumed:
        if (_isAppBackground) {
          _isAppBackground = false;
          if (!_quitting) {
            _sendLeave(false);
            if (!_cameraOff && _cameraType != CameraType.MicOnly)
              _engine.muteLocalVideoStream(false);
            if (_micOn) _engine.muteLocalAudioStream(false);
          }
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _sendLeave(bool isLeave) {
    _isLeave = isLeave;
    _socket.json.emit('leave', {
      'token': _token,
      'live_id': widget.liveId,
      'user_id': _userId,
      'is_leave': isLeave,
    });
  }

  Future<void> _initializeAgoraSdk() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    await _engine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');

    final userModel = Provider.of<UserModel>(context, listen: false);
    final config = Agora.VideoEncoderConfiguration();
    config.dimensions =
        AgoraRtcHelper.dimensions(userModel.liveWidth, userModel.liveHeight);
    config.orientationMode = AgoraRtcHelper.orientationMode(widget.isPortrait);
    config.frameRate = AgoraRtcHelper.frameRate(userModel.liveFrameRate);
    config.bitrate = userModel.liveBitrate;
    _engine.setVideoEncoderConfiguration(config);
    _engine.setAudioProfile(
      Agora.AudioProfile.MusicHighQualityStereo,
      Agora.AudioScenario.GameStreaming,
    );
    _engine.setParameters("{\"che.audio.enable.aec\":false}");
    _engine.setParameters("{\"che.audio.enable.agc\":false}");
    _engine.setParameters("{\"che.audio.enable.ns\":false}");
    if (_enableBeautification()) {
      await AgoraRtcFaceUnity.registerAudioFrameObserver(
        await _engine.getNativeHandle(),
      );
      await AgoraRtcFaceUnity.registerVideoFrameObserver(
        await _engine.getNativeHandle(),
      );
    }

    switch (_cameraType) {
      case CameraType.InCamera:
        break;
      case CameraType.OutCamera:
        // Agoraの配信はセルフィーカメラから始まるという前提で、アウトカメラだったら切り替える。
        _engine.switchCamera();
        break;
      case CameraType.MicOnly:
        _cameraOff = true;
        break;
    }

    await _engine.joinChannel(null, widget.liveId, null, 0);

    _sePlayer.initialize(Consts.SE_MIXING_VOLUME_PERCENT);

    await Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _checkStart = true;
      });
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await Agora.RtcEngine.create(Consts.AGORA_APP_ID);

    if (_cameraType != CameraType.MicOnly) {
      await _engine.enableVideo();
    }
    await _engine.setChannelProfile(Agora.ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(Agora.ClientRole.Broadcaster);

    _sePlayer = SePlayer(_engine);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    final eventHandler = Agora.RtcEngineEventHandler();
    eventHandler.error = (Agora.ErrorCode code) {
      setState(() {
        final info = 'onError: $code';
        debugPrint(info);
      });
    };

    eventHandler.firstLocalVideoFrame = (width, height, elapsed) {
      // 美顔機能.
      if (!_initializedBeautification) {
        initBeautification();
        _initializedBeautification = true;
      }
    };

    //AgoraRtcEngine.onJoinChannelSuccess = (String channel,
    //    int uid,
    //    int elapsed,) {
    //};

    //AgoraRtcEngine.onLeaveChannel = () {
    //};

    eventHandler.userJoined = (int uid, int elapsed) {
      setState(() {
        _users.add(uid);
        if (_myId == null) _myId = uid;
      });
    };

    eventHandler.userOffline = (int uid, Agora.UserOfflineReason reason) {
      setState(() {
        _users.remove(uid);
        if (_myId == uid) _myId = null;
      });
    };

    //AgoraRtcEngine.onFirstRemoteVideoFrame = (
    //    int uid,
    //    int width,
    //    int height,
    //    int elapsed,
    //    ) {
    //};
    _engine.setEventHandler(eventHandler);
  }

  Future initBeautification() async {
    if (!_enableBeautification()) {
      return;
    }
    var isPhysicalDevice = false;
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      isPhysicalDevice = iosInfo.isPhysicalDevice;
    } else {
      final androidInfo = await deviceInfo.androidInfo;
      isPhysicalDevice = androidInfo.isPhysicalDevice;
    }
    // シミューレーターの場合は何もしない.
    if (!isPhysicalDevice) {
      return;
    }
    try {
      await AgoraRtcFaceUnity.enableFaceBeautification();
      await Future.delayed(Duration(milliseconds: 500));
      final beautification = await BeautificationUseCase.load();
      await AgoraRtcFaceUnity.initializeFaceBeautification(
        beautification: beautification,
      );
    } catch (e) {
      print('Beautification Initialize Error');
    }
  }

  Future<bool> _requestGiftInfo() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);
    // TODO: 仮データじゃなくなったら直接APIを叩く
    final list = await BottomSheetGift.requestGiftInfo(service, userModel);
    if (list == null) return false;
    setState(() {
      _giftInfoList = list;
    });
    return true;
  }

  void _checkLiverAlive() {
    _socket.json.emit('liver_alive', {
      'token': _token,
      'live_id': widget.liveId,
      'user_id': _userId,
    });
  }

  void _socketConnect() {
    _socket = IO.io(BackendService.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });
    // socket.on('disconnect', (_) => print('disconnect'));

    _socket.on('connect', (data) {
      _socket.json.emit('connect_live', {
        'token': _token,
        'user_id': _userId,
        'live_id': widget.liveId,
        'is_leave': _isLeave,
      });

      // マイクのみの場合には最初にカメラオフを送る
      if (_cameraType == CameraType.MicOnly) {
        // なぜか emit connect_live と同じタイミングで送ると反映されないので、
        // １フレーム遅らせてみる。
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _socket.json.emit('camera_off', {
            'token': _token,
            'user_id': _userId,
            'live_id': widget.liveId,
            'camera_off': true,
          });
        });
      }
    });
    _socket.on('connected_live', (data) {
      setState(() {
        _audienceCount = data['person_count'] ?? _audienceCount;
        _giftPoint = data['point'];
      });
    });
    //_socket.on('disconnect_room', (data) {
    //  print('disconnect_room: $data');
    //});
    _socket.on('disconnect_liver', (data) {
      if (_debugIllegalLiveId(data['live_id'])) return;

      if (!_quitting) {
        // サーバから切断された場合
        setState(() => _quitting = true);
        /*await*/ _disconnect();
        showDisconnectDialog(context, data['msg']);
      }
    });
    _socket.on('disconnect_listener', (data) {
      if (_debugIllegalLiveId(data['live_id'])) return;

      setState(() {
        if (data != null &&
            data['person_count'] != null &&
            data['person_count'] is int) {
          _audienceCount = data['person_count'];
        } else {
          --_audienceCount;
        }
        _audienceCount = max(_audienceCount, 0);
      });
    });
    _socket.on('liver_alive', (data) {
      if (data['result']) {
        Future.delayed(Duration(seconds: 30), () {
          _checkLiverAlive();
        });
      }
    });
    _socket.on('gift', (dynamic data) {
      if (_debugIllegalLiveId(data['live_id'])) return;

      // TODO: 実際にギフトをサーバから取得するようにした場合に、対応するギフトを選択する仕組み
      int num =
          int.tryParse(data['gift_id'].toString()); // >= 1, not start from 0
      if (num != null) {
        setState(() {
          final animPattern = num; // TODO: ギフトIDとアニメーションをマッチングさせる仕組み
          _giftAnimationQueue.add(animPattern);
          _giftPoint = data['point'];
        });
      }
    });
    _socket.on('event_relay_start_reservation', (data) {
      // イベントのチェック.
      if (_eventId != data['event_id']) {
        return;
      }
      // 次のリレー配信者情報を更新.
      setState(() {
        _setRelayNextInfo(
          liverId: data['liver_id'],
          liverName: data['liver_nickname'],
          startDate: DateTime.tryParse(data['start_date'] as String),
        );
      });
    });

    // リレー配信の切り替え.
    _socket.on('event_relay_start', (data) {
      // 自身の配信じゃない場合は無視.
      if (widget.liveId != data['live_id']) {
        return;
      }
      setState(() {
        _eventId = data['event_id'];
        _relayStartDate = DateTime.tryParse(data['start_date'] as String);
        _relayEndDate = DateTime.tryParse(data['end_date'] as String);
      });
    });
  }

  /// 次のリレー配信者情報を更新.
  void _setRelayNextInfo({
    @required String liverId,
    @required String liverName,
    @required DateTime startDate,
  }) {
    _relayNextLiverId = liverId;
    _relayNextLiverName = liverName;
    _relayNextStartDate = startDate;
  }

  /// 次のリレー配信者情報をリセット.
  void _resetRelayNextInfo() {
    _setRelayNextInfo(
      liverId: '',
      liverName: '',
      startDate: null,
    );
  }

  void _setLike() {
    _socket.on('like', (data) {
      if (_spawnLikeParticle != null) _spawnLikeParticle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final contentWidth = mq.size.width - mq.padding.left - mq.padding.right;
    return OrientationBuilder(builder: (context, orientation) {
      return Stack(
          children: <Widget>[
        !_cameraOff || _startTime == null
            ? null
            : LiverProfileBackground(
                _userId,
                cameraOff: _cameraOff,
              ),
        _cameraOff
            ? null
            : Container(
                height: double.infinity,
                width: double.infinity,
                child: RtcLocalView.SurfaceView(),
              ),
        SafeArea(
          bottom: false,
          right: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: WillPopScope(
              onWillPop: () {
                if (_quitting) return Future.value(false);
                return _viewEndDialog();
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: GiftAnimationWidget(
                      animationQueue: _giftAnimationQueue,
                    ),
                  ),
                  !_isChat
                      ? null
                      : Positioned(
                          bottom: _isChatBottomSheet ? 64 : 0,
                          left: 10,
                          right:
                              orientation == Orientation.portrait ? 80 : null,
                          width: orientation == Orientation.portrait
                              ? null
                              : contentWidth *
                                  (2.0 / 3), // ランドスケープの場合：コンテンツ幅の2/3としてみる
                          height: 200,
                          child: LiveMessageWidget(
                            socket: _socket,
                            giftInfoList: _giftInfoList,
                            isLiver: true,
                            liveId: widget.liveId,
                          ),
                        ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: LikeParticles(
                        Consts.MAX_LIKE_PARTICLE,
                        onReadyCallback: (spawn) {
                          _spawnLikeParticle = spawn;
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LiveTimerWidget(_startTime),
                          const SizedBox(height: 5),
                          Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: const BoxDecoration(
                                color: ColorLive.TRANS_90,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                SvgPicture.asset(
                                  "assets/svg/user.svg",
                                  height: 11,
                                ),
                                Text(
                                  '$_audienceCount',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          LiveGiftPointView(
                            point: _giftPoint,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    GiftRankingDialog(
                                  liverId: _userId,
                                ),
                              );
                            },
                          ),
                          if (!_micOn) const LiveMuteMicMark(),
                        ].where((w) => w != null).toList(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: orientation == Orientation.portrait ? 10 : 100,
                    child: LiveCloseButton(
                      onTap: () {
                        _viewEndDialog();
                      },
                      text: Lang.END,
                      space: 18,
                    ),
                  ),
                  if (_relayEndDate != null)
                    Positioned(
                      top: 40,
                      right: orientation == Orientation.portrait ? 10 : 100,
                      child: LiveRelayTimerWidget(
                        endDate: _relayEndDate,
                      ),
                    ),
                  if (_relayNextLiverId.isNotEmpty)
                    Positioned(
                      top: 65,
                      right: orientation == Orientation.portrait ? 10 : 100,
                      child: LiveNextLiverBoard(
                        liverId: _relayNextLiverId,
                        liverName: _relayNextLiverName,
                        startDate: _relayNextStartDate,
                      ),
                    ),
                  if ((widget.broadcastInfo.eventType == LiveEventType.relay) &&
                      (widget.broadcastInfo.memberStartDate
                          .isAfter(DateTime.now())))
                    Center(
                      child: LiveStartCountdownWidget(
                          startDate: widget.broadcastInfo.memberStartDate,
                          endDate: widget.broadcastInfo.memberEndDate,
                          onStop: () {
                            Future.delayed(Duration(milliseconds: 100), () {
                              setState(() {});
                            });
                          }),
                    ),
                  orientation == Orientation.portrait
                      ? null
                      : Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: _buildLandscapeMenu(context),
                        ),
                ].where((w) => w != null).toList(),
              ),
            ),
            bottomNavigationBar: orientation == Orientation.landscape
                ? null
                : SafeArea(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 54,
                      color: ColorLive.BLUE_BG,
                      child: FlatButton(
                        child: const Text(
                          Lang.OPEN_MENU,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        onPressed: () {
                          _bottomSheet();
                        },
                      ),
                    ),
                  ),
          ),
        ),
        !_quitting ? null : Container(color: const Color(0x40000000)),
      ].where((w) => w != null).toList());
    });
  }

  Widget _buildLandscapeMenu(BuildContext context) {
    return Container(
      width: 90,
      color: ColorLive.BLUE_BG.withOpacity(0.5),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _landscapeMenuButton(
              svgName: "chat",
              text: Lang.CHAT,
              onPressed: () {
                _bottomSheetInputChat(backToMenu: false);
              },
            ),
            _landscapeMenuButton(
              svgName: "sound_effect",
              text: Lang.SOUND_EFFECT,
              onPressed: () {
                _bottomSheetSoundEffect(backToMenu: false);
              },
            ),
            _landscapeMenuButton(
              svgName: "product",
              text: Lang.PRODUCT_SALES,
              onPressed: () {
                _bottomSheetProduct(backToMenu: false, landscape: true);
              },
            ),
            _isMicOnly()
                ? null
                : _landscapeMenuButton(
                    svgName: "switch",
                    text: Lang.CAMERA_SWITCH,
                    onPressed: () {
                      _toggleCameraSelfie();
                    },
                  ),
            _isMicOnly()
                ? null
                : !_enableBeautification()
                    ? _landscapeMenuButton(
                        svgName: 'face',
                        text: _isBeautifyEffect
                            ? Lang.BEAUTIFY_EFFECT_OFF
                            : Lang.BEAUTIFY_EFFECT_ON,
                        onPressed: () {
                          setState(() => _toggleBeautifyEffect());
                        },
                      )
                    : _landscapeMenuButton(
                        svgName: 'face',
                        text: Lang.BEAUTIFY_OPTION,
                        onPressed: () async {
                          await showBeautyBottomSheet(
                            context: context,
                          );
                        },
                      ),
            _isMicOnly()
                ? null
                : _landscapeMenuButton(
                    svgName: _cameraOff ? "camera_off" : "camera_on",
                    text: _cameraOff ? Lang.CAMERA_ON : Lang.CAMERA_OFF,
                    onPressed: () {
                      setState(() {
                        _toggleCameraMute();
                      });
                    },
                  ),
            _landscapeMenuButton(
              svgName: _micOn ? "unmute" : "mute",
              text: _micOn ? Lang.MUTE : Lang.UNMUTE,
              onPressed: () {
                _toggleMute();
              },
            ),
            _landscapeMenuButton(
              svgName: "user",
              text: Lang.AUDIENCE,
              onPressed: () {
                _bottomSheetAudience(backToMenu: false);
              },
            ),
          ].where((w) => w != null).toList(),
        ),
      ),
    );
  }

  Widget _landscapeMenuButton(
      {String svgName, String text, void Function() onPressed}) {
    return RawMaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 16),
      onPressed: onPressed,
      child: _menuColumn(svgName: svgName, text: text),
    );
  }

  // 呼び出されるのはポートレートの場合のみ
  Future<void> _bottomSheet() async {
    await showTransparentModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return IntrinsicHeight(
          child: Container(
            color: ColorLive.BLUE_BG,
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _bottomSheetSplitH(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _bottomSheetButton(
                      svgName: 'chat',
                      text: Lang.CHAT,
                      onPressed: () {
                        Navigator.of(context).pop();
                        _bottomSheetInputChat(backToMenu: true);
                      },
                    ),
                    _bottomSheetSplitV(),
                    _bottomSheetButton(
                      svgName: 'sound_effect',
                      text: Lang.SOUND_EFFECT,
                      onPressed: () {
                        Navigator.of(context).pop();
                        _bottomSheetSoundEffect();
                      },
                    ),
                    _bottomSheetSplitV(),
                    _bottomSheetButton(
                      svgName: 'product',
                      text: Lang.PRODUCT_SALES,
                      onPressed: () {
                        Navigator.of(context).pop();
                        _bottomSheetProduct(backToMenu: true);
                      },
                    ),
                    _isMicOnly() ? null : _bottomSheetSplitV(),
                    _isMicOnly()
                        ? null
                        : _bottomSheetButton(
                            svgName: 'user',
                            text: Lang.AUDIENCE,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _bottomSheetAudience(backToMenu: true);
                            },
                          ),
                  ].where((w) => w != null).toList(),
                ),
                _bottomSheetSplitH(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _isMicOnly()
                        ? null
                        : !_enableBeautification()
                            ? _bottomSheetButton(
                                svgName: 'face',
                                text: _isBeautifyEffect
                                    ? Lang.BEAUTIFY_EFFECT_OFF
                                    : Lang.BEAUTIFY_EFFECT_ON,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _toggleBeautifyEffect();
                                },
                              )
                            : _bottomSheetButton(
                                svgName: 'face',
                                text: Lang.BEAUTIFY_OPTION,
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await showBeautyBottomSheet(
                                    context: context,
                                  );
                                },
                              ),
                    _isMicOnly() ? null : _bottomSheetSplitV(),
                    _isMicOnly()
                        ? null
                        : _bottomSheetButton(
                            svgName: 'switch',
                            text: Lang.CAMERA_SWITCH,
                            onPressed: () {
                              _toggleCameraSelfie();
                              Navigator.of(context).pop();
                            },
                          ),
                    _isMicOnly() ? null : _bottomSheetSplitV(),
                    _isMicOnly()
                        ? null
                        : _bottomSheetButton(
                            svgName: _cameraOff ? "camera_off" : "camera_on",
                            text: _cameraOff ? Lang.CAMERA_ON : Lang.CAMERA_OFF,
                            onPressed: () {
                              setState(() {
                                _toggleCameraMute();
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                    _isMicOnly() ? null : _bottomSheetSplitV(),
                    _bottomSheetButton(
                      svgName: _micOn ? "unmute" : "mute",
                      text: _micOn ? Lang.MUTE : Lang.UNMUTE,
                      onPressed: () {
                        _toggleMute();
                        Navigator.of(context).pop();
                      },
                    ),
                    !_isMicOnly() ? null : _bottomSheetSplitV(),
                    !_isMicOnly()
                        ? null
                        : _bottomSheetButton(
                            svgName: 'user',
                            text: Lang.AUDIENCE,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _bottomSheetAudience(backToMenu: true);
                            },
                          ),
                  ].where((w) => w != null).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isMicOnly() {
    return _cameraType == CameraType.MicOnly;
  }

  bool _enableBeautification() {
    return widget.enableBeautification && !_isMicOnly();
  }

  void _toggleCameraSelfie() {
    setState(() {
      _cameraType = _cameraType == CameraType.InCamera
          ? CameraType.OutCamera
          : CameraType.InCamera;
    });

    _engine.switchCamera();
  }

  void _toggleCameraMute() {
    setState(() {
      _cameraOff = !_cameraOff;

      _socket.json.emit('camera_off', {
        'token': _token,
        'user_id': _userId,
        'live_id': widget.liveId,
        'camera_off': _cameraOff,
      });
    });

    // カメラをOFFにする時はミュートをOFFにする
    if (!_micOn) {
      _toggleMute();
    }

    _engine.muteLocalVideoStream(_cameraOff);
  }

  void _toggleMute() {
    setState(() {
      _micOn = !_micOn;
      _engine.muteLocalAudioStream(!_micOn);

      _socket.json.emit('mute', {
        'token': _token,
        'user_id': _userId,
        'live_id': widget.liveId,
        'is_mute': !_micOn,
      });
    });
  }

  Future<void> _bottomSheetInputChat({bool backToMenu = true}) async {
    setState(() {
      _isChatBottomSheet = true;
    });

    await showTransparentModalBottomSheet(
      backgroundColor: ColorLive.BLUE_BG,
      context: context,
      isScrollControlled: true,
      builder: (context) => BottomSheetChatInput(
        controller: _chatTextController,
        isLiver: true,
        onBackMenu: () {
          Navigator.of(context).pop();
          KeyboardUtil.close(context);
          if (backToMenu) _bottomSheet();
        },
        onSend: (text, ng) {
          if (ng) {
            NGFilter.showAlertDialog(context);
          } else {
            final userModel = Provider.of<UserModel>(context, listen: false);

            final data = {
              "token": _token,
              "user_id": _userId,
              "live_id": widget.liveId,
              "nickname": userModel.nickname,
              'message': text,
            };
            _socket.json.emit('message', data);
            _chatTextController.clear();
            Navigator.of(context).pop();
          }
        },
      ),
    );

    setState(() {
      _isChatBottomSheet = false;
    });
  }

  Future<void> _bottomSheetSoundEffect({bool backToMenu = true}) async {
    await showTransparentModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BottomSheetSoundEffect(
          onBack: () {
            Navigator.of(context).pop();
            if (backToMenu) _bottomSheet();
          },
          onTap: (index) {
            _playSoundEffect(index);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _toggleBeautifyEffect() {
    _isBeautifyEffect = !_isBeautifyEffect;

    var beautyOptions = Agora.BeautyOptions();
    bool enable = _isBeautifyEffect;
    if (enable) {
      beautyOptions.smoothnessLevel = 1.0;
      beautyOptions.lighteningLevel = 0.5;
    }
    _engine.setBeautyEffectOptions(enable, beautyOptions);
  }

  void _playSoundEffect(int index) {
    _sePlayer.stop();
    _sePlayer.play(index);
  }

  //void _stopSoundEffect() {
  //  _sePlayer.stop();
  //}

  Future<void> _bottomSheetProduct(
      {bool backToMenu = true, bool landscape = false}) async {
    final tuple = await _requestEcItem();
    final products = tuple.item1;
    final storeProfiles = tuple.item2;
    if (products == null) {
      // TODO: エラー表示
      return;
    }

    final userModel = Provider.of<UserModel>(context, listen: false);

    if (landscape) {
      final mq = MediaQuery.of(context);
      await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: <Widget>[
                Container(
                  color: const Color(0x80000000),
                  child: SafeArea(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 32,
                              right: 32,
                              top: mq.padding.top > 0 ? 0 : 8,
                              bottom: mq.padding.bottom > 0 ? 0 : 8,
                            ),
                            child: BottomSheetProductSwiper(
                              viewportFraction: 0.8,
                              products: products,
                              storeProfiles: storeProfiles,
                              provideUserId: userModel.id,
                              isLiver: true,
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
                            ),
                          ),
                          child: FlatButton(
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.pop(context);
                              _bottomSheetProductAdd();
                            },
                            child: Text(
                              Lang.ADD_NEW_PRODUCT,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: max(mq.padding.top, 8),
                  right: mq.padding.right,
                  width: 30,
                  height: 30,
                  child: Material(
                    type: MaterialType.button,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return BottomSheetProduct(
            products: products,
            provideUserId: userModel.id,
            storeProfiles: storeProfiles,
            isLiver: true,
            onBack: () {
              Navigator.of(context).pop();
              KeyboardUtil.close(context);
              if (backToMenu) _bottomSheet();
            },
          );
        },
      );
    }
  }

  // 新規商品登録(product=null)、または編集(product=non null)
  Future<void> _bottomSheetProductAdd() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: ColorLive.BLUE_BG,
      builder: (context) {
        return BottomSheetProductAddEdit(
          onBack: () {
            KeyboardUtil.close(context);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<Tuple2<List<Product>, List<StoreProfile>>> _requestEcItem() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);
    final response = await service.getEcItem(userModel.id);
    if (response != null && response.result) {
      final list = List<Product>();
      for (final data in response.getData()) {
        list.add(Product.fromJson(data));
      }

      final products = list
          .where((p) => p.publicFlag)
          .orderByDescending((x) => x.isPublished ? 1 : 0)
          .thenByDescending((x) => x.createDate)
          .toList();

      // 商品が30以下の場合、下書きを挿入.
      final drafts = list.where((p) => !p.publicFlag).toList();
      int num = Consts.PRODUCT_LIVE_VIEW_MAX_LENGTH - products.length;
      if (drafts.length < num) {
        num = drafts.length;
      }
      if (num > 0) {
        products.insertAll(
            0, drafts.getRange(drafts.length - num, drafts.length));
      }

      List<StoreProfile> storeProfiles = [];
      if ((response.containsKey('store_data') &&
          (response.getByKey('store_data') != null))) {
        final list = response.getByKey('store_data') as List;
        storeProfiles = list.map((x) => StoreProfile.fromJson(x)).toList();
      }
      return Tuple2(products, storeProfiles);
    }
    return Tuple2(null, null);
  }

  Future<void> _bottomSheetAudience({bool backToMenu = true}) async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return BottomSheetAudience(
            liveId: widget.liveId,
            onBack: () {
              Navigator.of(context).pop();
              KeyboardUtil.close(context);
              if (backToMenu) _bottomSheet();
            },
          );
        });
  }

  Widget _bottomSheetButton(
      {String svgName,
      String text,
      double height: 28.0,
      void Function() onPressed}) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: 89.5,
            child: _menuColumn(svgName: svgName, text: text),
          ),
        ),
      ),
    );
  }

  Widget _bottomSheetSplitV() {
    return Container(
      height: 89.5,
      width: 1,
      color: ColorLive.C505,
    );
  }

  Widget _bottomSheetSplitH() {
    return Container(
      width: double.infinity,
      height: 1,
      color: ColorLive.C505,
    );
  }

  Widget _menuColumn({String svgName, String text, double height: 28.0}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          "assets/svg/menu/$svgName.svg",
          height: height,
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }

  Future<bool> _stopLive() async {
    _socket?.json?.emit('disconnect_room', {
      'token': _token,
      'user_id': _userId,
      'live_id': widget.liveId,
    });

    await _disconnect();

    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);
    final response = await service.postLiveStop(widget.liveId, userModel.id);
    if (response?.result == true) {
      // 放送中フラグをfalse
      userModel.setIsBroadcasting(false);
      userModel.saveToStorage();

      return true;
    }
    await showNetworkErrorDialog(context, msg: response?.getByKey('msg'));
    return false;
  }

  Future<bool> _viewEndDialog() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Text(
                      Lang.MESSAGE_END_STREAMING,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
                        ),
                      ),
                      child: FlatButton(
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          Lang.CANCEL,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                      ),
                      child: FlatButton(
                        textColor: Colors.black,
                        onPressed: () async {
                          Navigator.pop(context, true);
                        },
                        child: Text(
                          Lang.FINISH,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() => _quitting = true);
      if (!await _stopLive()) {
        setState(() => _quitting = false);
        return false;
      }
      Navigator.of(context).pushReplacement(
          FadeRoute(builder: (context) => ApplyJasracPage(widget.liveId)));
    }
    return false; // onWillPopで処理されたくないので、選ばれた選択肢にかかわらずfalseを返す
  }

  // デバッグ用：違うライブルームにいいねやギフトが飛ぶことがある？のを防止するための対策
  bool _debugIllegalLiveId(String liveId) {
    // ソケットに live_id が含まれない場合にもOKにする。
    return liveId != null && liveId != widget.liveId;
  }
}
