import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/domain/usecase/live_event_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/live_event/live_event_list_tile.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/indicator_view.dart';
import 'package:live812/utils/route/fade_route.dart';

import 'live_event_detail_page.dart';

class LiveEventClosedPage extends StatefulWidget {
  @override
  _LiveEventClosedPageState createState() => _LiveEventClosedPageState();
}

class _LiveEventClosedPageState extends State<LiveEventClosedPage> {
  List<LiveEvent> _liveEventList = [];

  @override
  void initState() {
    super.initState();
    Future(() {
      if (mounted) {
        _requestClosedLiveEvent(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: 80,
      ),
      itemBuilder: (context, index) {
        final liveEvent = _liveEventList[index];
        return LiveEventListTitle(
          liveEvent: liveEvent,
          onTap: () async {
            await _onTapLiveEvent(
              context: context,
              liveEvent: liveEvent,
            );
          },
          onTapFollow: () async {
            await _onTapLiveEventFollow(
              context: context,
              liveEvent: liveEvent,
            );
          },
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 2,
          color: ColorLive.BORDER2,
          indent: 20,
          endIndent: 20,
        );
      },
      itemCount: _liveEventList.length,
    );
  }

  /// イベント一覧を取得.
  Future<void> _requestClosedLiveEvent(BuildContext context) async {
    try {
      _liveEventList = await LiveEventUseCase.requestClosedLiveEvent(context);
      if (mounted) {
        setState(() {});
      }
    } on HttpException catch (e) {
      await showNetworkErrorDialog(context, msg: e.message);
    } catch (e) {
      await showNetworkErrorDialog(context, msg: e.toString());
    }
  }

  /// イベントをタップ.
  Future _onTapLiveEvent({BuildContext context, LiveEvent liveEvent}) async {
    LiveEvent detail;
    String errorMessage = '';
    IndicatorView.show(context);
    try {
      detail = await LiveEventUseCase.requestLiveEventOverView(
        context,
        liveEvent.id,
      );
    } on HttpException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    }
    IndicatorView.hide(context);
    if ((detail == null) || (errorMessage.isNotEmpty)) {
      await showNetworkErrorDialog(context, msg: errorMessage);
      return;
    }
    bool refresh = await Navigator.push(
      context,
      FadeRoute(
        builder: (context) => LiveEventDetailPage(
          liveEvent: detail,
        ),
      ),
    );
    if (refresh == true) {
      await _requestClosedLiveEvent(context);
    }
  }

  /// イベントフォロー/フォロー解除ボタンをタップ.
  Future _onTapLiveEventFollow({
    BuildContext context,
    LiveEvent liveEvent,
  }) async {
    bool success = false;
    String errorMessage = '';
    IndicatorView.show(context);
    try {
      if (liveEvent.isFollowed) {
        // イベントフォロー解除.
        success = await LiveEventUseCase.deleteLiveEventFollow(
          context,
          liveEvent.id,
        );
      } else {
        // イベントフォロー.
        success = await LiveEventUseCase.postLiveEventFollow(
          context,
          liveEvent.id,
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
    await _requestClosedLiveEvent(context);
  }
}
