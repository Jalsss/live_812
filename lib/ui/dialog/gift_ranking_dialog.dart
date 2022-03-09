import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/profile_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/safe_network_image.dart';

class GiftRankingDialog extends StatefulWidget {
  final String liverId;

  GiftRankingDialog({@required this.liverId});

  @override
  _GiftRankingDialogState createState() => _GiftRankingDialogState();
}

class _GiftRankingDialogState extends State<GiftRankingDialog> {
  List<UserModel> _streamRanking;
  List<UserModel> _monthlyRanking;

  @override
  void initState() {
    super.initState();
    _requestLiveGiftRanking(context);
    _requestLiveGiftMonthlyRanking(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      child: _dialogContent(context),
    );
  }

  Widget _dialogContent(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: ColorLive.BORDER4,
            ),
            padding: EdgeInsets.only(bottom: 5, top: 5),
            child: TabBar(
              unselectedLabelColor: ColorLive.MAIN_BG,
              unselectedLabelStyle: TextStyle(fontSize: 16),
              indicatorColor: ColorLive.ORANGE,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: ColorLive.ORANGE,
              labelStyle:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              tabs: <Widget>[
                Tab(text: Lang.LIVE_THIS),
                Tab(text: Lang.LIVE_MONTHLY),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _buildRankingTable(_streamRanking),
                _buildRankingTable(_monthlyRanking),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingTable(List<UserModel> list) {
    if (list?.isNotEmpty != true)
      return Container();

    final border = BorderSide(color: ColorLive.BORDER4.withAlpha(400));
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Table(
          border: TableBorder(
            horizontalInside: border,
            top: border,
            bottom: border,
          ),
          columnWidths: {0: IntrinsicColumnWidth(), 1: FlexColumnWidth(), 2: IntrinsicColumnWidth()},
          children: List.generate(list.length, (index) {
            return _buildGiftItem(index, list[index]);
          }),
        ),
      ),
    );
  }

  TableRow _buildGiftItem(int rank, UserModel userModel) {
    return TableRow(
      children: <Widget>[
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${rank + 1}",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 12, top: 6, bottom: 6, right: 8),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  shape: BoxShape.circle,
                ),
                child: RawMaterialButton(
                  elevation: 2,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    radius: 15.0,
                    backgroundImage: SafeNetworkImage(
                      BackendService.getUserThumbnailUrl(userModel.id, small: true)),
                    backgroundColor: Colors.white.withAlpha(100),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ProfileDialog(userId: userModel.id),
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                  child: Text(
                    userModel.nickname ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                '${userModel.point}',
                style: TextStyle(
                  fontFamily: "Roboto",
                  color: Colors.black,
                  fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 4),
              SvgPicture.asset(
                "assets/svg/gift.svg",
                height: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _requestLiveGiftRanking(BuildContext context) async {
    final service = BackendService(context);
    final response = await service.getRankLiveGift(widget.liverId);
    if (response?.result == true) {
      final list = List<UserModel>();
      final data = response.getData();
      for (final d in data) {
        list.add(UserModel.fromJson(d));
      }
      setState(() => _streamRanking = list);
    }
  }

  Future<void> _requestLiveGiftMonthlyRanking(BuildContext context) async {
    final service = BackendService(context);
    final response = await service.getRankLiveGiftMonthly(widget.liverId);
    if (response != null && response.result) {
      final list = List<UserModel>();
      final data = response.getData();
      for (final d in data) {
        list.add(UserModel.fromJson(d));
      }
      setState(() => _monthlyRanking = list);
    }
  }
}