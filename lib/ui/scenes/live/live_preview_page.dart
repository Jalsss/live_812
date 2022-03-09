import 'dart:async';
import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_indicator/home_indicator.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/usecase/beautification_usecase.dart';
import 'package:live812/ui/scenes/live/widget/live_close_button.dart';
import 'package:live812/ui/scenes/live/widget/show_beauty_bottom_sheet.dart';
import 'package:live812/utils/agora_rtc_faceunity.dart';
import 'package:live812/utils/agora_rtc_helper.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:provider/provider.dart';
import 'package:screen/screen.dart';

class LivePreviewPage extends StatefulWidget {
  const LivePreviewPage();

  @override
  _LivePreviewPageState createState() => _LivePreviewPageState();
}

class _LivePreviewPageState extends State<LivePreviewPage> {
  RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    HomeIndicator.hide();
    Screen.keepOn(true);
    initAgora();
  }

  @override
  void dispose() async {
    super.dispose();

    Screen.keepOn(false);
    await AgoraRtcFaceUnity.unregisterAudioFrameObserver();
    await AgoraRtcFaceUnity.unregisterVideoFrameObserver();
    await _engine?.stopPreview();
    await _engine?.destroy();

    HomeIndicator.show();
  }

  /// Agoraの初期化.
  Future initAgora() async {
    _engine = await RtcEngine.create(Consts.AGORA_APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
    await _engine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    final userModel = Provider.of<UserModel>(context, listen: false);
    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.dimensions =
        AgoraRtcHelper.dimensions(userModel.liveWidth, userModel.liveHeight);
    config.orientationMode = AgoraRtcHelper.orientationMode(true);
    config.frameRate = AgoraRtcHelper.frameRate(userModel.liveFrameRate);
    config.bitrate = userModel.liveBitrate;
    _engine.setVideoEncoderConfiguration(config);

    final eventHandler = RtcEngineEventHandler();
    eventHandler.firstLocalVideoFrame = (width, height, elapsed) {
      // 美顔機能.
      initBeautification();
    };
    _engine.setEventHandler(eventHandler);

    await AgoraRtcFaceUnity.registerAudioFrameObserver(
        await _engine.getNativeHandle());
    await AgoraRtcFaceUnity.registerVideoFrameObserver(
        await _engine.getNativeHandle());

    await _engine.startPreview();

    setState(() {});
  }

  Future initBeautification() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            child: RtcLocalView.SurfaceView(),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 5,
                  right: 20,
                  child: LiveCloseButton(
                    text: '戻る',
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: SvgPicture.asset(
          'assets/svg/menu/face.svg',
          color: Colors.white,
        ),
        backgroundColor: ColorLive.MAIN_BG,
        onPressed: () async {
          await showBeautyBottomSheet(
            context: context,
          );
        },
      ),
    );
  }
}
