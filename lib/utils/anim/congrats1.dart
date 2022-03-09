import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class Congrats1Animation extends StatefulWidget {
  final void Function() onEndCallback;

  Congrats1Animation(this.onEndCallback);

  @override
  _Congrats1AnimationState createState() => _Congrats1AnimationState();
}

class _Congrats1AnimationState extends State<Congrats1Animation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load([
        'assets/anim/04popup.png',
        'assets/anim/square.png',
        'assets/anim/04a@2x.png',
        'assets/anim/04b@2x.png',
        'assets/anim/04c@2x.png',
        'assets/anim/04d@2x.png',
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final popup = Sprite.fromImage(assets[0]);
          popup.position = const Offset(SIZE / 2, SIZE);
          popup.zPosition = 4.0;
          popup.opacity = 0;
          popup.scale = 1.6;
          _rootNode.addChild(popup);

          final corn = Sprite.fromImage(assets[2]);
          corn.position = const Offset(SIZE / 8, SIZE / 2);
          corn.zPosition = 3.0;
          corn.opacity = 0;
          _rootNode.addChild(corn);

          final tape1 = Sprite.fromImage(assets[3]);
          final tape2 = Sprite.fromImage(assets[4]);
          final tape3 = Sprite.fromImage(assets[5]);
          tape1.zPosition = 2.0;
          tape2.zPosition = 2.0;
          tape3.zPosition = 2.0;
          tape1.position = const Offset(SIZE / 2, SIZE / 4);
          tape2.position = const Offset(SIZE / 3, SIZE / 12);
          tape3.position = const Offset(SIZE / 1.6, SIZE / 2.2);

          final fadeIn1 = motionFadeIn(popup, 0.5, Curves.linearToEaseOut);
          final fadeIn2 = motionFadeIn(corn, 0.5, Curves.linearToEaseOut);

          final fadeOut1 = motionFadeOut(popup, 5.0, Curves.easeInQuint);
          final fadeOut2 = motionFadeOut(corn, 5.0, Curves.easeInQuint);
          final fadeOut3 = motionFadeOut(tape1, 5.0, Curves.easeInQuint);
          final fadeOut4 = motionFadeOut(tape2, 5.0, Curves.easeInQuint);
          final fadeOut5 = motionFadeOut(tape3, 5.0, Curves.easeInQuint);

          Motion motion = MotionSequence([
            MotionGroup([fadeIn1, fadeIn2]),
            MotionCallFunction(() {
              _rootNode.addChild(tape1);
              _rootNode.addChild(tape2);
              _rootNode.addChild(tape3);

              final square = SpriteTexture(assets[1]);
              final particleSystem = ParticleSystem(
                square,
                autoRemoveOnFinish: true,
                direction: 100.0,
                directionVar: 20.0,
                emissionRate: 80.0,
                maxParticles: 60,
                numParticlesToEmit: 60,
                startRotationVar: 100,
                endRotation: 200,
                endRotationVar: 60,
                posVar: const Offset(SIZE / 80, SIZE / 80),
                startSize: 0.1,
                startSizeVar: 0.2,
                endSize: 0.1,
                speed: 1600.0,
                speedVar: 30,
                life: 3,
                alphaVar: 0,
                redVar: 200,
                blueVar: 200,
                greenVar: 200,
                colorSequence: ColorSequence.fromStartAndEndColor(Colors.white70, Colors.white),
                transferMode: BlendMode.srcOver,
              );
              particleSystem.opacity = 1.0;
              particleSystem.position = const Offset(SIZE / 7, SIZE / 2);
              particleSystem.rotation = 220.0;
              particleSystem.zPosition = 1.0;
              _rootNode.addChild(particleSystem);
            }),
//            MotionGroup([
//              MotionTween<Offset>((a) => tape1.position = a, const Offset(SIZE / 2, SIZE / 4),
//                  const Offset(SIZE * 7 / 4, -SIZE * 3 / 4), 2, Curves.linearToEaseOut),
//              MotionTween<Offset>((a) => tape2.position = a, const Offset(SIZE / 3, SIZE / 12),
//                  const Offset(SIZE / 2, -SIZE * 2), 2, Curves.linearToEaseOut),
//              MotionTween<Offset>((a) => tape3.position = a, const Offset(SIZE / 1.6, SIZE / 2.2),
//                  const Offset(SIZE * 3, SIZE / 2.2), 2, Curves.linearToEaseOut),
//            ]),
            MotionGroup([fadeOut1, fadeOut2, fadeOut3, fadeOut4, fadeOut5]),
          ]);

          popup.motions.run(MotionSequence([
            motion,
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
