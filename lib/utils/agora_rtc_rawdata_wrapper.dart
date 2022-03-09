import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class AgoraRtcRawDataWrapper {
  static const MethodChannel _channel =
  const MethodChannel('agora_rtc_rawdata');

  static Future<void> registerAudioFrameObserver(int engineHandle) {
    return _channel.invokeMethod('registerAudioFrameObserver', engineHandle);
  }

  static Future<void> unregisterAudioFrameObserver() {
    return _channel.invokeMethod('unregisterAudioFrameObserver');
  }

  static Future<void> registerVideoFrameObserver(int engineHandle) {
    return _channel.invokeMethod('registerVideoFrameObserver', engineHandle);
  }

  static Future<void> unregisterVideoFrameObserver() {
    return _channel.invokeMethod('unregisterVideoFrameObserver');
  }

  static Future<void> enableFaceBeautification() {
    return _channel.invokeMethod('enableFaceBeautification');
  }

  static Future<void> disableFaceBeautification() {
    return _channel.invokeMethod('disableFaceBeautification');
  }

  static Future<void> setFaceBeautificationFilter({
    String filterName,
    double filterLevel,
  }) {
    if (filterName.isEmpty) {
      return null;
    }
    final arguments = <String, dynamic>{
      'filter_name': filterName,
      'filter_level': math.max(math.min(filterLevel, 1.0), 0.0),
    };
    return _channel.invokeMethod('setFaceBeautificationFilter', arguments);
  }

  static Future<void> setFaceBeautificationSkinWhitening({
    double colorLevel,
  }) {
    final arguments = <String, dynamic>{
      'color_level': math.max(math.min(colorLevel, 1.0), 0.0),
    };
    return _channel.invokeMethod(
        'setFaceBeautificationSkinWhitening', arguments);
  }

  static Future<void> setFaceBeautificationRuddy({
    double redLevel,
  }) {
    final arguments = <String, dynamic>{
      'red_level': math.max(math.min(redLevel, 1.0), 0.0),
    };
    return _channel.invokeMethod('setFaceBeautificationRuddy', arguments);
  }

  static Future<void> setFaceBeautificationBlur({
    double blurLevel,
    bool skinDetect,
    double nonskinBlurScale,
    bool heavyBlur,
    double blurBlendRatio,
  }) {
    final arguments = <String, dynamic>{
      'blur_level': math.max(math.min(blurLevel, 6.0), 0.0),
      'skin_detect': skinDetect ? 1 : 0,
      'nonskin_blur_scale': math.max(math.min(nonskinBlurScale, 1.0), 0.0),
      'heavy_blur': heavyBlur ? 1 : 0,
      'blur_blend_ratio': math.max(math.min(blurBlendRatio, 1.0), 0.0),
    };
    return _channel.invokeMethod('setFaceBeautificationBlur', arguments);
  }

  static Future<void> setFaceBeautificationEyeBrighten({
    double eyeBright,
  }) {
    final arguments = <String, dynamic>{
      'eye_bright': math.max(math.min(eyeBright, 1.0), 0.0),
    };
    return _channel.invokeMethod('setFaceBeautificationEyeBrighten', arguments);
  }

  static Future<void> setFaceBeautificationToothWhiten({
    double toothWhiten,
  }) {
    final arguments = <String, dynamic>{
      'tooth_whiten': math.max(math.min(toothWhiten, 1.0), 0.0),
    };
    return _channel.invokeMethod('setFaceBeautificationToothWhiten', arguments);
  }

  static Future<void> setFaceBeautificationFaceOutline({
    int faceShape,
    double faceShapeLevel,
    double eyeEnlarging,
    double cheekThinning,
    double intensityForehead,
    double intensityChin,
    double intensityNose,
    double intensityMouth,
  }) {
    final arguments = <String, dynamic>{
      'face_shape': math.max(math.min(faceShape, 4), 0),
      'face_shape_level': math.max(math.min(faceShapeLevel, 1.0), 0.0),
      'eye_enlarging': math.max(math.min(eyeEnlarging, 1.0), 0.0),
      'cheek_thinning': math.max(math.min(cheekThinning, 1.0), 0.0),
      'intensity_forehead': math.max(math.min(intensityForehead, 1.0), 0.0),
      'intensity_chin': math.max(math.min(intensityChin, 1.0), 0.0),
      'intensity_nose': math.max(math.min(intensityNose, 1.0), 0.0),
      'intensity_mouth': math.max(math.min(intensityMouth, 1.0), 0.0),
    };
    return _channel.invokeMethod('setFaceBeautificationFaceOutline', arguments);
  }
}
