import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:live812/domain/model/withdraw/benefit_log.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/user/liver/withdraw_dialog.dart';
import 'package:live812/utils/comma_format.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';

class LiverWithdrawPage extends StatefulWidget {
  final int benefit;

  LiverWithdrawPage(this.benefit);

  @override
  LiverWithdrawPageState createState() => LiverWithdrawPageState();
}

class LiverWithdrawPageState extends State<LiverWithdrawPage> {
  List<BenefitLog> _list;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _requestBenefitLog();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.WITHDRAW_REQUEST,
      titleColor: Colors.white,
      isLoading: _isLoading,
      body: DefaultTextStyle(
        style: TextStyle(color: Colors.white),
        child: Column(
          children: <Widget>[
            _divider(),
            _topRow(),
            _divider(),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                color: Colors.black,
                child: _list == null ? Container() : _buildList(_list),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                Lang.WITHDRAW_AMOUNT,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
              Row(
                children: <Widget>[
                  Text(
                    widget.benefit != null ? commaFormat(widget.benefit) : '-',
                    style: TextStyle(
                        color: ColorLive.ORANGE,
                        fontSize: 26,
                        fontFamily: "Roboto"),
                  ),
                  Text(
                    " " + Lang.YEN,
                    style: TextStyle(color: ColorLive.ORANGE, fontSize: 12),
                  ),
                  SizedBox(width: 10),
                  MaterialButton(
                    minWidth: 80,
                    onPressed: !_canWithdraw() ? null :  () {
                      _requestWithdraw();
                    },
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: ColorLive.ORANGE,
                    disabledColor: ColorLive.C555,
                    disabledTextColor: Colors.grey,
                    textColor: Colors.white,
                    child: Text(
                      Lang.DO_WITHDRAW,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '報酬の確定は月末締め翌月５日確定します。' +
                '振込申請は10,000円以上の場合に申請が可能です。' +
                '当月15日までの申請分が翌月末に振込されます。',
            style: TextStyle(fontSize: 11, color: Color(0xffe0e0e0)),
          ),
        ],
      ),
    );
  }

  bool _canWithdraw() {
    return widget.benefit != null && widget.benefit >= Consts.WITHDRAW_AVAILABLE_MINIMUM_AMOUNT;
  }

  Widget _buildList(List<dynamic> list) {
    return ListView(
      padding: EdgeInsets.all(0),
      children: list.map<Widget>((log) {
        return Column(
          children: [
            _divider(),
            _buildRow(log),
          ],
        );
      }).toList() + [
        _divider(),
      ],
    );
  }

  Widget _buildRow(BenefitLog log) {
    final fmtYearMonth = DateFormat('yyyy.MM.dd');
    final fmtYearMonthDay = DateFormat('yyyy.MM.dd');

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(fmtYearMonth.format(log.createDate)),
              ),
              Row(
                children: [
                  Text(
                    commaFormat(log.benefit ?? 0),
                    style: TextStyle(
                      color: log.benefit >= 0 ? ColorLive.ORANGE : ColorLive.RED,
                      fontSize: 22,
                      fontFamily: "Roboto"),
                  ),
                  Text(
                    " " + Lang.YEN,
                    style: TextStyle(
                      color: log.benefit >= 0 ? ColorLive.ORANGE : ColorLive.RED,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          log.benefit >= 0 ? null : Container(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorLive.RED,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Text(
                  '${fmtYearMonthDay.format(log.withdrawEstimateDate)}振込',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ),
          ),
        ].where((w) => w != null).toList(),
      ),
    );
  }

  // 区切り線
  Widget _divider({color: ColorLive.DIVIDER, double height: 0.5}) {
    return Divider(
      color: color,
      height: height,
      thickness: 0.5,
    );
  }

  Future<void> _requestBenefitLog() async {
    final service = BackendService(context);
    setState(() => _isLoading = true);
    final response = await service.getBenefitLog(onlyWithdraw: false);
    setState(() => _isLoading = false);
    if (response?.result == true) {
      final list = new List<BenefitLog>();
      final data = response.getData();
      for (final d in data) {
        list.add(BenefitLog.fromJson(d));
      }
      setState(() => _list = list);
    } else {
      await showNetworkErrorDialog(context, msg: response?.getByKey('msg'));
    }
  }

  Future<void> _requestWithdraw() async {
    final service = BackendService(context);
    setState(() => _isLoading = true);
    final response = await service.postPointWithdraw(10000);
    setState(() => _isLoading = false);
    if (response?.result == true) {
      // TODO: 予定日などを表示
      final estimateDateStr = response.getByKey('withdraw_estimate_date');
      final estimateDate = estimateDateStr == null ? null : DateTime.tryParse(estimateDateStr);
      final dialog = showDialog(
        context: context,
        //barrierDismissible: false,
        builder: (BuildContext context) => WithdrawDialog(estimateDate),
      );
      final updateLog = _requestBenefitLog();  // TODO: リトライ

      await Future.wait([
        dialog,
        updateLog,
      ]);
    } else {
      await showNetworkErrorDialog(context, msg: response?.getByKey('msg'));
    }
  }
}
