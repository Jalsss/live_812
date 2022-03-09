import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/ui/scenes/live_event/live_event_title_label.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/date_format.dart';

class LiveEventListTitle extends StatelessWidget {
  LiveEventListTitle({
    this.liveEvent,
    this.isWanted = false,
    this.onTap,
    this.onTapFollow,
  });

  final LiveEvent liveEvent;
  final bool isWanted;
  final Function onTap;
  final Function onTapFollow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(
          left: 20,
          top: 10,
          right: 20,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    liveEvent.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (c, o, s) {
                      return const Icon(
                        Icons.error,
                        color: Colors.red,
                      );
                    },
                  ),
                ),
              ),
            ),
            Text(
              liveEvent.name,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            LiveEventTitleLabel(
              icon: SvgPicture.asset('assets/svg/icon_hold.svg'),
              child: const Text(
                '開催日時',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5, bottom: 15),
              child: Text(
                '${dateFormatLiveEvent(liveEvent.startDate)}〜${dateFormatLiveEvent(liveEvent.endDate)}',
                style: const TextStyle(color: const Color(0xFFACB1B4), fontSize: 13),
              ),
            ),
            if (isWanted)
              LiveEventTitleLabel(
                icon: SvgPicture.asset('assets/svg/icon_participant.svg'),
                child: const Text(
                  '参加募集期限',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            if (isWanted)
              Container(
                padding: const EdgeInsets.only(top: 5, bottom: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            '${dateFormatLiveEvent(liveEvent.requestLimitDate)}',
                            style: const TextStyle(
                              color: ColorLive.YELLOW,
                              fontSize: 13,
                            ),
                          ),
                          const Text(
                            'まで',
                            style: TextStyle(
                              color: Color(0xFFACB1B4),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(liveEvent.ownerImageUrl),
                  onBackgroundImageError: (d, s) {},
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    liveEvent.ownerNickname,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ColorLive.C99,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 26.0,
                  child: RaisedButton(
                    onPressed: onTapFollow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.zero,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: liveEvent.isFollowed
                            ? ColorLive.C99
                            : ColorLive.BLUE,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 160.0,
                          minHeight: 26.0,
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/svg/icon_follow.svg'),
                            const SizedBox(width: 5),
                            Text(
                              liveEvent.isFollowed
                                  ? 'フォロー&通知をやめる'
                                  : 'イベントをフォロー&通知',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
