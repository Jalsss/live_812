import 'dart:io';

import 'package:flutter/material.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/domain/model/live/live_event_prize.dart';
import 'package:live812/domain/usecase/live_event_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class LiveEventDetailPrizePage extends StatefulWidget {
  const LiveEventDetailPrizePage({
    @required this.liveEvent,
  });

  final LiveEvent liveEvent;

  @override
  _LiveEventDetailPrizePageState createState() =>
      _LiveEventDetailPrizePageState();
}

class _LiveEventDetailPrizePageState extends State<LiveEventDetailPrizePage> {
  LiveEventPrize _prize;

  @override
  void initState() {
    super.initState();
    Future(() {
      if (mounted) {
        _requestPrize(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_prize == null) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ListView(
        children: [
          const Text(
            'プライズ内容',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: ColorLive.BLUE_BG,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 15),
                  child: Text(
                    _prize.description,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// イベントプライズ情報を取得.
  Future _requestPrize(BuildContext context) async {
    String errorMessage = '';
    try {
      _prize = await LiveEventUseCase.requestLiveEventPrize(
        context,
        widget.liveEvent.id,
      );
    } on HttpException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    }
    if ((_prize == null) || (errorMessage.isNotEmpty)) {
      await showNetworkErrorDialog(context, msg: errorMessage);
      return;
    }
    if (mounted) {
      setState(() {});
    }
  }
}
