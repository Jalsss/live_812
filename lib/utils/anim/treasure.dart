import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class TreasureAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  TreasureAnimation({this.onEndCallback});

  @override
  _TreasureAnimationState createState() => _TreasureAnimationState();
}

class _TreasureAnimationState extends State<TreasureAnimation> {
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
      future: images.load([
        'assets/anim/18a@2x.png',
        'assets/anim/18b@2x.png',
        'assets/anim/18c@2x.png',
        'assets/anim/18gem1@2x.png',
        'assets/anim/18gem2@2x.png',
        'assets/anim/18coin1@2x.png',
        'assets/anim/18coin2@2x.png',
        'assets/anim/18coin3@2x.png',
        'assets/anim/18light@2x.png',
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<ui.Image> assets = snapshot.data;

          final gemPositions = <Offset>[
            const Offset(SIZE / 8, SIZE / 1.2),
            const Offset(SIZE / 10, SIZE / 1.3),
            const Offset(SIZE / 7, SIZE / 1.4),
            const Offset(SIZE / 7, SIZE / 1.1),
            const Offset(SIZE / 10, SIZE / 1.1),
            const Offset(SIZE * 7 / 8, SIZE / 1.3),
            const Offset(SIZE * 7 / 8, SIZE / 1.6),
            const Offset(SIZE * 11 / 12, SIZE / 1.2),
            const Offset(SIZE * 8 / 9, SIZE / 1.4),
            const Offset(SIZE * 11 / 12, SIZE / 1.5),
            const Offset(SIZE * 7 / 8, SIZE * 7 / 8),
          ];

          final gemRotation = List<double>.generate(11, (i) => i * 10.0);

          final gems = <Sprite>[];

          for (int i = 0; i < gemPositions.length; ++i) {
            final gem = Sprite.fromImage(i % 2 == 0 ? assets[3] : assets[4]);
            gem.position = gemPositions[i];
            gem.rotation = gemRotation[i];
            gems.add(gem);
            rootNode.addChild(gem);
          }

          final Sprite t1 = Sprite.fromImage(assets[0]);
          t1.position = Offset(SIZE / 2, SIZE / 2);
          rootNode.addChild(t1);

          final showT1 = MotionTween<double>(
                (a) => t1.opacity = a,
            1.0,
            1.0,
            0.5,
            Curves.linear,
          );
          final hideT1 = MotionTween<double>(
                (a) => t1.opacity = a,
            0.0,
            0.0,
            0.001,
            Curves.linear,
          );

          final Sprite t2 = Sprite.fromImage(assets[1]);
          t2.position = Offset(SIZE / 2, SIZE / 2);
          t2.opacity = 0.0;
          rootNode.addChild(t2);

          final showT2 = MotionTween<double>(
                (a) => t2.opacity = a,
            1.0,
            1.0,
            0.3,
            Curves.linear,
          );
          final hideT2 = MotionTween<double>(
                (a) => t2.opacity = a,
            0.0,
            0.0,
            0.001,
            Curves.linear,
          );

          final Sprite t3 = Sprite.fromImage(assets[2]);
          t3.position = Offset(SIZE / 2, SIZE / 2);
          t3.opacity = 0.0;
          rootNode.addChild(t3);

          final showT3 = MotionTween<double>(
                (a) => t3.opacity = a,
            1.0,
            1.0,
            0.5,
            Curves.linear,
          );

          final rotate1 = MotionTween<double>(
                (a) => t3.rotation = a,
            0.0,
            -15.0,
            0.1,
            Curves.easeIn,
          );
          final rotate1Reverse = MotionTween<double>(
                (a) => t3.rotation = a,
            -15.0,
            0.0,
            0.08,
            Curves.easeOut,
          );
          final rotate2 = MotionTween<double>(
                (a) => t3.rotation = a,
            0.0,
            15.0,
            0.1,
            Curves.easeIn,
          );
          final rotate2Reverse = MotionTween<double>(
                (a) => t3.rotation = a,
            15.0,
            0.0,
            0.08,
            Curves.easeOut,
          );

          final fadeOut = MotionTween<double>(
                (a) {
              t3.opacity = a;
              gems.forEach((g) => g.opacity = a);
            },
            1.0,
            0,
            18.0,
            Curves.easeInQuint,
          );

          final sequence = MotionSequence([
            showT1,
            hideT1,
            showT2,
            hideT2,
            MotionGroup([
              MotionGroup([
                showT3,
                MotionSequence([
                  rotate1,
                  rotate1Reverse,
                  rotate2,
                  rotate2Reverse,
                ]),
              ]),
              MotionCallFunction(() => _addCoins(assets[5], const Offset(0, SIZE / 3))),
              MotionCallFunction(() => _addCoins(assets[6], const Offset(0, SIZE / 6))),
              MotionCallFunction(() => _addCoins(assets[7], const Offset(0, SIZE))),
              MotionCallFunction(() => _addCoins(assets[8], const Offset(0, 0))),
              fadeOut,
            ]),
          ]);

          Motion motion = sequence;
          if (widget.onEndCallback != null) {
            motion = MotionSequence([
              motion,
              MotionCallFunction(widget.onEndCallback),
            ]);
          }

          t1.motions.run(motion);

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

  void _addCoins(ui.Image coinImage, Offset gravity) {
    final particle = ParticleSystem(
      SpriteTexture(coinImage),
      autoRemoveOnFinish: true,
      emissionRate: 40,
      maxParticles: 20,
      numParticlesToEmit: 200,
      posVar: const Offset(SIZE / 6, 0),
      startRotation: 0,
      endRotation: 180,
      startRotationVar: 60,
      startSize: 1.0,
      endSize: 1.0,
      speed: 200.0,
      gravity: gravity,
      transferMode: BlendMode.srcOver,
    );
    particle.position = const Offset(SIZE / 2, SIZE / 2);
    rootNode.addChild(particle);
  }
}
