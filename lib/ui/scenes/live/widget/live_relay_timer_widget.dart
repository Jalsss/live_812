import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/date_format.dart';

/// リレー配信の残り時間.
class LiveRelayTimerWidget extends StatefulWidget {
  const LiveRelayTimerWidget({
    @required this.endDate,
  });

  final DateTime endDate;

  @override
  _LiveRelayTimerWidgetState createState() => _LiveRelayTimerWidgetState();
}

class _LiveRelayTimerWidgetState extends State<LiveRelayTimerWidget> {
  Timer _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), _updateDisplay);
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _updateDisplay(Timer _) {
    if (widget.endDate == null) {
      return;
    }
    final now = DateTime.now();
    setState(() {
      _seconds = widget.endDate.difference(now).inSeconds;
      if (_seconds <= 0) {
        _seconds = 0;
        // タイマーを停止.
        if (_timer.isActive) {
          _timer.cancel();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_seconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return Container(
      width: 170,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xB3FF252E),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${dateFormatTime(widget.endDate)}',
            style: const TextStyle(
              color: ColorLive.YELLOW,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const Text(
            'まであと',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$minutes',
            style: const TextStyle(
              color: ColorLive.YELLOW,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const Text(
            '分',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$seconds',
            style: const TextStyle(
              color: ColorLive.YELLOW,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const Text(
            '秒',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
