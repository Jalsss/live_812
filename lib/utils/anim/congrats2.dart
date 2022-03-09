import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class Congrats2Animation extends StatefulWidget {
  final void Function() onEndCallback;

  Congrats2Animation(this.onEndCallback);

  @override
  _Congrats2AnimationState createState() => _Congrats2AnimationState();
}

class _Congrats2AnimationState extends State<Congrats2Animation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load(['assets/anim/09@2x.png']),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final Sprite cream = Sprite.fromImage(assets[0]);
          cream.position = Offset(SIZE / 2, SIZE);
          cream.pivot = Offset(0.5, 1.0);
          cream.scale = 0.7;
          _rootNode.addChild(cream);

          final scale = motionScale(cream, 0.7, 1.0, 0.75, Curves.easeOut);

          cream.motions.run(MotionSequence([
            scale,
            MotionDelay(3.25),
            motionFadeOut(cream, 1.0, Curves.easeInQuint),
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
