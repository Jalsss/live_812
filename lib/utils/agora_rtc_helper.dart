import 'package:agora_rtc_engine/rtc_engine.dart';

class AgoraRtcHelper {
  AgoraRtcHelper._();

  static VideoOutputOrientationMode orientationMode(bool isPortrait) {
    if (isPortrait) {
      return VideoOutputOrientationMode.FixedPortrait;
    } else {
      return VideoOutputOrientationMode.FixedLandscape;
    }
  }

  static VideoDimensions dimensions(int width, int height) {
    return VideoDimensions(width, height);
  }

  static VideoFrameRate frameRate(int frameRate) {
    if (frameRate < 7) {
      return VideoFrameRate.Fps1;
    } else if ((7 <= frameRate) && (frameRate < 10)) {
      return VideoFrameRate.Fps7;
    } else if ((10 <= frameRate) && (frameRate < 15)) {
      return VideoFrameRate.Fps10;
    } else if ((15 <= frameRate) && (frameRate < 24)) {
      return VideoFrameRate.Fps15;
    } else if ((24 <= frameRate) && (frameRate < 30)) {
      return VideoFrameRate.Fps24;
    } else if ((30 <= frameRate) && (frameRate < 60)) {
      return VideoFrameRate.Fps30;
    } else {
      return VideoFrameRate.Fps60;
    }
  }
}
