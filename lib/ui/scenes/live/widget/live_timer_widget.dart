import 'dart:async';

import 'package:flutter/material.dart';

class LiveTimerWidget extends StatefulWidget {
  final DateTime startTime;

  LiveTimerWidget(this.startTime);

  @override
  _LiveTimerWidgetState createState() => _LiveTimerWidgetState();
}

class _LiveTimerWidgetState extends State<LiveTimerWidget> {
  Timer _timer;
  int _seconds = 0;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), _updateDisplay);
  }

  void _updateDisplay(Timer _) {
    final now = DateTime.now();
    setState(() {
      if (widget.startTime == null)
        _seconds = 0;
      else
        _seconds = now.difference(widget.startTime).inSeconds;
    });
  }

  String _getDisplay() {
    if (widget.startTime == null)
      return '';

    final hours = (_seconds ~/ 3600).toString().padLeft(2, "0");
    final minutes = ((_seconds % 3600) ~/ 60).toString().padLeft(2, "0");
    final seconds = ((_seconds % 60).toString().padLeft(2, "0"));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Text(_getDisplay(),
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
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
    );
  }
}
