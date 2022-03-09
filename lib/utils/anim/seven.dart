import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class SevenAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  SevenAnimation({this.onEndCallback});

  @override
  _SevenAnimationState createState() => _SevenAnimationState();
}

class _SevenAnimationState extends State<SevenAnimation> {
  NodeWithSize rootNode;

  static const SIZE = 1024.0;

  @override
  void initState() {
    super.initState();
    rootNode = NodeWithSize(const Size(SIZE, SIZE));
  }

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load(['assets/anim/17@2x.png']),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<ui.Image> assets = snapshot.data;
          final Sprite seven = Sprite.fromImage(assets[0]);
          seven.position = Offset(SIZE / 2, SIZE);
          seven.pivot = Offset(0.5, 1.0);
          seven.scale = 0.8;
          rootNode.addChild(seven);

          final rotate1 = MotionTween<double>(
                (a) => seven.rotation = a,
            0,
            15.0,
            2.0,
            Curves.easeInOut,
          );

          final rotate2 = MotionTween<double>(
                (a) => seven.rotation = a,
            15.0,
            -15.0,
            4.0,
            Curves.easeInOut,
          );

          final rotate3 = MotionTween<double>(
                (a) => seven.rotation = a,
            -15.0,
            0,
            2.0,
            Curves.easeInOut,
          );

          final fadeOut = MotionTween<double>(
                (a) => seven.opacity = a,
            1.0,
            0.0,
            2.0,
            Curves.easeOut,
          );

          final sequence = MotionSequence([rotate1, rotate2, rotate3, fadeOut,
          ]);

          Motion motion = sequence;
          if (widget.onEndCallback != null) {
            motion = MotionSequence([
              motion,
              MotionCallFunction(widget.onEndCallback),
            ]);
          }

          seven.motions.run(motion);

          return Container(
            child: Center(
              child: SpriteWidget(rootNode),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
