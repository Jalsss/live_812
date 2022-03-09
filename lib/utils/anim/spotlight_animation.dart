import 'dart:math';

import 'package:flutter/material.dart';
import 'package:live812/domain/usecase/gift_usecase.dart';
import 'package:live812/utils/image_file_map.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class SpotlightTable {
  final double delay;
  final double duration;
  final double angle;
  final double x, y;
  final double fade;
  final int image;
  final double scale;
  final double loop;

  const SpotlightTable({
    @required this.x, @required this.y, @required this.delay, @required this.duration,
    @required this.angle, this.fade = 0.25, this.image = 0, this.scale = 1, this.loop = 1.0,
  });
}

class SpotlightAnimation extends StatefulWidget {
  final List<String> imagePaths;
  final List<SpotlightTable> table;
  final void Function() onEndCallback;

  SpotlightAnimation({@required this.imagePaths, @required this.table, @required this.onEndCallback});

  @override
  _SpotlightAnimationState createState() => _SpotlightAnimationState();
}

class _SpotlightAnimationState extends State<SpotlightAnimation> {
  static const SIZE = 384.0;

  NodeWithSize _originNode;
  NodeWithSize _rootNode;
  Future<List<ui.Image>> _imageLoad;
  double _scaleX = 1;

  @override
  void initState() {
    super.initState();
    _originNode = NodeWithSize(const Size(SIZE, SIZE));
    if (GiftUseCase.isTargetPlatform) {
      final ImageFileMap images = ImageFileMap();
      _imageLoad = images.load(widget.imagePaths);
    } else {
      final ImageMap images = ImageMap(rootBundle);
      _imageLoad = images.load(widget.imagePaths);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, boxConstraint) {
        return FutureBuilder(
          future: _imageLoad,
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Container();

            if (_rootNode == null) {
              _rootNode = NodeWithSize(const Size(SIZE, SIZE));
              _rootNode.position = const Offset(SIZE / 2, SIZE / 2);
              _originNode.addChild(_rootNode);

              final List<ui.Image> assets = snapshot.data;
              _setupRootNode(boxConstraint);

              final duration = _createSpotlights(_rootNode, widget.table, assets);

              _rootNode.motions.run(MotionSequence([
                MotionDelay(duration),
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
    );
  }

  double _createSpotlights(Node parent, List<SpotlightTable> table, List<ui.Image> images) {
    double duration = 0;
    for (int i = 0; i < table.length; ++i) {
      final t = table[i];
      final sprite = Sprite.fromImage(images[t.image]);
      sprite.pivot = const Offset(0.5, 0.05);
      sprite.position = Offset(t.x * (SIZE * 0.5) * _scaleX, t.y * (SIZE * 0.5));
      sprite.scale = t.scale;

      sprite.motions.run(MotionTween<double>(
          (v) => sprite.rotation = cos(v) * t.angle,
          0, 2 * pi * t.loop, t.duration),
      );
      if (t.fade > 0) {
        sprite.motions.run(MotionTween<double>(
            (v) => sprite.opacity = v,
            0, 1, t.fade),
        );
        sprite.motions.run(MotionSequence([
          MotionDelay(t.duration - t.fade),
          MotionTween<double>(
              (v) => sprite.opacity = v,
              1, 0, t.fade),
        ]));
      }

      if (t.delay <= 0) {
        parent.addChild(sprite);
      } else {
        parent.motions.run(MotionSequence([
          MotionDelay(t.delay),
          MotionCallFunction(() => parent.addChild(sprite)),
        ]));
      }

      duration = max(duration, t.delay + t.duration);
    }
    return duration;
  }

  void _setupRootNode(BoxConstraints boxConstraint) {
    final w = boxConstraint.maxWidth;
    final h = boxConstraint.maxHeight;

    if (h >= w) {
      // 縦がSIZEいっぱい、横のスケールを計算
      _rootNode.scale = 1.0;
      _scaleX = w / h;
      // 中央
      _rootNode.position = Offset(SIZE * 0.5, SIZE * 0.5);
    } else {
      // 縦がSIZEいっぱい、横のスケールを計算
      final shrink = 4 / 5;
      final scale = h / w / shrink;
      _rootNode.scale = scale;
      // 上を合わせる
      _rootNode.position = Offset(SIZE * 0.5, SIZE * (0.5 + (1 - shrink) * 0.5));
      _scaleX = 1;  //w / h;
    }
  }
}
