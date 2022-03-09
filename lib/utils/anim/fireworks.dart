import 'dart:math';

import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class FireworksAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  FireworksAnimation(this.onEndCallback);

  @override
  _FireworksAnimationState createState() => _FireworksAnimationState();
}

class _FireworksAnimationState extends State<FireworksAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  int _getRandomSign(int seed) {
    switch (seed % 4) {
      case 0:
        return 1;
      case 1:
        return -1;
      case 2:
        return -1;
      case 3:
        return 1;
      default:
        return 1;
    }
  }

  Offset _getRandomPosition() {
    final position = Random().nextDouble();
    final sign = Random().nextInt(400);
    return Offset(SIZE / 2 + position * 500 * _getRandomSign(sign),
        SIZE / 2 + position * 500 * _getRandomSign(sign + 1));
  }

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images
          .load(['assets/anim/14popup@2x.png', 'assets/anim/particle.png']),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final Sprite popup = Sprite.fromImage(assets[0]);
          popup.position = const Offset(SIZE / 2, SIZE / 2);
          popup.zPosition = 1.0;
          _rootNode.addChild(popup);

          final particle = SpriteTexture(snapshot.data[1]);
          final delay = MotionDelay(0.8);
          final fireworks = MotionSequence(List<Motion>.generate(
              28,
              (i) => i % 2 == 0 ? delay : MotionCallFunction(() {
                final colorVar = Random().nextInt(300);
                final particleSystem = ParticleSystem(
                  particle,
                  autoRemoveOnFinish: true,
                  emissionRate: 4000.0,
                  maxParticles: 1200,
                  numParticlesToEmit: 1200,
                  startSize: 0.1,
                  startSizeVar: 0.1,
                  endSize: 0.1,
                  speed: 800.0,
                  speedVar: 10,
                  life: 0.5,
                  alphaVar: 0,
                  redVar: colorVar % 3 == 0 ? 0xFF : 0,
                  blueVar: colorVar % 3 == 1 ? 0xFF : 0,
                  greenVar: colorVar % 3 == 2 ? 0xFF : 0,
                  colorSequence: ColorSequence.fromStartAndEndColor(
                      Colors.white, Colors.white),
                  gravity: const Offset(0, SIZE / 6),
                  transferMode: BlendMode.srcOver,
                );
                particleSystem.opacity = 0.7;
                particleSystem.position = _getRandomPosition();
                particleSystem.zPosition = 2.0;
                _rootNode.addChild(particleSystem);
              }),
          ));

          final fadeOut = motionFadeOut(popup, 13.0, Curves.easeInQuint);

          popup.motions.run(MotionSequence([
            MotionGroup([fireworks, fadeOut]),
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
