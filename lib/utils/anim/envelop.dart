import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class EnvelopAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  EnvelopAnimation(this.onEndCallback);

  @override
  _EnvelopAnimationState createState() => _EnvelopAnimationState();
}

class _EnvelopAnimationState extends State<EnvelopAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load(['assets/anim/11@2x.png']),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final Sprite envelop = Sprite.fromImage(assets[0]);
          envelop.position = Offset(SIZE / 2, SIZE);
          envelop.pivot = Offset(0.5, 1.0);
          envelop.scale = 0.2;
          _rootNode.addChild(envelop);

          final scale = motionScale(envelop, 0.2, 1.0, 0.75, Curves.easeOut);

          envelop.motions.run(MotionSequence([
            scale,
            MotionDelay(1.85),
            motionFadeOut(envelop, 1.0, Curves.easeInQuint),
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
