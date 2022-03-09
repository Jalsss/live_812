import 'dart:math';

import 'package:flutter/material.dart';
import 'package:live812/domain/usecase/gift_usecase.dart';
import 'package:live812/utils/image_file_map.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui show Image;

// 複数パートのレン版アニメ

enum SequenceAlign {
  TOP,
  BOTTOM,
}

class SequenceInfo {
  final SequenceAlign align;
  final double offset;
  final List<String> assetPaths;

  SequenceInfo({this.align, this.offset, this.assetPaths});
}

class SequenceAnimationMulti extends StatefulWidget {
  final List<SequenceInfo> sequenceInfos;
  final double duration;
  final void Function() onEndCallback;
  final double scale;

  SequenceAnimationMulti({@required this.sequenceInfos, @required this.duration, @required this.onEndCallback, this.scale = 1.0});

  @override
  _SequenceAnimationMultiState createState() => _SequenceAnimationMultiState();
}

class _SequenceAnimationMultiState extends State<SequenceAnimationMulti> {
  static const SIZE = 1024.0;

  NodeWithSize _originNode;
  NodeWithSize _rootNode;
  final ImageMap images = ImageMap(rootBundle);
  Future<List<List<ui.Image>>> _imageLoad;

  @override
  void initState() {
    super.initState();
    _originNode = NodeWithSize(const Size(SIZE, SIZE));
    if (GiftUseCase.isTargetPlatform) {
      final ImageFileMap images = ImageFileMap();
      _imageLoad = Future.wait(widget.sequenceInfos.map((info) =>
          images.load(info.assetPaths)));
    } else {
      final ImageMap images = ImageMap(rootBundle);
      _imageLoad = Future.wait(widget.sequenceInfos.map((info) =>
          images.load(info.assetPaths)));
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

                final mq = MediaQuery.of(context);
                final List<List<ui.Image>> assets = snapshot.data;
                final sprites = assets.map((list) => list.map((asset) => Sprite.fromImage(asset)).toList()).toList();
                final sizes = sprites.map((list) => list[0].size).toList();
                final positions = _setupRootNode(mq, boxConstraint, sizes);
                for (int i = 0; i < sprites.length; ++i) {
                  final motions = List<Motion>();
                  for (int j = 0; j < sprites[i].length; ++j) {
                    Sprite sprite = sprites[i][j];
                    sprite.scale = widget.scale;
                    sprite.position = positions[i];
                    if (j == 0) {
                      _rootNode.addChild(sprite);
                    } else {
                      motions.add(MotionCallFunction(() {
                        _rootNode.addChild(sprite);
                      }));
                      motions.add(MotionRemoveNode(sprites[i][j - 1]));
                    }
                    motions.add(MotionDelay(widget.duration));
                  }
                  if (i == 0)
                    motions.add(MotionCallFunction(widget.onEndCallback));

                  final sequence = MotionSequence(motions);
                  _rootNode.motions.run(sequence);
                }
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

  List<Offset> _setupRootNode(MediaQueryData mq, BoxConstraints boxConstraint, List<Size> imageSizes) {
    final w = boxConstraint.maxWidth;
    final h = boxConstraint.maxHeight;

    if (h >= w) {
      // 横がフィットするようにスケールを計算する
      final scale = (SIZE * w) / (h * imageSizes[0].width);
      _rootNode.scale = scale;

      // 各表示位置計算
      return List.generate(imageSizes.length, (i) {
        final size = imageSizes[i];
        final info = widget.sequenceInfos[i];
        final hh = size.height;
        switch (info.align) {
          case SequenceAlign.TOP:
            return Offset(0, (-SIZE / scale + hh) * 0.5 + info.offset);
          case SequenceAlign.BOTTOM:
            return Offset(0, ( SIZE / scale - hh) * 0.5 - info.offset + mq.padding.bottom);  // ライブ画面は画面下部のパディングを無視するので、その分ずらす
          default:
            return null;
        }
      }).toList();
    } else {
      //final totalH = imageSizes.map((size) => size.height).reduce((a, b) => a + b);
      final totalH = imageSizes.map((size) => size.height).reduce((a, b) => max(a, b));  // 上下重ねるようにしてみる
      final scale = (SIZE * h) / (w * totalH);
      _rootNode.scale = scale;

      // 各表示位置計算（ポートレイトの場合はオフセットは無視して、トップとボトムに配置）
      return List.generate(imageSizes.length, (i) {
        final size = imageSizes[i];
        final info = widget.sequenceInfos[i];
        final hh = size.height;
        switch (info.align) {
          case SequenceAlign.TOP:
            return Offset(0, (-totalH + hh) * 0.5);
          case SequenceAlign.BOTTOM:
            return Offset(0, ( totalH - hh) * 0.5 + mq.padding.bottom);  // ライブ画面は画面下部のパディングを無視するので、その分ずらす
          default:
            return null;
        }
      }).toList();
    }
  }
}
