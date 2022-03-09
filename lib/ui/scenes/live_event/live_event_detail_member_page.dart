import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/domain/model/live/live_event_member.dart';
import 'package:live812/domain/model/live/room_info.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/live_event_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/live/live_view_page.dart';
import 'package:live812/ui/scenes/live_event/live_event_title_label.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/route/fade_route.dart';

class LiveEventDetailMemberPage extends StatefulWidget {
  const LiveEventDetailMemberPage({
    @required this.liveEvent,
  });

  final LiveEvent liveEvent;

  @override
  _LiveEventDetailMemberPageState createState() =>
      _LiveEventDetailMemberPageState();
}

class _LiveEventDetailMemberPageState extends State<LiveEventDetailMemberPage> {
  List<LiveEventMember> _members;

  @override
  void initState() {
    super.initState();

    Future(() {
      if (mounted) {
        _requestMember(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_members == null) {
      return Container();
    }

    // リレーイベント.
    if (widget.liveEvent.eventType == LiveEventType.relay) {
      return ListView.builder(
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return _LiveEventRelayMemberItem(
            member: member,
            index: index,
            length: _members.length,
            onTap: () async {
              await _onTap(context, member);
            },
          );
        },
      );
    }

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = 3;
    final itemWidth = width / crossAxisCount;
    final imageSize = itemWidth - 30;
    final childAspectRatio = itemWidth / (imageSize + 50);
    List<LiveEventMember> listLive = [];
    List<LiveEventMember> listInfo = [];
    _members.forEach((element) {
      if(element.isOnAir()) {
        listLive.add(element);
      } else {
        listInfo.add(element);
      }
    });
    return SingleChildScrollView(
        child: Column(
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Center(
                child: listLive.length > 0 ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/svg/electric.svg'),
                      SizedBox(width: 5),
                      Text(
                        '只今配信中',
                        style: TextStyle(color: Colors.white),
                      )
                    ]) : SizedBox(),
              ),
              SizedBox(height: 10,),

              Wrap(
                spacing: 10,
                children: List.generate(listLive.length, (i) {
                  return _LiveEventMemberGridItem(
                    member: listLive[i],
                    imageSize: imageSize,
                    onTap: () async {
                      await _onTap(context, listLive[i]);
                    },
                  );
                }).toList(),
              ),
              if(listLive.length > 0)
                SizedBox(height: 10,),
              if(listLive.length > 0)
                Divider(color: Color(0xff868a95),height: 1,indent: 15,endIndent: 15,),
              if(listLive.length > 0)
                SizedBox(height: 10,),
              Wrap(
                spacing: 15,
                children: List.generate(listInfo.length, (i) {
                  return _LiveEventMemberGridItem(
                    member: listInfo[i],
                    imageSize: imageSize,
                    onTap: () async {
                      await _onTap(context, listInfo[i]);
                    },
                  );
                }).toList(),
              )
            ]
        )
    );
  }

  /// イベント参加者情報の取得.
  Future _requestMember(BuildContext context) async {
    String errorMessage = '';
    try {
      _members = await LiveEventUseCase.requestLiveEventMember(
        context,
        widget.liveEvent.id,
      );
    } on HttpException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    }

    if ((_members == null) || (errorMessage.isNotEmpty)) {
      await showNetworkErrorDialog(context, msg: errorMessage);
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// メンバーアイコンを押下.
  Future _onTap(
    BuildContext context,
    LiveEventMember member,
  ) async {
    if (member.isOnAir()) {
      // ライブ配信中なので視聴画面へ.
      List<RoomInfoModel> list;
      String errorMessage = '';
      try {
        final service = BackendService(context);
        final response = await service.getStreamingLiveRoom(
          liveId: member.liveId,
        );

        if (response?.result == true) {
          list = [];
          for (final json in response.getData()) {
            list.add(RoomInfoModel.fromJson(json));
          }
        }
      } on HttpException catch (e) {
        errorMessage = e.message;
      } catch (e) {
        errorMessage = e.toString();
      }
      if (list?.isNotEmpty != true) {
        await showInformationDialog(
          context,
          title: '配信終了',
          msg: '配信終了しました',
        );
      } else if (errorMessage.isNotEmpty) {
        await showNetworkErrorDialog(context, msg: errorMessage);
      } else {
        // リレー配信の場合.
        final roomInfo = list[0];
        if (roomInfo.eventType == LiveEventType.relay) {
          if (!roomInfo.isOnAir()) {
            await showInformationDialog(
              context,
              title: 'リレー配信',
              msg: '開始予定時刻 : ${dateFormatTime(roomInfo.liveStartDate)}',
            );
            return;
          }
        }
        // 視聴画面へ.
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return LiveViewPage(list, 0);
        }));
      }
    } else {
      // プロフィール画面へ.
      await Navigator.push(
        context,
        FadeRoute(
          builder: (context) => ProfileViewPage(userId: member.id),
        ),
      );
    }
    await _requestMember(context);
  }
}

class _LiveEventMemberGridItem extends StatelessWidget {
  const _LiveEventMemberGridItem({
    this.member,
    this.imageSize,
    this.onTap,
  });

  final LiveEventMember member;
  final double imageSize;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 3 - 10,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(member.imageUrl),
                      fit: BoxFit.fitHeight,
                      onError: (d, s) {
                        print("$d");
                      },
                    ),
                  ),
                ),
                if (member.isOnAir())
                  Image.asset(
                    'assets/gif/broadcasting.gif',
                    width: imageSize,
                    height: imageSize,
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                member.nickname ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveEventRelayMemberItem extends StatelessWidget {
  const _LiveEventRelayMemberItem({
    this.member,
    this.index,
    this.length,
    this.onTap,
  });

  final LiveEventMember member;
  final int index;
  final int length;
  final Function onTap;

  final List<Color> _colors = const [
    const Color(0xC0FF5A5A),
    const Color(0xC0FFA750),
    const Color(0xC0FCDF00),
    const Color(0xC0A2E50C),
    const Color(0xC049BE26),
    const Color(0xC030D6B5),
    const Color(0xC069CCFC),
    const Color(0xC03466EF),
    const Color(0xC0A261ED),
    const Color(0xC0FF60B0),
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Stack(
              children: [
                SvgPicture.asset(
                  _relayIconAssetName(index, length),
                  width: 100,
                  height: 100,
                ),
                if (member.isOnAir())
                  Container(
                    width: 100,
                    height: 100,
                    child: Center(
                      child: Image.asset(
                        'assets/gif/broadcasting.gif',
                        width: 55,
                        height: 55,
                        repeat: ImageRepeat.repeat,
                      ),
                    ),
                  ),
                Container(
                  width: 100,
                  height: 100,
                  child: Center(
                    child: Text(
                      '${dateFormatTime(member.liveStartDate)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                height: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _relayBackgroundColor(index),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(member.imageUrl),
                              fit: BoxFit.cover,
                              onError: (d, s) {
                                print("$d");
                              },
                            ),
                          ),
                        ),
                        if (member.isOnAir())
                          Image.asset(
                            'assets/gif/broadcasting.gif',
                            width: 60,
                            height: 60,
                            repeat: ImageRepeat.repeat,
                          ),
                      ],
                    ),
                    const SizedBox(width: 15),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.nickname,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const LiveEventTitleLabel(
                            child: Text(
                              '配信予定時刻',
                              style: TextStyle(fontSize: 10),
                            ),
                            color: Colors.white,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${dateFormatLiveEventRelay(member.liveStartDate)}〜${dateFormatLiveEventRelay(member.liveEndDate)}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 画像名.
  String _relayIconAssetName(int index, int length) {
    if (index == 0) {
      return 'assets/svg/icon_relay_start.svg';
    } else if (index == (length - 1)) {
      return 'assets/svg/icon_relay_end.svg';
    } else {
      return 'assets/svg/icon_relay_middle.svg';
    }
  }

  /// 背景色.
  Color _relayBackgroundColor(int index) {
    int c = index % _colors.length;
    return _colors[c];
  }
}
