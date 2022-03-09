import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class SushiAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  SushiAnimation(this.onEndCallback);

  @override
  _SushiAnimationState createState() => _SushiAnimationState();
}

class _SushiAnimationState extends State<SushiAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load([
        'assets/anim/07a@2x.png',
        'assets/anim/07b@2x.png',
        'assets/anim/07c@2x.png',
        'assets/anim/07popup@2x.png'
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final Sprite sushi1 = Sprite.fromImage(assets[0]);
          sushi1.position = Offset(SIZE * 2, SIZE / 2);
          sushi1.zPosition = 4.0;
          final Sprite sushi2 = Sprite.fromImage(assets[1]);
          sushi2.position = Offset(SIZE * 2, SIZE / 2);
          sushi2.zPosition = 3.0;
          final Sprite sushi3 = Sprite.fromImage(assets[2]);
          sushi3.position = Offset(SIZE * 2, SIZE / 2);
          sushi3.zPosition = 2.0;
          final Sprite popup = Sprite.fromImage(assets[3]);
          popup.position = Offset(SIZE / 2, SIZE / 4);
          popup.zPosition = 1.0;
          popup.opacity = 0.0;
          _rootNode.addChild(sushi1);
          _rootNode.addChild(sushi2);
          _rootNode.addChild(sushi3);
          _rootNode.addChild(popup);

          final move1 = motionPosition(sushi1, Offset(SIZE * 2, SIZE / 2), Offset(SIZE / 6, SIZE / 2), 0.5, Curves.linearToEaseOut);
          final move2 = motionPosition(sushi2, Offset(SIZE * 2, SIZE / 2), Offset(SIZE * 3 / 5, SIZE / 2), 0.5, Curves.linearToEaseOut);
          final move3 = motionPosition(sushi3, Offset(SIZE * 2, SIZE / 2), Offset(SIZE * 4 / 5, SIZE / 2), 0.5, Curves.linearToEaseOut);
          final fadeIn = motionFadeIn(popup, 0.5, Curves.easeInOut);
          final fadeOut = MotionGroup([
            motionFadeOut(sushi1, 5.0, Curves.easeInQuint),
            motionFadeOut(sushi2, 5.0, Curves.easeInQuint),
            motionFadeOut(sushi3, 5.0, Curves.easeInQuint),
            motionFadeOut(popup, 5.0, Curves.easeInQuint),
          ]);

          popup.motions.run(MotionSequence([
            MotionSequence([
              move1,
              move2,
              move3,
              fadeIn,
              fadeOut,
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
