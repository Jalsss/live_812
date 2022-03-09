import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:simple_animations/simple_animations.dart';

class LikeParticles extends StatefulWidget {
  final int numberOfParticles;
  final void Function(Function) onReadyCallback;

  LikeParticles(this.numberOfParticles, {@required this.onReadyCallback});

  @override
  _LikeParticlesState createState() => _LikeParticlesState();
}

class _LikeParticlesState extends State<LikeParticles> {
  final Random _random = Random();
  final List<_LikeParticleModel> _particles = [];
  ui.Image _image_heart;
  ui.Image _image_heart1;
  ui.Image _image_heart2;
  ui.Image _image_heart3;
  ui.Image _image_heart4;
  ui.Image _image_heart5;
  ui.Image _image_heart6;
  ui.Image _image_heart7;
  bool _isImageloaded = false;
  int _activeCount = 0;
  bool _active = false;
  Duration _now = Duration(seconds: 0);

  @override
  void initState() {
    super.initState();

    _init();
  }

  Future<Null> _init() async {
    ByteData data = await rootBundle.load('assets/icon/like_01.png'); // red
    _image_heart1 = await _loadImage(Uint8List.view(data.buffer));
    data = await rootBundle.load('assets/icon/like_02.png'); //yellow
    _image_heart2 = await _loadImage(Uint8List.view(data.buffer));
    data = await rootBundle.load('assets/icon/like_03.png'); // green
    _image_heart3 = await _loadImage(Uint8List.view(data.buffer));
    data = await rootBundle.load('assets/icon/like_04.png'); //blue
    _image_heart4 = await _loadImage(Uint8List.view(data.buffer));
    data = await rootBundle.load('assets/icon/like_05.png'); //purple
    _image_heart5 = await _loadImage(Uint8List.view(data.buffer));
    data = await rootBundle.load('assets/icon/like_06.png'); //bell
    _image_heart6 = await _loadImage(Uint8List.view(data.buffer));
    data = await rootBundle.load('assets/icon/like_07.png'); //snow
    _image_heart7 = await _loadImage(Uint8List.view(data.buffer));
    data = await rootBundle.load('assets/icon/like.png'); // pink
    _image_heart = await _loadImage(Uint8List.view(data.buffer));

    if (widget.onReadyCallback != null) {
      widget.onReadyCallback(_spawn);
    }
  }

  Future<ui.Image> _loadImage(List<int> img) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        _isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return !_active
        ? Container()
        : Rendering(
            //startTime: Duration(seconds: 1),
            onTick: _simulateParticles,
            builder: (context, time) {
              return Container(
                child: _buildImage(time),
              );
            },
          );
  }

  Widget _buildImage(time) {
    if (this._isImageloaded) {
      return CustomPaint(
        painter: _LikeParticlePainter(_particles, _activeCount, time),
      );
    } else {
      return Center();
    }
  }

  void _simulateParticles(Duration time) {
    _now = time;
    for (int i = 0; i < _activeCount; ++i) {
      final particle = _particles[i];
      if (!particle.update(time)) {
        if (i < _activeCount - 1) {
          // 最後の位置と入れ替えて、非アクティブにする
          _particles[i] = _particles[_activeCount - 1];
          _particles[_activeCount - 1] = particle;
          --i;
        }
        if (--_activeCount <= 0) {
          setState(() {
            _active = false;
            _now = Duration(seconds: 0);
          });
        }
      }
    }
  }

  void _spawn() {
    if (_activeCount >= widget.numberOfParticles) return;

    int index = _activeCount++;
    if (index <= 0) {
      setState(() => _active = true);
    }

    _LikeParticleModel particle = _LikeParticleModel();
    if (index >= _particles.length) {
      _particles.add(particle);
    } else {
      particle = _particles[index];
    }

    final randomInt = _random.nextInt(29);
    switch (randomInt) {
      case 0: case 1: case 2: case 3: 
        particle.image = _image_heart;
        break;
      case 4: case 5: case 6: case 7: 
        particle.image = _image_heart1;
        break;
      case 8: case 9: case 10: case 11: 
        particle.image = _image_heart2;
        break;
      case 12: case 13: case 14: case 15: 
        particle.image = _image_heart3;
        break;
      case 16: case 17: case 18: case 19: 
        particle.image = _image_heart4;
        break;
      case 20: case 21: case 22: case 23: 
        particle.image = _image_heart5;
        break;
      case 24: case 25: case 26: 
        particle.image = _image_heart6;
        break;
      case 27: case 28: case 29: default:
        particle.image = _image_heart7;
        break;
    }

    particle.restart(_random, time: _now);
  }
}

class _LikeParticleModel {
  Animatable _tween;
  AnimationProgress _animationProgress;
  ui.Image image;

  void restart(Random random, {Duration time = Duration.zero}) {
    final startPosition = Offset(random.nextDouble(), 0.95);
    final endPosition = Offset(random.nextDouble(), 0.0);
    final duration = Duration(milliseconds: 2000 + random.nextInt(1000));

    _tween = MultiTrackTween([
      Track("x").add(
          duration, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.easeInOutSine),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.easeIn),
    ]);
    _animationProgress = AnimationProgress(duration: duration, startTime: time);
  }

  bool update(Duration time) {
    final progress = _animationProgress.progress(time);
    if (progress >= 1.0) {
      return false;
    }
    return true;
  }
}

class _LikeParticlePainter extends CustomPainter {
  final List<_LikeParticleModel> _particles;
  final int activeCount;
  final Duration _time;

  _LikeParticlePainter(this._particles, this.activeCount, this._time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ColorLive.PINK.withAlpha(150);

    final ofsx = -_particles[0].image.width * 0.5;
    final ofsy = -_particles[0].image.width * 0.5;

    for (int i = 0; i < activeCount; ++i) {
      final particle = _particles[i];
      final progress = particle._animationProgress.progress(_time);
      final animation = particle._tween.transform(progress);
      final position = Offset(animation["x"] * size.width + ofsx,
          animation["y"] * size.height + ofsy);
      canvas.drawImage(_particles[i].image, position, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
