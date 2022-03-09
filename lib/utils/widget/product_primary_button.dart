import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class ProductPrimaryButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final String draughtText;
  final void Function() onDraught;
  final bool isRelease;
  final double height;

  ProductPrimaryButton({
    @required this.text,
    @required this.onPressed,
    this.draughtText,
    this.onDraught,
    this.isRelease,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
              ),
            ),
            child: FlatButton(
              textColor: Colors.white,
              onPressed: onPressed,
              child: Text(
                text,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        isRelease
            ? SizedBox.shrink()
            : Expanded(
                flex: 4,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      colors: [Colors.grey, Colors.grey[600]],
                    ),
                  ),
                  child: FlatButton(
                    textColor: Colors.white,
                    onPressed: onDraught,
                    child: Text(
                      draughtText,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
