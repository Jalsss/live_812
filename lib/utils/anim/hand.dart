import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class HandAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  HandAnimation(this.onEndCallback);

  @override
  _HandAnimationState createState() => _HandAnimationState();
}

class _HandAnimationState extends State<HandAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load(['assets/anim/01a@2x.png', 'assets/anim/01b@2x.png']),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final Sprite hand = Sprite.fromImage(assets[0]);
          hand.position = const Offset(SIZE / 2, SIZE / 2);
          hand.pivot = const Offset(0.5, 1.0);
          _rootNode.addChild(hand);

          final Sprite shout = Sprite.fromImage(assets[1]);
          shout.position = const Offset(SIZE / 2, 0);
          shout.scale = 0.2;
          _rootNode.addChild(shout);
          final zoomIn = motionScale(shout, 0.2, 1.0, 0.8, Curves.ease);

          final fadeOut1 = motionFadeOut(hand, 1.4, Curves.easeInQuint);
          final fadeOut2 = motionFadeOut(shout, 1.4, Curves.easeInQuint);

          final rotate = MotionSequence([
            motionRotation(hand, 0, 15, 0.6, Curves.easeInOut),
            motionRotation(hand, 15, -15, 1.0, Curves.easeInOut),
            motionRotation(hand, -15, 0, 0.6, Curves.easeInOut),
          ]);

          shout.motions.run(MotionSequence([
            MotionGroup([rotate, zoomIn]),
            MotionGroup([fadeOut1, fadeOut2]),
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
