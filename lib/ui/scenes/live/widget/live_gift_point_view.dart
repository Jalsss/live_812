import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class LiveGiftPointView extends StatelessWidget {
  const LiveGiftPointView({
    this.point,
    this.onTap,
  });

  final int point;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 2,
        ),
        decoration: const BoxDecoration(
          color: ColorLive.TRANS_90,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SvgPicture.asset(
              "assets/svg/gift.svg",
              height: 15,
            ),
            Text(
              '$point',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
