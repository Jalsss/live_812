import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';

/// 目立つ、グレーボタン
class PrimaryGrayButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final double height;
  final bool round;

  PrimaryGrayButton({
    @required this.text,
    @required this.onPressed,
    this.height = 60,
    this.round = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: ColorLive.C99,
          borderRadius:
              !round ? null : BorderRadius.all(Radius.circular(height / 2)),
        ),
        child: FlatButton(
          textColor: Colors.white,
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
