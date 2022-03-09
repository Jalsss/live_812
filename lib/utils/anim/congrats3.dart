import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class Congrats3Animation extends StatefulWidget {
  final void Function() onEndCallback;

  Congrats3Animation(this.onEndCallback);

  @override
  _Congrats3AnimationState createState() => _Congrats3AnimationState();
}

class _Congrats3AnimationState extends State<Congrats3Animation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future:
      images.load(['assets/anim/15@2x.png', 'assets/anim/15popup@2x.png', 'assets/anim/square.png']),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final Sprite cake = Sprite.fromImage(assets[0]);
          cake.position = const Offset(SIZE / 2, SIZE / 2);
          cake.zPosition = 3.0;
          cake.opacity = 0;
          _rootNode.addChild(cake);

          final Sprite popup = Sprite.fromImage(assets[1]);
          popup.position = const Offset(SIZE / 2, SIZE);
          popup.zPosition = 4.0;
          popup.opacity = 0;
          _rootNode.addChild(popup);

          final square = SpriteTexture(assets[2]);

          final fadeIn1 = motionFadeIn(cake, 0.5, Curves.easeOut);
          final fadeIn2 = motionFadeIn(popup, 0.5, Curves.easeOut);

          final fadeOut1 = motionFadeOut(cake, 11.0, Curves.easeInQuint);
          final fadeOut2 = motionFadeOut(popup, 11.0, Curves.easeInQuint);

          Motion motion = MotionSequence([
            MotionGroup([fadeIn1, fadeIn2]),
            MotionCallFunction(() {
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
                speed: 1200.0,
                speedVar: 30,
                life: 8,
                alphaVar: 0,
                redVar: 200,
                blueVar: 200,
                greenVar: 200,
                colorSequence: ColorSequence.fromStartAndEndColor(
                    Colors.white70, Colors.white),
                transferMode: BlendMode.srcOver,
              );
              particleSystem.opacity = 1.0;
              particleSystem.position = const Offset(-SIZE / 3, SIZE);
              particleSystem.rotation = 210.0;
              particleSystem.zPosition = 2.0;
              _rootNode.addChild(particleSystem);
            }),
            MotionDelay(0.4),
            MotionCallFunction(() {
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
                speed: 1200.0,
                speedVar: 30,
                life: 8,
                alphaVar: 0,
                redVar: 200,
                blueVar: 200,
                greenVar: 200,
                colorSequence: ColorSequence.fromStartAndEndColor(
                    Colors.white70, Colors.white),
                transferMode: BlendMode.srcOver,
              );
              particleSystem.opacity = 1.0;
              particleSystem.position = const Offset(SIZE * 4 / 3, SIZE);
              particleSystem.rotation = 150.0;
              particleSystem.zPosition = 2.0;
              _rootNode.addChild(particleSystem);
            }),
            MotionDelay(0.8),
            MotionCallFunction(() {
              final particleSystem = ParticleSystem(
                square,
                autoRemoveOnFinish: true,
                emissionRate: 80.0,
                maxParticles: 400,
                numParticlesToEmit: 400,
                startRotationVar: 100,
                endRotation: 200,
                endRotationVar: 60,
                posVar: const Offset(SIZE, 0),
                startSize: 0.1,
                startSizeVar: 0.2,
                endSize: 0.1,
                speed: 200.0,
                speedVar: 30,
                life: 6,
                alphaVar: 0,
                redVar: 200,
                blueVar: 200,
                greenVar: 200,
                gravity: const Offset(0, SIZE / 3),
                colorSequence: ColorSequence.fromStartAndEndColor(
                    Colors.white70, Colors.white),
                transferMode: BlendMode.srcOver,
              );
              particleSystem.opacity = 1.0;
              particleSystem.position = const Offset(SIZE / 2, -SIZE);
              particleSystem.zPosition = 2.0;
              _rootNode.addChild(particleSystem);
            }),
            MotionGroup([fadeOut1, fadeOut2]),
          ]);

          cake.motions.run(MotionSequence([
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
