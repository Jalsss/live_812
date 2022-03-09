import 'package:flutter/material.dart';

// 読み込み中を知らせるインジケータ
class SpinningIndicator extends StatelessWidget {
  final bool shade;
  final bool invisible;

  SpinningIndicator({this.shade = true, this.invisible = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: shade && !invisible ? Color(0x40000000) : Colors.transparent,
      child: invisible ? null : Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
