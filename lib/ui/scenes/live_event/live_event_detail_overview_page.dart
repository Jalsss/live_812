import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/ui/scenes/live_event/live_event_title_label.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:provider/provider.dart';

class LiveEventDetailOverViewPage extends StatelessWidget {
  const LiveEventDetailOverViewPage({
    @required this.liveEvent,
  });

  final LiveEvent liveEvent;

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final isLiver = userModel?.isLiver ?? false;
    return Container(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 10,
      ),
      child: ListView(
        children: [
          if (liveEvent.eventType != LiveEventType.none)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  LiveEventTitleLabel(
                    color: const Color(0xFFFEF36C),
                    icon: SvgPicture.asset(
                      liveEvent.eventTypeAssetName(),
                      color: ColorLive.MAIN_BG,
                    ),
                    child: Text(
                      liveEvent.eventTypeName(),
                      style: const TextStyle(
                        color: ColorLive.MAIN_BG,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  liveEvent.imageUrl,
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              color: ColorLive.BLUE_BG,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LiveEventTitleLabel(
                  child: Text(
                    '主催者',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  child: Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(liveEvent.ownerImageUrl),
                                onError: (d, s) {},
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await _onTapOwner(
                              context: context,
                              userId: liveEvent.ownerAccountId,
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 15),
                          child: Text(
                            liveEvent.ownerNickname,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const LiveEventTitleLabel(
                  child: Text(
                    'イベント名',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 15),
                  child: Text(
                    liveEvent.name,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const LiveEventTitleLabel(
                  child: Text(
                    '開催日時',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 15),
                  child: Text(
                    '${dateFormatLiveEvent(liveEvent.startDate)}〜${dateFormatLiveEvent(liveEvent.endDate)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                const LiveEventTitleLabel(
                  child: Text(
                    'イベント内容',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 15),
                  child: Text(
                    liveEvent.description,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                if (isLiver)
                  const LiveEventTitleLabel(
                    child: Text(
                      '募集要項',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                if (isLiver)
                  Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 15),
                    child: Text(
                      liveEvent.guideline,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                if (isLiver)
                  const LiveEventTitleLabel(
                    child: Text(
                      '参加募集期限',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                if (isLiver)
                  Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 15),
                    child: Row(
                      children: [
                        Text(
                          '${dateFormatLiveEvent(liveEvent.requestLimitDate)}',
                          style: const TextStyle(
                              color: ColorLive.YELLOW, fontSize: 13),
                        ),
                        const Text(
                          'まで',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onTapOwner({
    BuildContext context,
    String userId,
  }) async {
    // プロフィール画面へ.
    await Navigator.push(
      context,
      FadeRoute(
        builder: (context) => ProfileViewPage(userId: userId),
      ),
    );
  }
}
