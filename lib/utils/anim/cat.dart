import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class CatAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  CatAnimation(this.onEndCallback);

  @override
  _CatAnimationState createState() => _CatAnimationState();
}

class _CatAnimationState extends State<CatAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load([
        'assets/anim/05a@2x.png',
        'assets/anim/05b@2x.png',
        'assets/anim/05c@2x.png',
        'assets/anim/05popup@2x.png',
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final cat1 = Sprite.fromImage(assets[0]);
          final cat2 = Sprite.fromImage(assets[1]);
          final cat3 = Sprite.fromImage(assets[2]);
          cat1.position = const Offset(SIZE / 2, SIZE / 2);
          cat2.position = const Offset(SIZE / 2, SIZE / 2);
          cat3.position = const Offset(SIZE / 2, SIZE / 2);
          cat2.opacity = 0;
          cat3.opacity = 0;
          _rootNode.addChild(cat1);
          _rootNode.addChild(cat2);
          _rootNode.addChild(cat3);

          final popup = Sprite.fromImage(assets[3]);
          popup.position = const Offset(SIZE / 2, SIZE);
          popup.zPosition = 2.0;
          _rootNode.addChild(popup);

          final fadeOut1 = motionFadeOut(cat3, 3.6, Curves.easeInQuint);
          final fadeOut2 = motionFadeOut(popup, 3.6, Curves.easeInQuint);

          final sequence = MotionSequence([
            MotionDelay(1.0),
            MotionCallFunction(() {
              cat1.opacity = 0;
              cat2.opacity = 1;
            }),
            MotionDelay(0.3),
            MotionCallFunction(() {
              cat2.opacity = 0;
              cat3.opacity = 1;
            }),
            MotionDelay(0.3),
            MotionCallFunction(() {
              cat3.opacity = 0;
              cat2.opacity = 1;
            }),
            MotionDelay(0.3),
            MotionCallFunction(() {
              cat2.opacity = 0;
              cat1.opacity = 1;
            }),
            MotionDelay(0.3),
            MotionCallFunction(() {
              cat1.opacity = 0;
              cat2.opacity = 1;
            }),
            MotionDelay(0.3),
            MotionCallFunction(() {
              cat2.opacity = 0;
              cat3.opacity = 1;
            }),
            MotionGroup([fadeOut1, fadeOut2]),
          ]);

          cat1.motions.run(MotionSequence([
            sequence,
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
