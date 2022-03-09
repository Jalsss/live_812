import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/widget/safe_network_image.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class LiverProfileBackground extends StatelessWidget {
  LiverProfileBackground(
    this.liverId, {
    this.isLeave = false,
    this.cameraOff = false,
    this.eventId = '',
  });

  final String liverId;
  final bool isLeave;
  final bool cameraOff;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: (eventId ?? '').isNotEmpty && isLeave
                  ? SafeNetworkImage(
                      BackendService.getEventThumbnailUrl(eventId))
                  : SafeNetworkImage(
                      BackendService.getUserThumbnailUrl(liverId)),
              onError: (d, s) {},
              fit: BoxFit.cover,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            ),
          ),
        ),
        Center(
          child: !isLeave && !cameraOff ? _smallProfileImage(context) : Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _smallProfileImage(context),
              const SizedBox(height: 8),
              Text(
                isLeave ? ((eventId ?? '').isNotEmpty ? '配信準備中です' : '離席中…') : '音声のみで配信中！',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black,
                      offset: Offset(0, 1),
                    ),
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black,
                      offset: Offset(2, 1),
                    ),
                  ],
                ),
              ),
              isLeave ? null : _buildWave(),
            ].where((w) => w != null).toList(),
          ),
        ),
      ],
    );
  }

  Widget _smallProfileImage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double width = min(size.width, size.height) / 2;

    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: SafeNetworkImage(
            (eventId ?? '').isNotEmpty && isLeave
                ? BackendService.getEventThumbnailUrl(eventId)
                : BackendService.getUserThumbnailUrl(liverId),
          ),
          onError: (d, s) {},
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  Widget _buildWave() {
    return SizedBox(
      height: 50,
      child: WaveWidget(
        config: CustomConfig(
          gradients: const [
            [Color(0xc0ffdddd), Color(0x40ffdddd)],
            [Color(0xc0ddffdd), Color(0x40ddffdd)],
            [Color(0xc0ddddff), Color(0x40ddddff)],
            [Color(0xc0ffffff), Color(0x40ffffff)],
          ],
          durations: const [35000, 19440, 10800, 6000],
          heightPercentages: const [0.1, 0.2, 0.3, 0.6],
          blur: const MaskFilter.blur(BlurStyle.solid, 10),
          gradientBegin: Alignment.bottomLeft,
          gradientEnd: Alignment.topRight,
        ),
        waveAmplitude: 0,
        //backgroundColor: Colors.blue,
        size: const Size(
          double.infinity,
          double.infinity,
        ),
      ),
    );
  }
}
