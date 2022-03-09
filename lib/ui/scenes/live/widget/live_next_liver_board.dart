import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/widget/safe_network_image.dart';
import 'package:marquee/marquee.dart';

class LiveNextLiverBoard extends StatelessWidget {
  const LiveNextLiverBoard({
    this.liverId,
    this.liverName,
    this.startDate,
  });

  /// ライバーのID.
  final String liverId;

  /// ライバーの名前.
  final String liverName;

  /// 開始時間.
  final DateTime startDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 46,
      decoration: BoxDecoration(
        color: ColorLive.BLUE,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(
              radius: 16.5,
              backgroundImage:
                  SafeNetworkImage(BackendService.getUserThumbnailUrl(liverId)),
              backgroundColor: Colors.transparent,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 5),
                    SvgPicture.asset('assets/svg/icon_next.svg'),
                    const SizedBox(width: 5),
                    Text(
                      '${dateFormatTime(startDate)}〜',
                      style: const TextStyle(
                        color: ColorLive.YELLOW,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                const Divider(
                  height: 2,
                  thickness: 1,
                  color: Colors.white,
                  endIndent: 10,
                ),
                Container(
                  height: 20,
                  child: liverName.length > 9
                      ? Marquee(
                          text: liverName + '  ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          pauseAfterRound: const Duration(seconds: 3),
                        )
                      : Text(
                          liverName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
