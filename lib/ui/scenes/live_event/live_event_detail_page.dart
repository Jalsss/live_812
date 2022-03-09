import 'dart:io';

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/usecase/live_event_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/live_event/live_event_detail_member_page.dart';
import 'package:live812/ui/scenes/live_event/live_event_detail_overview_page.dart';
import 'package:live812/ui/scenes/live_event/live_event_detail_prize_page.dart';
import 'package:live812/ui/scenes/live_event/live_event_detail_ranking_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/indicator_view.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:live812/utils/widget/primary_gray_button.dart';
import 'package:provider/provider.dart';

class LiveEventDetailPage extends StatefulWidget {
  const LiveEventDetailPage({
    @required this.liveEvent,
  });

  final LiveEvent liveEvent;

  @override
  _LiveEventDetailPageState createState() => _LiveEventDetailPageState();
}

class _LiveEventDetailPageState extends State<LiveEventDetailPage> {
  /// エントリーできるかどうか.
  bool _canEntry = false;

  /// エントリーしているかどうか.
  bool _isEntry = false;

  /// フォローしているかどうか.
  bool _isFollow = false;

  /// 戻った画面を更新をするかどうか.
  bool _isRefresh = true;

  List _tabs = <Tab>[];
  List _tabBarView = <Widget>[];

  @override
  void initState() {
    super.initState();

    final userModel = Provider.of<UserModel>(context, listen: false);
    _canEntry = userModel.isLiver &&
        (widget.liveEvent.status == LiveEventStatus.wanted) &&
        (!widget.liveEvent.inviteOnly);
    _isEntry = widget.liveEvent.isJoined;
    _isFollow = widget.liveEvent.isFollowed;
    // 概要を追加.
    _tabs.add(Tab(text: '概要'));
    _tabBarView.add(LiveEventDetailOverViewPage(
      liveEvent: widget.liveEvent,
    ));

    // ランキングを追加.
    if (widget.liveEvent.isRanking) {
      _tabs.add(Tab(text: 'ランキング'));
      _tabBarView.add(LiveEventDetailRankingPage(
        liveEvent: widget.liveEvent,
      ));
    }
    // プライズを追加.
    if (widget.liveEvent.isPrize) {
      _tabs.add(Tab(text: 'プライズ'));
      _tabBarView.add(LiveEventDetailPrizePage(
        liveEvent: widget.liveEvent,
      ));
    }
    // 参加者を追加.
    _tabs.add(Tab(text: '参加者'));
    _tabBarView.add(LiveEventDetailMemberPage(
      liveEvent: widget.liveEvent,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.liveEvent.name),
          centerTitle: true,
          backgroundColor: ColorLive.MAIN_BG,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset("assets/svg/backButton.svg"),
            onPressed: () {
              Navigator.pop(context, _isRefresh);
            },
          ),
          actions: [
            Container(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: _isFollow
                    ? SvgPicture.asset('assets/svg/icon_favo01.svg')
                    : SvgPicture.asset('assets/svg/icon_favo01_active.svg'),
                color: ColorLive.BLUE,
                onPressed: () async {
                  await _onTapLiveEventFollow(context: context);
                },
              ),
            ),
          ],
        ),
        backgroundColor: ColorLive.MAIN_BG,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ButtonsTabBar(
                  duration: 100,
                  backgroundColor: Colors.white,
                  unselectedBackgroundColor: ColorLive.MAIN_BG,
                  labelStyle: const TextStyle(
                    color: ColorLive.MAIN_BG,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    color: ColorLive.C99,
                    fontSize: 12,
                  ),
                  borderWidth: 1,
                  borderColor: Colors.white,
                  unselectedBorderColor: ColorLive.C99,
                  radius: 20,
                  height: 40,
                  tabs: _tabs,
                ),
              ),
              const Divider(
                color: ColorLive.BORDER2,
                indent: 10,
                endIndent: 10,
              ),
              Expanded(
                child: TabBarView(children: _tabBarView),
              ),
              if (_canEntry)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        left: 80,
                        top: 10,
                        right: 80,
                      ),
                      child: _isEntry
                          ? PrimaryGrayButton(
                              text: '応募を取り消す',
                              onPressed: () async {
                                await onTapEventEntry(context);
                              },
                              height: 40,
                              round: true,
                            )
                          : PrimaryButton(
                              text: '応募する',
                              onPressed: () async {
                                await onTapEventEntry(context);
                              },
                              height: 40,
                              round: true,
                            ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      child: Center(
                        child: const Text(
                          '※応募を取り消せる期間は、募集期間中のみとなります',
                          style: TextStyle(
                            color: const Color(0xFFD3497A),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// イベント参加/参加解除.
  Future onTapEventEntry(BuildContext context) async {
    String errorMessage = '';
    IndicatorView.show(context);
    try {
      _isRefresh = true;
      if (!_isEntry) {
        // イベント参加.
        await LiveEventUseCase.postLiveEventEntry(
          context,
          widget.liveEvent.id,
        );
        _isEntry = true;
      } else {
        // イベント参加解除.
        await LiveEventUseCase.deleteLiveEventEntry(
          context,
          widget.liveEvent.id,
        );
        _isEntry = false;
      }
    } on HttpException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    }
    IndicatorView.hide(context);
    if (errorMessage.isNotEmpty) {
      await showNetworkErrorDialog(context, msg: errorMessage);
      return;
    }
    if (mounted) {
      setState(() {});
    }
  }

  /// イベントフォロー/フォロー解除ボタンをタップ.
  Future _onTapLiveEventFollow({
    BuildContext context,
  }) async {
    _isRefresh = true;
    bool success = false;
    String errorMessage = '';
    IndicatorView.show(context);
    try {
      if (_isFollow) {
        // イベントフォロー解除.
        success = await LiveEventUseCase.deleteLiveEventFollow(
          context,
          widget.liveEvent.id,
        );
      } else {
        // イベントフォロー.
        success = await LiveEventUseCase.postLiveEventFollow(
          context,
          widget.liveEvent.id,
        );
      }
    } on HttpException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    }
    IndicatorView.hide(context);
    if ((success == null) || (errorMessage.isNotEmpty)) {
      await showNetworkErrorDialog(context, msg: errorMessage);
      return;
    }
    _isFollow = !_isFollow;
    if (mounted) {
      setState(() {});
    }
    Flushbar(
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: Colors.blue[300],
      ),
      message: _isFollow ? 'フォローしました' : 'フォローを解除しました',
      duration: const Duration(milliseconds: 2000),
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
    )..show(context);
  }
}
