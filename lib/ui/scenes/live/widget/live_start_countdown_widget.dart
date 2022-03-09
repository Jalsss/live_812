import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/date_format.dart';

class LiveStartCountdownWidget extends StatefulWidget {
  LiveStartCountdownWidget({
    @required this.startDate,
    @required this.endDate,
    @required this.onStop,
  });

  /// 配信開始時間.
  final DateTime startDate;
  /// 配信終了時間.
  final DateTime endDate;
  /// 配信開始時のコールバック.
  final Function onStop;

  @override
  _LiveStartCountdownWidgetState createState() =>
      _LiveStartCountdownWidgetState();
}

class _LiveStartCountdownWidgetState extends State<LiveStartCountdownWidget> {
  Timer _timer;
  int _seconds = 0;

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), _updateDisplay);
    _updateDisplay(null);
  }

  void _updateDisplay(Timer _) {
    if (widget.startDate == null) {
      return;
    }
    final now = DateTime.now();
    setState(() {
      final _milliseconds = widget.startDate.difference(now).inMilliseconds;
      _seconds = (_milliseconds / 1000).floor();
      if (_milliseconds <= 0) {
        _seconds = 0;
        // タイマーを停止.
        if (_timer.isActive) {
          _timer.cancel();
          if (widget.onStop != null) {
            widget.onStop();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(128),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      width: 230,
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'もうすぐあなたの配信が始まります。',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${dateFormatTime(widget.startDate)}〜${dateFormatTime(widget.endDate)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const Text(
            '開始まであと',
            style: TextStyle(
              color: ColorLive.YELLOW,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorLive.YELLOW,
                    width: 3,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Center(
                child: Text(
                  '$seconds',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              Container(
                width: 130,
                height: 100,
                alignment: Alignment.bottomRight,
                child: const Text(
                  '秒',
                  style: TextStyle(
                    color: ColorLive.YELLOW,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
