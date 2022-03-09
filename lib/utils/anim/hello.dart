import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class HelloAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  HelloAnimation(this.onEndCallback);

  @override
  _HelloAnimationState createState() => _HelloAnimationState();
}

class _HelloAnimationState extends State<HelloAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load([
        'assets/anim/03a.png',
        'assets/anim/03b.png',
        'assets/anim/03c.png',
        'assets/anim/03d.png',
        'assets/anim/03e.png',
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final Sprite hello1 = Sprite.fromImage(assets[0]);
          final Sprite hello2 = Sprite.fromImage(assets[1]);
          final Sprite hello3 = Sprite.fromImage(assets[2]);
          final Sprite hello4 = Sprite.fromImage(assets[3]);
          final Sprite hello5 = Sprite.fromImage(assets[4]);
          hello1.opacity = 0;
          hello2.opacity = 0;
          hello3.opacity = 0;
          hello4.opacity = 0;
          hello5.opacity = 0;
          hello1.position = const Offset(SIZE * 3 / 16, SIZE / 3);
          hello2.position = const Offset(SIZE * 3 / 8, SIZE / 3);
          hello3.position = const Offset(SIZE * 4 / 8, SIZE / 3);
          hello4.position = const Offset(SIZE * 5 / 8, SIZE / 3);
          hello5.position = const Offset(SIZE * 6 / 8, SIZE / 3);
          _rootNode.addChild(hello1);
          _rootNode.addChild(hello2);
          _rootNode.addChild(hello3);
          _rootNode.addChild(hello4);
          _rootNode.addChild(hello5);

          final sequence = MotionSequence([
            MotionGroup([
              MotionGroup([
                motionFadeIn(hello1, 0.4, Curves.linearToEaseOut),
                motionFadeIn(hello2, 0.4, Curves.linearToEaseOut),
                motionFadeIn(hello3, 0.4, Curves.linearToEaseOut),
                motionFadeIn(hello4, 0.4, Curves.linearToEaseOut),
                motionFadeIn(hello5, 0.4, Curves.linearToEaseOut),
              ]),
              MotionTween<double>(
                  (a) => hello1.position = Offset(SIZE * 3 / 16, a), SIZE / 3, SIZE / 2, 1.8, Curves.bounceOut),
              MotionSequence([
                MotionDelay(0.1),
                MotionTween<double>(
                    (a) => hello2.position = Offset(SIZE * 3 / 8, a), SIZE / 3, SIZE / 2, 1.8, Curves.bounceOut),
              ]),
              MotionSequence([
                MotionDelay(0.2),
                MotionTween<double>(
                    (a) => hello3.position = Offset(SIZE * 4 / 8, a), SIZE / 3, SIZE / 2, 1.8, Curves.bounceOut),
              ]),
              MotionSequence([
                MotionDelay(0.3),
                MotionTween<double>(
                    (a) => hello4.position = Offset(SIZE * 5 / 8, a), SIZE / 3, SIZE / 2, 1.8, Curves.bounceOut),
              ]),
              MotionSequence([
                MotionDelay(0.4),
                MotionTween<double>(
                    (a) => hello5.position = Offset(SIZE * 6 / 8, a), SIZE / 3, SIZE / 2, 1.8, Curves.bounceOut),
              ]),
            ]),
            MotionGroup([
              motionFadeOut(hello1, 3.2, Curves.easeInQuint),
              motionFadeOut(hello2, 3.2, Curves.easeInQuint),
              motionFadeOut(hello3, 3.2, Curves.easeInQuint),
              motionFadeOut(hello4, 3.2, Curves.easeInQuint),
              motionFadeOut(hello5, 3.2, Curves.easeInQuint),
            ]),
          ]);

          hello1.motions.run(MotionSequence([
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
