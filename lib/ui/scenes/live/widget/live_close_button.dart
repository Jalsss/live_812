import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class LiveCloseButton extends StatelessWidget {
  const LiveCloseButton({
    this.text,
    this.space = 8,
    this.onTap,
  });

  final String text;
  final double space;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              shadows: [
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
          SizedBox(width: space),
          ClipOval(
            child: Container(
              height: 25,
              width: 25,
              padding: const EdgeInsets.all(5),
              color: ColorLive.TRANS_90,
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
