import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class GreetingAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  GreetingAnimation(this.onEndCallback);

  @override
  _GreetingAnimationState createState() => _GreetingAnimationState();
}

class _GreetingAnimationState extends State<GreetingAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load([
        'assets/anim/02a.png',
        'assets/anim/02b.png',
        'assets/anim/02c.png',
        'assets/anim/02popup@2x.png'
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
        return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final Sprite greeting1 = Sprite.fromImage(assets[0]);
          final Sprite greeting2 = Sprite.fromImage(assets[1]);
          final Sprite greeting3 = Sprite.fromImage(assets[2]);
          final Sprite popup = Sprite.fromImage(assets[3]);
          greeting1.position = const Offset(SIZE / 2, SIZE / 2);
          greeting2.position = const Offset(SIZE / 2, SIZE / 2);
          greeting3.position = const Offset(SIZE / 2, SIZE / 2);
          popup.position = const Offset(SIZE / 8, SIZE / 2);
          greeting1.opacity = 0.0;
          greeting2.opacity = 0.0;
          greeting3.opacity = 0.0;
          popup.opacity = 0.0;
          _rootNode.addChild(greeting1);
          _rootNode.addChild(greeting2);
          _rootNode.addChild(greeting3);
          _rootNode.addChild(popup);

          final fadeIn = motionFadeIn(popup, 0.5, Curves.linearToEaseOut);

          final sequence = MotionSequence([
            MotionCallFunction(() => greeting1.opacity = 1.0),
            MotionDelay(1.0),
            MotionCallFunction(() {
              greeting1.opacity = 0.0;
              greeting2.opacity = 1.0;
            }),
            MotionDelay(0.4),
            MotionCallFunction(() {
              greeting2.opacity = 0.0;
              greeting3.opacity = 1.0;
            }),
            MotionDelay(0.6),
            MotionCallFunction(() {
              greeting2.opacity = 1.0;
              greeting3.opacity = 0.0;
            }),
            MotionDelay(0.2),
            MotionCallFunction(() {
              greeting1.opacity = 1.0;
              greeting2.opacity = 0.0;
            }),
            MotionDelay(0.6),
            MotionCallFunction(() {
              greeting1.opacity = 0.0;
              greeting2.opacity = 1.0;
            }),
            MotionDelay(0.4),
            MotionCallFunction(() {
              greeting2.opacity = 0.0;
              greeting3.opacity = 1.0;
            }),
            MotionGroup([
              motionFadeOut(greeting3, 4, Curves.easeInQuint),
              motionFadeOut(popup, 4, Curves.easeInQuint),
            ]),
          ]);

          popup.motions.run(MotionSequence([
            MotionGroup([fadeIn, sequence]),
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
