import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live812/domain/model/live/beautification.dart';
import 'package:live812/utils/agora_rtc_rawdata_wrapper.dart';

class AgoraRtcFaceUnity {
  static Future<void> registerAudioFrameObserver(int engineHandle) {
    return AgoraRtcRawDataWrapper.registerAudioFrameObserver(engineHandle);
  }

  static Future<void> unregisterAudioFrameObserver() {
    return AgoraRtcRawDataWrapper.unregisterAudioFrameObserver();
  }

  static Future<void> registerVideoFrameObserver(int engineHandle) {
    return AgoraRtcRawDataWrapper.registerVideoFrameObserver(engineHandle);
  }

  static Future<void> unregisterVideoFrameObserver() {
    return AgoraRtcRawDataWrapper.unregisterVideoFrameObserver();
  }

  static Future<void> initializeFaceBeautification({
    @required Beautification beautification,
  }) async {
    await setFaceBeautificationSkinWhitening(
      colorLevel: beautification.colorLevel.toDouble(),
    );
    await setFaceBeautificationRuddy(
      redLevel: beautification.redLevel.toDouble(),
    );
    await setFaceBeautificationBlur(
      blurLevel: beautification.blurLevel.toDouble(),
    );
    await setFaceBeautificationToothWhiten(
      toothWhiten: beautification.toothWhiten.toDouble(),
    );
    await setFaceBeautificationFaceOutline(
      eyeEnlarging: beautification.eyeEnlarging.toDouble(),
      cheekThinning: beautification.cheekThinning.toDouble(),
      intensityForehead: beautification.intensityForehead.toDouble(),
      intensityChin: beautification.intensityChin.toDouble(),
      intensityNose: beautification.intensityNose.toDouble(),
      intensityMouth: beautification.intensityMouth.toDouble(),
    );
    await setFaceBeautificationFilter(
      filterName: BeautificationFilter.name(beautification.filterType()),
      filterLevel: beautification.filterLevel().toDouble(),
    );
  }

  static Future<void> enableFaceBeautification() {
    return AgoraRtcRawDataWrapper.enableFaceBeautification();
  }

  static Future<void> disableFaceBeautification() {
    return AgoraRtcRawDataWrapper.disableFaceBeautification();
  }

  static Future<void> setFaceBeautificationFilter({
    String filterName,
    double filterLevel,
  }) {
    return AgoraRtcRawDataWrapper.setFaceBeautificationFilter(
      filterName: filterName,
      filterLevel: filterLevel / 100,
    );
  }

  static Future<void> setFaceBeautificationSkinWhitening({
    double colorLevel,
  }) {
    return AgoraRtcRawDataWrapper.setFaceBeautificationSkinWhitening(
      colorLevel: colorLevel / 100,
    );
  }

  static Future<void> setFaceBeautificationRuddy({
    double redLevel,
  }) {
    return AgoraRtcRawDataWrapper.setFaceBeautificationRuddy(
      redLevel: redLevel / 100,
    );
  }

  static Future<void> setFaceBeautificationBlur({
    double blurLevel,
  }) {
    return AgoraRtcRawDataWrapper.setFaceBeautificationBlur(
      blurLevel: (6 * blurLevel) / 100,
      skinDetect: true,
      nonskinBlurScale: 0,
      heavyBlur: true,
      blurBlendRatio: 100,
    );
  }

  static Future<void> setFaceBeautificationEyeBrighten({
    double eyeBright,
  }) {
    return AgoraRtcRawDataWrapper.setFaceBeautificationEyeBrighten(
      eyeBright: eyeBright / 100,
    );
  }

  static Future<void> setFaceBeautificationToothWhiten({
    double toothWhiten,
  }) {
    return AgoraRtcRawDataWrapper.setFaceBeautificationToothWhiten(
      toothWhiten: toothWhiten / 100,
    );
  }

  static Future<void> setFaceBeautificationFaceOutline({
    double eyeEnlarging,
    double cheekThinning,
    double intensityForehead,
    double intensityChin,
    double intensityNose,
    double intensityMouth,
  }) {
    return AgoraRtcRawDataWrapper.setFaceBeautificationFaceOutline(
      faceShape: 4,
      faceShapeLevel: 1.0,
      eyeEnlarging: eyeEnlarging / 100,
      cheekThinning: cheekThinning / 100,
      intensityForehead: (intensityForehead + 50.0) / 100,
      intensityChin: (intensityChin + 50.0) / 100,
      intensityNose: (intensityNose + 50.0) / 100,
      intensityMouth: -(intensityMouth - 50.0) / 100,
    );
  }
}
