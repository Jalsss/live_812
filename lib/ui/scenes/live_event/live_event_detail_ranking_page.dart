import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:live812/domain/model/live/gift_info.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/domain/model/live/live_event_ranking.dart';
import 'package:live812/domain/usecase/live_event_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_gift.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class LiveEventDetailRankingPage extends StatefulWidget {
  const LiveEventDetailRankingPage({
    @required this.liveEvent,
  });

  final LiveEvent liveEvent;

  @override
  _LiveEventDetailRankingPageState createState() =>
      _LiveEventDetailRankingPageState();
}

class _LiveEventDetailRankingPageState
    extends State<LiveEventDetailRankingPage> {
  LiveEventRanking _ranking;

  final _rankGiftList = <GiftInfoModel>[];

  @override
  void initState() {
    super.initState();
    Future(() {
      if (mounted) {
        _requestRanking(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ranking == null) {
      return Container();
    }

    return Container(
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Center(
              child: Text(
                _ranking.name,
                style: const TextStyle(
                  color: ColorLive.ORANGE,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          if (_ranking.isRankingGift)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                    color: ColorLive.BLUE_BG,
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Text(
                        '集計対象ギフト',
                        style: TextStyle(
                          color: ColorLive.C99,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 15,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _rankGiftList
                            .map((e) => _LiveEventRankingTargetGift(
                                  giftId: e.imageId,
                                  coin: e.point,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: 260),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                children: [
                  _ranking.users.length >= 2
                      ? _LiveEventRankingTopUser(
                          rank: 2,
                          userName: _ranking.users[1].nickname,
                          imageUrl: _ranking.users[1].imageUrl,
                          coin: _ranking.users[1].coin,
                        )
                      : Expanded(child: Container()),
                  _ranking.users.length >= 1
                      ? _LiveEventRankingTopUser(
                          rank: 1,
                          userName: _ranking.users[0].nickname,
                          imageUrl: _ranking.users[0].imageUrl,
                          coin: _ranking.users[0].coin,
                        )
                      : Expanded(child: Container()),
                  _ranking.users.length >= 3
                      ? _LiveEventRankingTopUser(
                          rank: 3,
                          userName: _ranking.users[2].nickname,
                          imageUrl: _ranking.users[2].imageUrl,
                          coin: _ranking.users[2].coin,
                        )
                      : Expanded(child: Container()),
                ],
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount:
                _ranking.users.length - 3 > 0 ? _ranking.users.length - 3 : 0,
            itemBuilder: (context, index) {
              final user = _ranking.users[index + 3];
              return _LiveEventRankingUser(
                userName: user.nickname,
                imageUrl: user.imageUrl,
                coin: user.coin,
                rank: index + 3 + 1,
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: ColorLive.BORDER2,
                thickness: 1,
              );
            },
          ),
        ],
      ),
    );
  }

  /// イベントランキング情報を取得.
  Future _requestRanking(BuildContext context) async {
    String errorMessage = '';
    try {
      _ranking = await LiveEventUseCase.requestLiveEventRanking(
        context,
        widget.liveEvent.id,
      );
    } on HttpException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    }
    if ((_ranking == null) || (errorMessage.isNotEmpty)) {
      await showNetworkErrorDialog(context, msg: errorMessage);
      return;
    }
    // ギフトデータの取得.
    _rankGiftList.clear();
    if ((_ranking.rankingGiftCSV != null) &&
        (_ranking.rankingGiftCSV.isNotEmpty)) {
      final list = await BottomSheetGift.requestGiftInfo(null, null);
      final ids =
          _ranking.rankingGiftCSV.split(',').map((e) => int.parse(e)).toList();
      _rankGiftList.addAll(
        list.where((e) => ids.indexOf(e.id) >= 0).toList(),
      );
    }
    if (mounted) {
      setState(() {});
    }
  }
}

class _LiveEventRankingTargetGift extends StatelessWidget {
  const _LiveEventRankingTargetGift({
    this.giftId,
    this.coin,
  });

  final int giftId;
  final int coin;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Image.asset(
                'assets/images/gift$giftId.png',
                height: 100,
                width: 100,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/svg/icon_coin.svg'),
              const SizedBox(width: 5),
              Text(
                formatter.format(coin),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveEventRankingTopUser extends StatelessWidget {
  const _LiveEventRankingTopUser({
    this.userName,
    this.imageUrl,
    this.coin,
    this.rank,
  });

  final String userName;
  final String imageUrl;
  final int coin;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    return Expanded(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rank != 1) const SizedBox(height: 100),
            Stack(
              overflow: Overflow.visible,
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: rank == 1 ? -34 : -24,
                  child: SvgPicture.asset('assets/svg/rank_n-$rank.svg'),
                ),
                Container(
                  width: rank == 1 ? 100 : 85,
                  height: rank == 1 ? 100 : 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: rank == 1
                          ? const Color(0xFFFEDD51)
                          : rank == 2
                              ? const Color(0xFFC0C5C8)
                              : const Color(0xFFDEAB8D),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      imageUrl,
                      errorBuilder: (b, o, s) {
                        return const Icon(Icons.error);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/svg/icon_coin.svg'),
                const SizedBox(width: 5),
                Text(
                  formatter.format(coin),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Roboto',
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

class _LiveEventRankingUser extends StatelessWidget {
  const _LiveEventRankingUser({
    this.userName,
    this.imageUrl,
    this.coin,
    this.rank,
  });

  final String userName;
  final String imageUrl;
  final int coin;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            child: Text(
              '$rank位',
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorLive.C99, fontSize: 10),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(imageUrl),
            onBackgroundImageError: (d, s) {},
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              userName,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          SvgPicture.asset(
            'assets/svg/icon_coin.svg',
            width: 15,
            height: 15,
          ),
          const SizedBox(width: 5),
          Container(
            width: 60,
            child: Text(
              formatter.format(coin),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
