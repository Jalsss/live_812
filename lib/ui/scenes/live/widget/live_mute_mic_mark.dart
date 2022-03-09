import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class LiveMuteMicMark extends StatelessWidget {
  const LiveMuteMicMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      width: 100,
      height: 70,
      decoration: const BoxDecoration(
        color: ColorLive.TRANS_90,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svg/menu/mute.svg',
            height: 28,
          ),
          const Text(
            'ミュート中',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
