import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class HighlightButton extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final bool highlight;
  final void Function() onPressed;

  HighlightButton(this.text, {
    Key key,
    this.onPressed,
    this.width = 200, this.height = 40, this.highlight = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: highlight ? null : ColorLive.C505,
        gradient: !highlight ? null : LinearGradient(
          begin: Alignment.centerLeft,
          colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
        ),
      ),
      child: FlatButton(
        textColor: Colors.white,
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
