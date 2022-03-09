import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:spritewidget/spritewidget.dart';

MotionInterval motionFade(Sprite sprite, double from, double to, double duration, [Curve curve]) {
  return MotionTween<double>(
      (a) => sprite.opacity = a,
      from, to, duration, curve);
}

MotionInterval motionFadeIn(Sprite sprite, double duration, [Curve curve]) {
  return motionFade(sprite, 0, 1, duration, curve);
}

MotionInterval motionFadeOut(Sprite sprite, double duration, [Curve curve]) {
  return motionFade(sprite, 1, 0, duration, curve);
}

MotionInterval motionScale(Sprite sprite, double from, double to, double duration, [Curve curve = Curves.ease]) {
  return MotionTween<double>(
      (s) => sprite.scale = s,
      from, to, duration, curve);
}

MotionInterval motionRotation(Sprite sprite, double from, double to, double duration, [Curve curve = Curves.ease]) {
  return MotionTween<double>(
      (angle) => sprite.rotation = angle,
      from, to, duration, curve);
}

MotionInterval motionPosition(Sprite sprite, Offset from, Offset to, double duration, [Curve curve = Curves.ease]) {
  return MotionTween<Offset>(
      (pos) => sprite.position = pos,
      from, to, duration, curve);
}
