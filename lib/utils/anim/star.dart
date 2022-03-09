import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class StarAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  StarAnimation(this.onEndCallback);

  @override
  _StarAnimationState createState() => _StarAnimationState();
}

class _StarAnimationState extends State<StarAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load([
        'assets/anim/star.png',
        'assets/anim/12a@2x.png',
        'assets/anim/12b@2x.png',
        'assets/anim/12c@2x.png',
        'assets/anim/stardust.png',
        'assets/anim/12popup@2x.png',
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final List<ui.Image> assets = snapshot.data;
          final ui.Image star = assets[0];

          _addParticle(assets[1]);
          _addParticle(assets[2]);
          _addParticle(assets[3]);

          final stardust = SpriteTexture(assets[4]);
          final positions = <List<double>>[
            [SIZE * 2, 0],
            [SIZE * 2, -SIZE * 1.5],
            [SIZE * 2, -SIZE * 0.5],
            [SIZE * 2, SIZE * 0.5],
            [SIZE * 2, -SIZE],
            [SIZE * 2, -SIZE * 1.8],
            [SIZE * 2, SIZE * 0.7],
            [SIZE * 2, SIZE * 0.2],
            [SIZE * 2, -SIZE],
          ];
          var index = 0;
          final delay = MotionDelay(0.8);

          final title = Sprite.fromImage(assets[5]);
          title.position = const Offset(SIZE / 2, SIZE / 2);
          title.scale = 1.5;
          _rootNode.addChild(title);

          final fadeOutTitle = motionFadeOut(title, 12.0, Curves.easeInQuint);

          final sequence = MotionSequence(List.generate(
            18,
            (i) => i % 2 != 0 ? delay : MotionCallFunction(() {
              _addShootingStar(star, stardust, positions[index][0], positions[index][1]);
              ++index;
            }),
          ));

          Motion motion = MotionGroup([fadeOutTitle, sequence]);
          if (widget.onEndCallback != null) {
            motion = MotionSequence([
              motion,
              MotionCallFunction(widget.onEndCallback),
            ]);
          }
          title.motions.run(motion);
        }

        return Container(
          child: Center(
            child: SpriteWidget(_rootNode),
          ),
        );
      },
    );
  }

  void _addParticle(ui.Image image) {
    final particleSystem = ParticleSystem(
      SpriteTexture(image),
      autoRemoveOnFinish: true,
      direction: 90.0,
      directionVar: 0.0,
      emissionRate: 10.0,
      maxParticles: 180,
      numParticlesToEmit: 80,
      endRotation: 150,
      endRotationVar: 100,
      posVar: const Offset(SIZE, SIZE / 8),
      startSizeVar: 0.3,
      startSize: 1.0,
      endSize: 0.2,
      speed: 600.0,
      speedVar: 50,
      life: 8,
      lifeVar: 0.5,
      alphaVar: 20,
      transferMode: BlendMode.srcOver,
    );
    particleSystem.opacity = 1.0;
    particleSystem.position = const Offset(SIZE * 1.5, -SIZE / 4);
    particleSystem.rotation = 45.0;
    _rootNode.addChild(particleSystem);
  }

  void _addShootingStar(
      ui.Image starImage, SpriteTexture stardust, double dx, double dy) {
    final particle = ParticleSystem(
      stardust,
      autoRemoveOnFinish: true,
      emissionRate: 80,
      direction: -45.0,
      directionVar: 0,
      maxParticles: 800,
      numParticlesToEmit: 1600,
      endRotation: 150,
      endRotationVar: 100,
      posVar: const Offset(SIZE / 15, SIZE / 15),
      startSizeVar: 0.2,
      startSize: 0.2,
      endSize: 0.2,
      speed: 600.0,
      speedVar: 30,
      life: 2,
      lifeVar: 0.5,
      alphaVar: 60,
      greenVar: 100,
      colorSequence:
      ColorSequence.fromStartAndEndColor(Colors.amber, Colors.white),
      transferMode: BlendMode.srcOver,
    );

    final star = Sprite.fromImage(starImage);
    star.position = const Offset(SIZE * 2, -SIZE * 2);
    star.scale = 0.6;

    _rootNode.addChild(particle);
    _rootNode.addChild(star);

    final shooting = MotionTween<double>(
        (a) => star.position = particle.position = Offset(dx - a, dy + a),
        0,
        SIZE * 3.5,
        6.0,
        Curves.easeOut);

    final fadeOut = MotionTween<double>(
        (a) => star.opacity = particle.opacity = a,
        1.0, 0.0, 8.0, Curves.easeInQuint);

    star.motions.run(MotionGroup([shooting, fadeOut]));
  }
}
