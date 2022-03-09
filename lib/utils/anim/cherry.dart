import 'package:flutter/material.dart';
import 'package:live812/utils/anim/sprite_utils.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';

class CherryAnimation extends StatefulWidget {
  final void Function() onEndCallback;

  CherryAnimation(this.onEndCallback);

  @override
  _CherryAnimationState createState() => _CherryAnimationState();
}

class _CherryAnimationState extends State<CherryAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _rootNode;

  @override
  Widget build(BuildContext context) {
    final ImageMap images = ImageMap(rootBundle);
    return FutureBuilder(
      future: images.load([
        'assets/anim/13a@2x.png',
        'assets/anim/13b@2x.png',
        'assets/anim/13popup@2x.png'
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Container();

        if (_rootNode == null) {
          _rootNode = NodeWithSize(const Size(SIZE, SIZE));

          final cherry1 = snapshot.data[1];
          final particleSystem1 = ParticleSystem(
            SpriteTexture(cherry1),
            autoRemoveOnFinish: true,
            emissionRate: 6.0,
            maxParticles: 30,
            numParticlesToEmit: 40,
            startRotationVar: 100,
            endRotation: 300,
            endRotationVar: 180,
            posVar: const Offset(SIZE, SIZE / 8),
            startSizeVar: 0.1,
            startSize: 0.6,
            endSize: 0.6,
            speed: 40.0,
            speedVar: 2,
            life: 6,
            lifeVar: 1,
            alphaVar: 0,
            gravity: const Offset(0, SIZE / 1.5),
            transferMode: BlendMode.srcOver,
          );
          particleSystem1.opacity = 1.0;
          particleSystem1.position = const Offset(SIZE * 2, -SIZE);
          particleSystem1.rotation = 20.0;
          particleSystem1.zPosition = 1.0;
          particleSystem1.scale = 1.0;
          _rootNode.addChild(particleSystem1);

          final cherry2 = snapshot.data[1];
          final particleSystem2 = ParticleSystem(
            SpriteTexture(cherry2),
            autoRemoveOnFinish: true,
            emissionRate: 22.0,
            maxParticles: 160,
            numParticlesToEmit: 240,
            startRotationVar: 100,
            endRotation: 300,
            endRotationVar: 180,
            posVar: const Offset(SIZE, SIZE / 8),
            startSizeVar: 0.1,
            startSize: 0.4,
            endSize: 0.4,
            speed: 200.0,
            speedVar: 2,
            life: 6,
            lifeVar: 1,
            alphaVar: 0,
            gravity: const Offset(0, SIZE / 1.5),
            transferMode: BlendMode.srcOver,
          );
          particleSystem2.opacity = 1.0;
          particleSystem2.position = const Offset(SIZE * 2, -SIZE);
          particleSystem2.rotation = 30.0;
          particleSystem2.zPosition = 2.0;
          particleSystem2.scale = 2.0;
          _rootNode.addChild(particleSystem2);

          final cherry3 = snapshot.data[0];
          final particleSystem3 = ParticleSystem(
            SpriteTexture(cherry3),
            autoRemoveOnFinish: true,
            emissionRate: 4.0,
            maxParticles: 20,
            numParticlesToEmit: 40,
            startRotationVar: 100,
            endRotation: 300,
            endRotationVar: 180,
            posVar: const Offset(SIZE, SIZE / 8),
            startSizeVar: 0.1,
            startSize: 0.4,
            endSize: 0.4,
            speed: 20.0,
            speedVar: 2,
            life: 6,
            lifeVar: 1,
            alphaVar: 0,
            gravity: const Offset(0, SIZE / 1.5),
            transferMode: BlendMode.srcOver,
          );
          particleSystem3.opacity = 1.0;
          particleSystem3.position = const Offset(SIZE * 2, -SIZE);
          particleSystem3.rotation = 40.0;
          particleSystem3.zPosition = 3.0;
          particleSystem3.scale = 2.0;
          _rootNode.addChild(particleSystem3);

          final title = Sprite.fromImage(snapshot.data[2]);
          title.position = const Offset(SIZE / 2, SIZE / 2);
          title.scale = 1.0;
          _rootNode.addChild(title);

          final fadeOut = motionFadeOut(title, 14.0, Curves.easeInQuint);

          title.motions.run(MotionSequence([
            fadeOut,
            MotionCallFunction(widget.onEndCallback),
          ]));
        }

        return Container(
          child: SpriteWidget(_rootNode),
        );
      },
    );
  }
}
