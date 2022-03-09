import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class SweetsAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  SweetsAnimation(this.onEndCallback);

  @override
  _SweetsAnimationState createState() => _SweetsAnimationState();
}

class _SweetsAnimationState extends State<SweetsAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load(['assets/anim/06@2x.png']),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final Sprite sweets = Sprite.fromImage(assets[0]);
          sweets.position = Offset(SIZE / 2, SIZE / 2);
          sweets.opacity = 0.0;
          _rootNode.addChild(sweets);

          sweets.motions.run(MotionSequence([
            MotionSequence([
              motionFadeIn(sweets, 0.5, Curves.easeInOut),
              MotionDelay(2.0),
              motionFadeOut(sweets, 3.0, Curves.easeInQuint),
            ]),
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
