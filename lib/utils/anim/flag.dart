import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class FlagAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  FlagAnimation(this.onEndCallback);

  @override
  _FlagAnimationState createState() => _FlagAnimationState();
}

class _FlagAnimationState extends State<FlagAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load(['assets/anim/08@2x.png']),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final Sprite flag = Sprite.fromImage(assets[0]);
          flag.position = const Offset(SIZE / 8, SIZE / 8);
          flag.pivot = const Offset(0.0, 0.0);
          _rootNode.addChild(flag);

          final skew1 = MotionTween<double>(
              (a) => flag.skewX = a,
              0.0, -30.0, 0.6, Curves.easeOut,
          );

          final skew2 = MotionTween<double>(
              (a) => flag.skewX = a,
              -30.0, 0.0, 1.0, Curves.easeInOut,
          );

          final sequence = MotionSequence([skew1, skew2]);

          final fadeOut = motionFadeOut(flag, 3.6, Curves.easeInQuint);

          flag.motions.run(MotionSequence([
            MotionGroup([sequence, fadeOut]),
            MotionCallFunction(widget.onEndCallback),
          ]));
        }

        return Container(
          child: Center(
            child: SpriteWidget(_rootNode),
          ),
        );
      },
    );
  }
}
