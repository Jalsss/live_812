import 'dart:async';
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart' as Agora;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/ec/store_profile.dart';
import 'package:live812/domain/model/json_data.dart';
import 'package:live812/domain/model/live/gift_info.dart';
import 'package:live812/domain/model/live/live_coach_mark.dart';
import 'package:live812/domain/model/live/room_info.dart';
import 'package:live812/domain/model/user/badge_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/distributor_details_dialog.dart';
import 'package:live812/ui/dialog/ec/buy_product_dialog.dart';
import 'package:live812/ui/dialog/gift_ranking_dialog.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_audience.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_chat_input.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_gift.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_product.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_share.dart';
import 'package:live812/ui/scenes/live/live_view_message.dart';
import 'package:live812/ui/scenes/live/live_view_spotlight_state.dart';
import 'package:live812/ui/scenes/live/widget/like_particles.dart';
import 'package:live812/ui/scenes/live/widget/live_close_button.dart';
import 'package:live812/ui/scenes/live/widget/live_gift_point_view.dart';
import 'package:live812/ui/scenes/live/widget/live_mute_mic_mark.dart';
import 'package:live812/ui/scenes/live/widget/live_next_liver_board.dart';
import 'package:live812/ui/scenes/live/widget/liver_profile_background.dart';
import 'package:live812/ui/scenes/user/history_purchase_page.dart';
import 'package:live812/utils/anim/gift_animation_widget.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/ng_filter.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/route/transparent_bottom_sheet_route.dart';
import 'package:live812/utils/share_util.dart';
import 'package:live812/utils/widget/safe_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tuple/tuple.dart';
import 'package:flushbar/flushbar.dart';
import 'package:live812/domain/model/socket/like_socket_model.dart';

class LiveViewContent extends StatefulWidget {
  LiveViewContent({
    this.roomInfo,
    this.setOrientation,
  });

  final RoomInfoModel roomInfo;
  final Function(bool) setOrientation;

  @override
  _LiveViewContentState createState() => _LiveViewContentState();
}

class _LiveViewContentState extends State<LiveViewContent> {
  TextEditingController _chatTextController = TextEditingController();

  /// 配信ID.
  String _liveId;

  /// ライバーID.
  String _liverId;

  /// イベントID.
  String _eventId;

  String _relayNextLiverId = '';
  String _relayNextLiverName = '';
  DateTime _relayNextStartDate;

  bool _isChat = true;
  bool _isChatBottomSheet = false;
  final List<int> _giftAnimationQueue = [];
  IO.Socket _socket;
  String _token;
  String _userId;
  UserModel _liverUserModel; // ライバーの情報
  bool _followRequesting = false;
  bool _micOn = true;
  bool _cameraOff = false;

  /// 画面の向き.
  bool _isPortrait = true;
  bool _isLeave = false; // 離席中？
  int _giftPoint = 0;
  List<GiftInfoModel> _giftInfoList;
  void Function() _spawnLikeParticle;
  Timer _sendingLikeTimer;
  bool _quitting = false;
  String _quitMessage;
  bool _disposing = false;

  final GlobalKey<_LiveViewContentState> keyLike =
      GlobalKey<_LiveViewContentState>();
  final GlobalKey<_LiveViewContentState> keyGift =
      GlobalKey<_LiveViewContentState>();
  final GlobalKey<_LiveViewContentState> keyFollow =
      GlobalKey<_LiveViewContentState>();
  final GlobalKey<_LiveViewContentState> keyMenu =
      GlobalKey<_LiveViewContentState>();

  LiveViewSpotlightState _spotlightState;
  LikeSocketModel likeModel;
  // Agora
  Agora.RtcEngine _engine;
  final _users = <int>[];
  int _myId;

  int stateView = 0;

  @override
  void dispose() {
    _disposing = true;
    _chatTextController.dispose();

    _disconnect();

    super.dispose();
  }

  dynamic _safeSetState(Function f) {
    if (mounted && !_disposing)
      return setState(f);
    else
      return f();
  }

  Future<void> _disconnect() async {
    if (_socket != null) {
      _socket.clearListeners();
      _socket.close();
      _safeSetState(() => _socket = null);
    }

    // destroy sdk
    await _engine.leaveChannel();
    await _engine.destroy();
  }

  @override
  void initState() {
    super.initState();

    _liveId = widget.roomInfo.liveId;
    _liverId = widget.roomInfo.liverId;
    _eventId = widget.roomInfo.eventId;
    _isPortrait = widget.roomInfo.isPortrait;

    // 次のリレー配信情報を初期化.
    _resetRelayNextInfo();

    /// ソケットサーバーへの接続.
    _connectSocket();

    _getLiverUserInfo();
    _requestGiftInfo();

    LiveCoachMark.isShowCoachMark().then((isShow) {
      if (isShow == null || isShow == false) {
        Future.delayed(Duration(seconds: 2)).then((value) {
          _spotlightState = LiveViewSpotlightState(
            [
              keyLike,
              keyGift,
              keyFollow,
              keyMenu,
              keyMenu,
            ],
            onPageChanged: (page) {
              if (page == null) {
                // スポットライト終了
                setState(() => _spotlightState = null);
                _startPlayer();
              } else {
                setState(() {}); // 更新反映
              }
            },
          );

          _spotlightState.displaySpotlight(0);
        });
      } else {
        _startPlayer();
      }
    });
  }

  void _startPlayer() {
    _initializeAgoraSdk();
  }

  Future<void> _initializeAgoraSdk() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.enableWebSdkInteroperability(true);
    _engine.setAudioProfile(
      Agora.AudioProfile.MusicHighQualityStereo,
      Agora.AudioScenario.GameStreaming,
    );
    await _engine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await _engine.setParameters("{\"che.audio.force.bluetooth.a2dp\":1}");
    await _engine.joinChannel(null, _liveId, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await Agora.RtcEngine.create(Consts.AGORA_APP_ID);

    await _engine.enableVideo();
    await _engine.setChannelProfile(Agora.ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(Agora.ClientRole.Audience);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    final eventHandler = Agora.RtcEngineEventHandler();
    eventHandler.error = (dynamic code) {
      final info = 'onError: $code';
      debugPrint(info);
    };

    //AgoraRtcEngine.onJoinChannelSuccess = (String channel,
    //    int uid,
    //    int elapsed,) {
    //  final info = 'onJoinChannel: $channel, uid: $uid';
    //  debugPrint(info);
    //};

    eventHandler.leaveChannel = (Agora.RtcStats stats) {
      _users.clear();
    };

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
    //  final info = 'firstRemoteVideo: $uid ${width}x $height';
    //  debugPrint(info);
    //};
    _engine.setEventHandler(eventHandler);
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

  bool _following() {
    return _liverUserModel != null && _liverUserModel.json['followed'] == true;
  }

  /// ソケットの接続.
  void _connectSocket() {
    _socket = IO.io(BackendService.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
    });
    // socket.on('disconnect', (_) => print('disconnect'));

    _socket.on('connect', (_) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _token = userModel.token;
      _userId = userModel.id;
      _socket.json.emit('connect_live', {
        'token': _token,
        'user_id': _userId,
        'live_id': _liveId,
      });
    });

    _socket.on('connected_live', (data) {
      setState(() {
        _giftPoint = data['point'] ?? _giftPoint;
        _micOn = !(data['is_mute'] == true);
        _cameraOff = data['camera_off'] == true;
        _isLeave = data['is_leave'] == true;
        // 画面の向きが違うなら変更.
        if (_isPortrait != (data['is_landscape'] != true)) {
          _isPortrait = !_isPortrait;
          if (widget.setOrientation != null) {
            widget.setOrientation(_isPortrait);
          }
        }
      });
    });

    _socket.on('alive_check', (data) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _token = userModel.token;
      _userId = userModel.id;
      _socket.json.emit('connect_live', {
        'token': _token,
        'user_id': _userId,
        'live_id': _liveId,
      });
    });

    _socket.on('disconnect_liver', (data) {
      if (_debugIllegalLiveId(data['live_id'])) {
        return;
      }

      if (!_quitting) {
        // サーバから切断された場合
        _quitMessage = data['msg'];
        setState(() => _quitting = true);
        /*await*/ _disconnect();
      }
    });

    _socket.on('like', (data) {
      if (_debugIllegalLiveId(data['live_id'])) {
        return;
      }

      if (_spawnLikeParticle != null) {
        _spawnLikeParticle();
      }
    });

    _socket.on('gift', (data) {
      int num;
      if (_debugIllegalLiveId(data['live_id'])) {
        return;
      }

      if (!data['result']) {
        num = 3516;
      } else {
        num =
            int.tryParse(data['gift_id'].toString()); // >= 1, not start from 0
      }

      if (num == null) {
        return;
      }
      setState(() {
        final animPattern = num; // TODO: ギフトIDとアニメーションをマッチングさせる仕組み
        _giftAnimationQueue.add(animPattern);
        _giftPoint = data['point'] ?? _giftPoint;
      });
    });

    _socket.on('mute', (data) {
      if (_debugIllegalLiveId(data['live_id'])) {
        return;
      }

      setState(() {
        _micOn = !(data['is_mute'] == true);
      });
    });

    _socket.on('camera_off', (data) {
      if (_debugIllegalLiveId(data['live_id'])) {
        return;
      }

      setState(() {
        _cameraOff = data['camera_off'] == true;
      });
    });

    _socket.on('leave', (data) {
      if (_debugIllegalLiveId(data['live_id'])) {
        return;
      }

      setState(() {
        _isLeave = data['is_leave'] == true;
      });
    });

    // リレー配信の切り替え.1分前.
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
          startDate: DateTime.tryParse(data['start_date']),
        );
      });
    });

    // リレー配信の切り替え.
    _socket.on('event_relay_start', (data) {
      // イベントのチェック.
      if (_eventId != data['event_id']) {
        return;
      }

      // 既に配信を見ている場合も無視.
      if (_liveId == data['live_id']) {
        return;
      }

      _liveId = data['live_id'];
      _liverId = data['liver_id'];

      _switchChannel();
    });
  }

  // デバッグ用：違うライブルームにいいねやギフトが飛ぶことがある？のを防止するための対策
  bool _debugIllegalLiveId(String liveId) {
    // ソケットに live_id が含まれない場合にもOKにする。
    return liveId != null && liveId != _liveId;
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

  /// リレー配信時のライブ配信の切り替え.
  Future<void> _switchChannel() async {
//    await AgoraRtcEngine.switchChannel(null, _liveId);
    await _engine.leaveChannel();
    await _engine.joinChannel(null, _liveId, null, 0);
    _getLiverUserInfo();
    _resetRelayNextInfo();
    setState(() {});
    Future(() {
      final userModel = Provider.of<UserModel>(context, listen: false);
      _token = userModel.token;
      _userId = userModel.id;
      _socket.json.emit('connect_live', {
        'token': _token,
        'user_id': _userId,
        'live_id': _liveId,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Spotlight を表示する際に OrientationBuilder が入っているとエラーが発生するので
    // その場合には挟まないようにする。
    // ランドスケープの場合、画面下部にメニューボタンがないので、スポットライトが
    // ちゃんと動作しないかもしれない
    if (_spotlightState?.enable == true) {
      return _buildMain(context, Orientation.portrait);
    } else {
      return OrientationBuilder(
        builder: (context, orientation) {
          return _buildMain(context, orientation);
        },
      );
    }
  }

  Widget _buildMain(BuildContext context, Orientation orientation) {
    final mq = MediaQuery.of(context);
    final contentWidth = mq.size.width - mq.padding.left - mq.padding.right;
    if (_socket != null) {
      _socket.on('like', (dynamic data) {
        setState(() {
          likeModel = LikeSocketModel.fromJson(data);
        });
      });
    }
    return Stack(
      children: <Widget>[
        !_isLeave && !_cameraOff
            ? null
            : LiverProfileBackground(
                _liverUserModel?.id,
                isLeave: _isLeave,
                cameraOff: _cameraOff,
                eventId: _eventId,
              ),
        _isLeave || (_users.isEmpty || _cameraOff)
            ? null
            : Container(
                height: double.infinity,
                width: double.infinity,
                child: RtcRemoteView.SurfaceView(uid: _users[0]),
              ),
        SafeArea(
          bottom: false,
          child: Spotlight(
            enabled: _spotlightState?.enable == true,
            center: _spotlightState?.center,
            radius: _spotlightState?.radius,
            description: _spotlightState?.description,
            animation: true,
            color: const Color.fromRGBO(0, 0, 0, 0.8),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              body: Container(
                child: Stack(
                  children: <Widget>[
                    stateView == 2 || stateView == 0
                        ? Opacity(
                            opacity: 1,
                            child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: GiftAnimationWidget(
                                  animationQueue: _giftAnimationQueue,
                                )),
                          )
                        : Opacity(
                            opacity: 0,
                            child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                child: GiftAnimationWidget(
                                  animationQueue: _giftAnimationQueue,
                                )),
                          ),
                    !_isChat
                        ? Container()
                        : Positioned(
                            bottom: _isChatBottomSheet ? 0 : 0,
                            left: 10,
                            right:
                                orientation == Orientation.portrait ? 90 : null,
                            width: orientation == Orientation.portrait
                                ? null
                                : contentWidth *
                                    (2.0 / 3), // ランドスケープの場合：コンテンツ幅の2/3としてみる
                            height: 200,
                            child: LiveViewMessageWidget(
                              socket: _socket,
                              giftInfoList: _giftInfoList,
                              isLiver: false,
                              liveId: _liveId,
                              stateView: stateView,
                            ),
                          ),
                    likeWidget(likeModel),
                    Positioned(
                      top: orientation == Orientation.portrait ? 6 : 0,
                      left: 0,
                      right: orientation == Orientation.landscape
                          ? 90
                          : 0, // ランドスケープの場合右にメニューがあるので、その分幅を狭める
                      child: _buildTopRow(context, orientation),
                    ),
                    (orientation == Orientation.portrait
                        ? Positioned(
                            bottom: _isChatBottomSheet ? 64 : 0,
                            right: 0,
                            child: _buildPortraitMenu(context))
                        : Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: _buildLandscapeMenu(context))),
                  ],
                ),
              ),
              bottomNavigationBar: orientation == Orientation.landscape
                  ? null
                  : SafeArea(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 54,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            colors: [ColorLive.BLUE_BG, ColorLive.BLUE_BG],
                          ),
                        ),
                        child: FlatButton(
                          child: Text(
                            Lang.OPEN_MENU,
                            key: keyMenu,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                          ),
                          onPressed: () {
                            _bottomSheet();
                          },
                        ),
                      ),
                    ),
            ),
          ),
        ),
        !_quitting ? null : _DisconnectLiveViewContent(msg: _quitMessage)
      ].where((w) => w != null).toList(),
    );
  }

  Widget likeWidget(LikeSocketModel likeModel) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    switch (stateView) {
      case 0:
        return like();
        break;
      case 1:
        return likeModel != null && likeModel.userId == userModel.id
            ? like()
            : Container();
        break;
      case 2:
        return like();
        break;
      case 3:
        return likeModel != null && likeModel.userId == userModel.id
            ? like()
            : Container();
        break;
      default:
        return Container();
    }
  }

  Widget like() {
    return Positioned.fill(
      child: IgnorePointer(
        child: LikeParticles(
          Consts.MAX_LIKE_PARTICLE,
          onReadyCallback: (spawn) {
            _spawnLikeParticle = spawn;
          },
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, Orientation orientation) {
    return Container(
      margin: EdgeInsets.only(
        top: orientation == Orientation.portrait ? 0 : 10,
        left: 10,
        right: 10,
      ),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: RawMaterialButton(
                            onPressed: _liverUserModel == null
                                ? null
                                : () {
                                    _viewDistributorDetails();
                                  },
                            elevation: 2,
                            padding: const EdgeInsets.all(2),
                            shape: const CircleBorder(),
                            child: CircleAvatar(
                              radius: 25.0,
                              backgroundImage: SafeNetworkImage(
                                  BackendService.getUserThumbnailUrl(
                                      _liverUserModel?.id)),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _liverUserModel?.nickname ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 5.0,
                                      color: Colors.black,
                                      offset: Offset(0, 1),
                                    ),
                                    Shadow(
                                      blurRadius: 5.0,
                                      color: Colors.black,
                                      offset: Offset(2, 1),
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              _followButton(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LiveGiftPointView(
                      point: _giftPoint,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return GiftRankingDialog(liverId: _liverId);
                          },
                        );
                      },
                    ),
                    if (!_micOn) const LiveMuteMicMark(),
                  ].where((w) => w != null).toList(),
                ),
              ),
              Container(
                child: LiveCloseButton(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  text: Lang.CLOSE,
                ),
              ),
            ],
          ),
          if (_relayNextLiverId.isNotEmpty)
            Positioned(
              top: 27.5,
              child: LiveNextLiverBoard(
                liverId: _relayNextLiverId,
                liverName: _relayNextLiverName,
                startDate: _relayNextStartDate,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPortraitMenu(BuildContext context) {
    return Column(
      children: <Widget>[
        RawMaterialButton(
          key: keyLike,
          onPressed: () {
            final userModel = Provider.of<UserModel>(context, listen: false);

            if (_sendingLikeTimer != null) {
              if (_spawnLikeParticle != null) _spawnLikeParticle();
              return;
            }
            if ((_socket == null) || (_token == null) || (_userId == null)) {
              return;
            }

            _socket.json.emit('like', {
              'token': _token,
              'user_id': _userId,
              'live_id': _liveId,
              'nickname': userModel.nickname,
            });
            _sendingLikeTimer = Timer(Duration(milliseconds: 300), () {
              setState(() => _sendingLikeTimer = null);
            });
          },
          shape: const CircleBorder(),
          elevation: 2.0,
          padding: const EdgeInsets.all(5),
          child: Container(
            height: 80.0,
            child: Image.asset('assets/images/ico01.png'),
          ),
        ),
        RawMaterialButton(
          key: keyGift,
          onPressed: () {
            _bottomSheetGift(onTap: (index, giftInfo) {
              _sendGift(index, giftInfo, context);
              return;
            });
          },
          shape: const CircleBorder(),
          elevation: 2.0,
          padding: const EdgeInsets.all(5),
          child: Container(
            height: 80.0,
            child: Image.asset('assets/images/ico02.png'),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeMenu(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateView) {
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
                svgName: "gift",
                text: Lang.GIFT,
                onPressed: () {
                  _bottomSheetGift(onTap: (index, giftInfo) {
                    _sendGift(index, giftInfo, context);
                    return;
                  });
                },
              ),
              _landscapeMenuButton(
                svgName: "card",
                text: Lang.PRODUCT_LIST,
                onPressed: () {
                  _bottomSheetProduct(backToMenu: false, landscape: true);
                },
              ),
              _landscapeMenuButton(
                svgName: "family",
                text: Lang.AUDIENCE,
                onPressed: () {
                  _bottomSheetAudience(backToMenu: false);
                },
              ),
              RawMaterialButton(
                padding: const EdgeInsets.symmetric(vertical: 8),
                onPressed: () {
                  switch (stateView) {
                    case 0:
                      setState(() {
                        stateView = 1;
                      });
                      setStateView(() {
                        stateView = 1;
                      });
                      break;
                    case 1:
                      setState(() {
                        stateView = 2;
                      });
                      setStateView(() {
                        stateView = 2;
                      });
                      break;
                    case 2:
                      setState(() {
                        stateView = 3;
                      });
                      setStateView(() {
                        stateView = 3;
                      });
                      break;
                    case 3:
                      setState(() {
                        stateView = 0;
                      });
                      setStateView(() {
                        stateView = 0;
                      });
                      break;
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Stack(alignment: Alignment.topLeft, children: [
                      SvgPicture.asset(
                        "assets/svg/icon_0${stateView + 1}.svg",
                        height: 25,
                      ),
                    ]),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '⾮表⽰機能',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    )
                  ],
                ),
              ),
              _landscapeMenuButton(
                svgName: "heart",
                text: Lang.HEART,
                onPressed: () {
                  final userModel =
                      Provider.of<UserModel>(context, listen: false);

                  if ((_socket == null) ||
                      (_token == null) ||
                      (_userId == null)) {
                    return;
                  }

                  final data = {
                    'token': _token,
                    'user_id': _userId,
                    'live_id': _liveId,
                    'nickname': userModel.nickname,
                  };

                  _socket.json.emit('like', data);
                },
              ),
              _landscapeMenuButton(
                svgName: "menu04",
                text: Lang.SHARE,
                onPressed: () {
                  _bottomSheetShare(backToMenu: false);
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _landscapeMenuButton(
      {String svgName, String text, void Function() onPressed}) {
    return RawMaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 8),
      onPressed: onPressed,
      child: _menuColumn(svgName: svgName, text: text),
    );
  }

  Future<void> _getLiverUserInfo() async {
    setState(() {
      _followRequesting = true;
    });
    final userModel = await _requestUserInfo(context, _liverId);
    setState(() {
      _followRequesting = false;
    });
    if (userModel != null) {
      setState(() {
        _liverUserModel = userModel;
      });
    }
  }

  Future<UserModel> _requestUserInfo(
      BuildContext context, String targetUserId) async {
    final service = BackendService(context);
    final response = await service.getUser(targetUserId);
    if (response == null || !response.result) return null;
    return UserModel.fromJson(response.getData());
  }

  Widget _followButton() {
    bool following = _following();
    return InkWell(
      onTap: _followRequesting
          ? null
          : () {
              _toggleFollow();
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
            color: following ? Colors.grey : Colors.orange,
            borderRadius: BorderRadius.circular(4)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              following ? Icons.remove : Icons.add,
              color: following ? Colors.black : Colors.white,
              size: 16,
            ),
            const SizedBox(width: 10),
            Text(
              Lang.FOLLOW,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              key: keyFollow,
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _toggleFollow() async {
    final service = BackendService(context);
    JsonData response;
    setState(() {
      _followRequesting = true;
    });
    bool following = _following();
    if (following) {
      response = await service.postUserFollow(unfollowId: _liverId);
    } else {
      response = await service.postUserFollow(followId: _liverId);
    }

    setState(() {
      _followRequesting = false;
    });
    if (response == null && !response.result) return false;
    setState(() {
      _liverUserModel.json['followed'] = !following;
    });
    return true;
  }

  Future<void> _bottomSheet() async {
    await showTransparentModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        double widthScr = MediaQuery.of(context).size.width;
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateView) {
          return IntrinsicHeight(
            child: Container(
              color: ColorLive.BLUE_BG,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RawMaterialButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: widthScr > 480
                                  ? widthScr * 0.053
                                  : widthScr * 0.045,
                              vertical: 20),
                          onPressed: _quitting
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  _bottomSheetInputChat(backToMenu: true);
                                },
                          child: _menuColumn(svgName: "chat", text: Lang.CHAT),
                        ),
                        RawMaterialButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: widthScr > 480
                                  ? widthScr * 0.053
                                  : widthScr * 0.045,
                              vertical: 20),
                          onPressed: _quitting
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  _bottomSheetProduct(backToMenu: true);
                                },
                          child: _menuColumn(
                              svgName: "card", text: Lang.PRODUCT_LIST),
                        ),
                        RawMaterialButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: widthScr > 480
                                  ? widthScr * 0.053
                                  : widthScr * 0.045,
                              vertical: 20),
                          onPressed: _quitting
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  _bottomSheetAudience(backToMenu: true);
                                },
                          child: _menuColumn(
                              svgName: "family", text: Lang.AUDIENCE),
                        ),
                        RawMaterialButton(
                          padding: EdgeInsets.fromLTRB(
                              widthScr > 480
                                  ? widthScr * 0.053
                                  : widthScr * 0.045,
                              20,
                              widthScr > 480
                                  ? widthScr * 0.053
                                  : widthScr * 0.045,
                              20),
                          onPressed: () {
                            switch (stateView) {
                              case 0:
                                setState(() {
                                  stateView = 1;
                                });
                                setStateView(() {
                                  stateView = 1;
                                });
                                break;
                              case 1:
                                setState(() {
                                  stateView = 2;
                                });
                                setStateView(() {
                                  stateView = 2;
                                });
                                break;
                              case 2:
                                setState(() {
                                  stateView = 3;
                                });
                                setStateView(() {
                                  stateView = 3;
                                });
                                break;
                              case 3:
                                setState(() {
                                  stateView = 0;
                                });
                                setStateView(() {
                                  stateView = 0;
                                });
                                break;
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Stack(alignment: Alignment.topLeft, children: [
                                SvgPicture.asset(
                                  "assets/svg/icon_0${stateView + 1}.svg",
                                  height: 25,
                                ),
                              ]),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                '⾮表⽰機能',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                        RawMaterialButton(
                          padding: EdgeInsets.symmetric(
                              horizontal: widthScr > 480
                                  ? widthScr * 0.053
                                  : widthScr * 0.045,
                              vertical: 20),
                          onPressed: _quitting
                              ? null
                              : () {
                                  String text =
                                      'LIVE812で${_liverUserModel.nickname}さんのライブ配信を視聴しよう♪';
                                  final info = ShareUtil.generateUserShareInfo(
                                      _liverUserModel,
                                      text: text);
                                  final url = info.item3;
                                  Share.share('$text\n$url');
                                  Navigator.of(context).pop();
                                },
                          child:
                              _menuColumn(svgName: "menu04", text: Lang.SHARE),
                        ),
                      ],
                    )),
              ),
            ),
          );
        });
      },
    );
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
        isLiver: false,
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

            if (_socket == null) {
              return;
            }

            final data = {
              'token': _token,
              'user_id': _userId,
              'live_id': _liveId,
              'nickname': userModel.nickname,
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

  Future<void> _bottomSheetGift(
      {bool Function(int, GiftInfoModel) onTap}) async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return BottomSheetGift(
            giftInfoList: _giftInfoList,
            onBack: () {
              Navigator.of(context).pop();
              KeyboardUtil.close(context);
              _bottomSheet();
            },
            onTap: (int animationIndex, GiftInfoModel giftInfo) {
              if (onTap(animationIndex, giftInfo)) Navigator.of(context).pop();
            },
          );
        });
  }

  bool _sendGift(int index, GiftInfoModel giftInfo, BuildContext context) {
    // ソケット通信の準備が終わっていない
    if (_socket == null) {
      return false;
    }

    // ポイントが足りるか？
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (giftInfo.point > userModel.point) {
      // TODO: エラー表示
      return false;
    }
    // ソケット通信
    final data = {
      "token": _token,
      "user_id": _userId,
      "live_id": _liveId,
      'gift_id': giftInfo.id,
      'nickname': userModel.nickname,
    };
    _socket.json.emit('gift', data);

    // ローカルで保持している、自分のポイントを引く
    setState(() {
      userModel.setPoint(userModel.point - giftInfo.point);
    });
    Navigator.of(context).pop();
    if (stateView == 3) {
      Flushbar(
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.blue[300],
        ),
        message: '${giftInfo.name}（${giftInfo.point}コイン）を贈りました❗',
        duration: const Duration(milliseconds: 2000),
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      )..show(context);
    }
    userModel.saveToStorage(); // TODO: 負荷対策
    return true;
  }

  Future<void> _bottomSheetProduct(
      {bool backToMenu = true, bool landscape = false}) async {
    final tuple = await _requestEcItem();
    final products = tuple.item1;
    final storeProfiles = tuple.item2;
    if (products == null) {
      // TODO: エラー表示
      return;
    }

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
                  padding: EdgeInsets.only(
                    left: mq.padding.left + 32,
                    right: mq.padding.right + 32,
                    top: max(mq.padding.top, 8),
                    bottom: max(mq.padding.bottom, 8),
                  ),
                  child: BottomSheetProductSwiper(
                    viewportFraction: 0.8,
                    products: products,
                    storeProfiles: storeProfiles,
                    provideUserId: _liverId,
                    isLiver: false,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: mq.padding.right,
                  width: 32,
                  height: 32,
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
          builder: (BuildContext context) {
            return BottomSheetProduct(
              products: products,
              storeProfiles: storeProfiles,
              provideUserId: _liverId,
              isLiver: false,
              onBack: () {
                Navigator.of(context).pop();
                KeyboardUtil.close(context);
                if (backToMenu) _bottomSheet();
              },
              onStartPurchase: (product) {
                _showPurchaseDialog(_liverId, product);
              },
            );
          });
    }
  }

  // 商品購入ダイアログ表示
  Future<void> _showPurchaseDialog(
      String provideUserId, Product product) async {
    final result = await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: null,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (BuildContext context, _a1, _a2) => BuyProductDialog(
        product: product,
        provideUserId: provideUserId,
        isInLiveRoom: true,
      ),
    );

    if (result == BuyProductDialogResult.PURCHASED ||
        result == BuyProductDialogResult.PURCHASED_AND_GOTO_HISTORY_PAGE) {
      // なにか購入したので、購入バッジを有効にする
      final badgeInfo = Provider.of<BadgeInfo>(context, listen: false);
      badgeInfo.purchase = true;
    }

    switch (result) {
      case BuyProductDialogResult.PURCHASED:
        break;
      case BuyProductDialogResult.PURCHASED_AND_GOTO_HISTORY_PAGE:
        Navigator.of(context).push(FadeRoute(
            builder: (context) => HistoryPurchasePage(
                  isTrading: true,
                )));
        break;
      default:
        break;
    }
  }

  Future<Tuple2<List<Product>, List<StoreProfile>>> _requestEcItem() async {
    final service = BackendService(context);
    final response = await service.getEcItem(_liverId);
    if (response != null && response.result) {
      var list = List<Product>();
      for (final data in response.getData()) {
        list.add(Product.fromJson(data));
      }
      // 専用商品でソート.
      list = list
          .orderByDescending((x) => x.isPublished ? 1 : 0)
          .thenByDescending((x) => x.customerUserId != null ? 1 : 0)
          .thenByDescending((x) => x.createDate)
          .toList();

      List<StoreProfile> storeProfiles = [];
      if ((response.containsKey('store_data') &&
          (response.getByKey('store_data') != null))) {
        final list = response.getByKey('store_data') as List;
        storeProfiles = list.map((x) => StoreProfile.fromJson(x)).toList();
      }
      return Tuple2(list, storeProfiles);
    }
    return Tuple2(null, null);
  }

  Future<void> _bottomSheetAudience({bool backToMenu = true}) async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return BottomSheetAudience(
            liveId: _liveId,
            onBack: () {
              Navigator.of(context).pop();
              KeyboardUtil.close(context);
              if (backToMenu) _bottomSheet();
            },
          );
        });
  }

  Future<void> _bottomSheetShare({bool backToMenu = true}) async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return BottomSheetShare(
            liveId: _liveId,
            liverUserModel: _liverUserModel,
            onBack: () {
              Navigator.of(context).pop();
              KeyboardUtil.close(context);
              if (backToMenu) _bottomSheet();
            },
          );
        });
  }

  Widget _menuColumn({svgName, text, callFunc: 1}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
          "assets/svg/$svgName.svg",
          height: 32,
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        )
      ],
    );
  }

  Future<void> _viewDistributorDetails() {
    return showDialog(
      context: context,
      builder: (BuildContext context) =>
          DistributorDetailsDialog(_liverUserModel),
    );
  }
}

/// 配信終了表示.
class _DisconnectLiveViewContent extends StatelessWidget {
  final String msg;

  _DisconnectLiveViewContent({this.msg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(
                    msg ?? '配信が終了しました',
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
                        Navigator.of(context).popUntil(
                            (route) => route.settings.name == '/bottom_nav');
                      },
                      child: const Text(
                        Lang.CLOSE_CC,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
