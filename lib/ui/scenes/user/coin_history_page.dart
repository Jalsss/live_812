import 'package:flutter/material.dart';
import 'package:live812/domain/model/iap/iap_info.dart';
import 'package:live812/domain/model/user/coin_history.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/comma_format.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/safe_network_image.dart';
import 'package:provider/provider.dart';

// コイン履歴（獲得/チャージ、使用履歴）
class CoinHistoryPage extends StatefulWidget {
  @override
  CoinHistoryPageState createState() => CoinHistoryPageState();
}

class CoinHistoryPageState extends State<CoinHistoryPage> {
  CoinHistory _history;
  bool _isLoading = false;
  bool _resolvingPendingIap = false;

  static String _formatDate(String dateStr) {
    dateStr ??= '';
    if (dateStr.length > 10) dateStr = dateStr.substring(0, 10);
    return dateStr.replaceAll('-', '.');
  }

  @override
  void initState() {
    super.initState();
    _requestCoinHistory();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.HISTORY,
      titleColor: Colors.white,
      isLoading: _isLoading || _resolvingPendingIap,
      body: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Column(
          children: <Widget>[
            Divider(
              height: 1,
              thickness: 1,
              color: ColorLive.BLUE_BG,
            ),
            Container(
              decoration: BoxDecoration(
                color: ColorLive.MAIN_BG,
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      Lang.BALANCE,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    _history != null ? commaFormat(_history.sum) : '-',
                    style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 26,
                        color: ColorLive.ORANGE),
                  ),
                  Text(
                    " " + Lang.COIN,
                    style: TextStyle(color: ColorLive.ORANGE, fontSize: 12),
                  ),
                  Table(
                    defaultColumnWidth: IntrinsicColumnWidth(),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      _balanceConstituent('無償', _history?.free),
                      _balanceConstituent('有償', _history?.paid),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: const Text(
                      '30日以内に期限切れとなるコイン',
                      style: TextStyle(
                        color: const Color(0xFFB6B6B6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    _history != null
                        ? commaFormat(_history.monthlyExpirePoint)
                        : '-',
                    style: const TextStyle(
                      color: const Color(0xFFB6B6B6),
                      fontSize: 12,
                      fontFamily: "Roboto",
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: ColorLive.BLUE_BG,
            ),
            Container(
              decoration: BoxDecoration(
                color: ColorLive.MAIN_BG,
              ),
              padding: EdgeInsets.only(bottom: 5, top: 5),
              child: TabBar(
                unselectedLabelColor: ColorLive.BORDER2,
                unselectedLabelStyle: TextStyle(fontSize: 16),
                indicatorColor: ColorLive.BORDER2,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                tabs: <Widget>[
                  Tab(
                    text: Lang.EARNING_CHARGING,
                  ),
                  Tab(
                    text: Lang.USAGE_HIS,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 5),
                color: ColorLive.C26,
                child: TabBarView(
                  children: <Widget>[
                    _history == null
                        ? Container()
                        : _history.entries.isEmpty
                            ? _buildNoHistory()
                            : _buildChargeHistory(),
                    _history == null
                        ? Container()
                        : _history.entries.isEmpty
                            ? _buildNoHistory()
                            : ListView(
                                children: _history.entries
                                    .where((entry) => (entry.point < 0) && !entry.isExpired)
                                    .map((entry) => _usageItem(context, entry))
                                    .toList(),
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

  Widget _buildChargeHistory() {
    List<Widget> children = _history.entries
        .where((entry) => (entry.point > 0) || (entry.isExpired))
        .map((entry) => _earningItem(context, entry))
        .toList();

    return ListView(
      children: children,
    );
  }

  Widget _buildNoHistory() {
    return Text(
      '履歴はまだありません',
      style: TextStyle(color: Colors.white),
    );
  }

  TableRow _balanceConstituent(String typeStr, int value) {
    return TableRow(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: ColorLive.ORANGE,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Text(typeStr),
        ),
        Text(
          value != null ? commaFormat(value) : '-',
          style: TextStyle(
              fontFamily: "Roboto",
              color: ColorLive.ORANGE,
              fontSize: 16,
              fontWeight: FontWeight.w700),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildPendingIapInfo(IapInfo iapInfo) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _formatDate(dateFormat(iapInfo.createdAt)),
                  style: TextStyle(color: Colors.white, fontFamily: "Roboto"),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text('処理中'),
              ),
              Text(
                iapInfo?.coin == null ? '---' : commaFormat(iapInfo.coin),
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: "Roboto",
                    color: ColorLive.ORANGE,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 5),
              Text(
                Lang.COIN,
                style: TextStyle(
                  color: ColorLive.ORANGE,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
            height: 1,
            thickness: 1,
            color: ColorLive.BLUE_BG.withAlpha(60),
          ),
        ),
      ],
    );
  }

  Widget _earningItem(context, CoinHistoryEntry data) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _formatDate(data?.createDate),
                  style: TextStyle(color: Colors.white, fontFamily: "Roboto"),
                ),
              ),
              data.isExpired
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
                        color: const Color(0xFF898B8E),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: const Text('期限切れ'),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: const BoxDecoration(
                        color: ColorLive.ORANGE,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Text(data.purchased ? '購入' : '付与'),
                    ),
              Text(
                commaFormat(data?.point ?? 0),
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontFamily: "Roboto",
                    color: ColorLive.ORANGE,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 5),
              Text(
                Lang.COIN,
                style: TextStyle(
                  color: ColorLive.ORANGE,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
            height: 1,
            thickness: 1,
            color: ColorLive.BLUE_BG.withAlpha(60),
          ),
        ),
      ],
    );
  }

  Widget _usageItem(BuildContext context, CoinHistoryEntry data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: 7, top: 11.5),
          child: Text(
            _formatDate(data?.createDate),
            style: TextStyle(color: Colors.white, fontFamily: "Roboto"),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.circle),
                child: RawMaterialButton(
                  elevation: 2,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    radius: 15.0,
                    backgroundImage: SafeNetworkImage(
                        BackendService.getUserThumbnailUrl(data.senderId,
                            small: true)),
                    backgroundColor: Colors.white.withAlpha(100),
                  ),
                  onPressed: () {},
                ),
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  data.sender ?? '--',
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 7),
              Text(
                commaFormat(data.point),
                style: TextStyle(
                    fontFamily: "Roboto",
                    color: ColorLive.ORANGE,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 5),
              Text(
                Lang.COIN,
                style: TextStyle(
                  color: ColorLive.ORANGE,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 9.5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Divider(
            height: 1,
            thickness: 1,
            color: ColorLive.BLUE_BG.withAlpha(60),
          ),
        ),
      ],
    );
  }

  Future<void> _requestCoinHistory() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);
    setState(() => _isLoading = true);
    final coinHistory = await service.getCoinHistory(userModel.id);
    setState(() {
      _isLoading = false;
      _history = coinHistory;
    });
  }
}
