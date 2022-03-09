import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:live812/domain/usecase/gift_usecase.dart';
import 'package:live812/utils/image_file_map.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

class SequenceAnimation extends StatefulWidget {
  final List<String> assetPaths;
  final double duration;
  final void Function() onEndCallback;
  final double scale;

  SequenceAnimation({@required this.assetPaths, @required this.duration, @required this.onEndCallback, this.scale = 1.0});

  @override
  _SequenceAnimationState createState() => _SequenceAnimationState();
}

class _SequenceAnimationState extends State<SequenceAnimation> {
  static const SIZE = 1024.0;

  NodeWithSize _originNode;
  NodeWithSize _rootNode;
  Future<List<ui.Image>> _imageLoad;

  @override
  void initState() {
    super.initState();
    _originNode = NodeWithSize(const Size(SIZE, SIZE));
    if (GiftUseCase.isTargetPlatform) {
      final ImageFileMap images = ImageFileMap();
      _imageLoad = images.load(widget.assetPaths);
    } else {
      final ImageMap images = ImageMap(rootBundle);
      _imageLoad = images.load(widget.assetPaths);
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
              final sprites = assets.map((asset) => Sprite.fromImage(asset)).toList();
              _setupRootNode(boxConstraint, sprites[0].size);
              final motions = List<Motion>();
              for (int i = 0; i < sprites.length; ++i) {
                Sprite sprite = sprites[i];
                sprite.scale = widget.scale;
                if (i == 0) {
                  _rootNode.addChild(sprite);
                } else {
                  motions.add(MotionCallFunction(() {
                    _rootNode.addChild(sprite);
                  }));
                  motions.add(MotionRemoveNode(sprites[i - 1]));
                }
                motions.add(MotionDelay(widget.duration));
              }
              motions.add(MotionCallFunction(widget.onEndCallback));

              final sequence = MotionSequence(motions);
              _rootNode.motions.run(sequence);
            }

            return Container(
              child: Center(
                child: SpriteWidget(_originNode),
              ),
            );
          },
        );
      }
    );
  }

  void _setupRootNode(BoxConstraints boxConstraint, Size imageSize) {
    final w = boxConstraint.maxWidth;
    final h = boxConstraint.maxHeight;

    if (h >= w) {
      // 横がフィットするようにスケールを計算する
      final scale = (SIZE * w) / (h * imageSize.width);
      _rootNode.scale = scale;
      // 上を合わせる
      _rootNode.position = Offset(SIZE * 0.5, SIZE * 0.5 - (SIZE - imageSize.height * scale) * 0.5);
    } else {
      // 縦が3/5（適当）入るようにスケールを計算する
      final scale = (SIZE * h) / (w * imageSize.height * (3 / 5));
      _rootNode.scale = scale;
      // 中央
      _rootNode.position = Offset(SIZE * 0.5, SIZE * 0.5);
    }
  }
}
