import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/item/PurchaseItem.dart';
import 'package:live812/ui/scenes/user/liver/liver_purchase_details_page.dart';
import 'package:live812/utils/comma_format.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:provider/provider.dart';

// 販売履歴
class LiverHistoryPurchasePage extends StatefulWidget {
  /// 取引中かどうか.
  final bool isTrading;

  LiverHistoryPurchasePage({this.isTrading});

  @override
  LiverHistoryPurchasePageState createState() =>
      LiverHistoryPurchasePageState();
}

class LiverHistoryPurchasePageState extends State<LiverHistoryPurchasePage> {
  bool _isLoading = true;
  List<Purchase> _histories;
  int _monthlySales;
  int _monthlyFee;
  int _monthlyBenefit;
  String _errorMessage;
  bool _pullToRefreshing = false;

  @override
  void initState() {
    super.initState();
    _requestEcItem();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      isLoading: _isLoading && !_pullToRefreshing,
      backgroundColor: ColorLive.MAIN_BG,
      title: widget.isTrading ? Lang.TRADING : Lang.PURCHASE_HISTORY_LIVER,
      titleColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Builder(
          builder: (context) {
            if (_errorMessage != null || _histories == null) {
              return Container(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    _isLoading ? '' : _errorMessage,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.only(top: 0),
              children: _buildHeader() +
                  _histories.map<Widget>((purchase) {
                    return PurchaseItem(
                      purchase: purchase,
                      onTap: () => _onTapItem(purchase),
                      isPurchase: false,
                    );
                  }).toList(),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildHeader() {
    if (widget.isTrading) {
      // 取引中.
      return [];
    } else {
      // 販売履歴.
      return [
        Divider(
          height: 1,
          thickness: 1,
          color: ColorLive.BLUE_BG,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSalesRowTop('今月の売上', _monthlySales),
              _buildSalesRowNext('手数料', _monthlyFee),
              _buildSalesRowNext('利益', _monthlyBenefit),
            ],
          ),
        ),
      ];
    }
  }

  Widget _buildSalesRowTop(String text, int amount) {
    return _buildSalesRow(
      text,
      amount,
      marginLeft: 0,
      iconWidget: Container(
        margin: EdgeInsets.only(top: 4, bottom: 4, right: 12),
        child: SvgPicture.asset(
          "assets/svg/menu/product.svg",
          height: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSalesRowNext(String text, int amount) {
    return _buildSalesRow(
      text,
      amount,
      iconWidget: Container(
        margin: EdgeInsets.only(top: 4, bottom: 4, right: 8),
        child: SvgPicture.asset(
          "assets/svg/menu/list.svg",
          height: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSalesRow(String text, int amount,
      {Widget iconWidget, double marginLeft = 30}) {
    return Container(
      margin: EdgeInsets.only(left: marginLeft, right: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          iconWidget,
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Expanded(
            child: Text(
              commaFormat(amount),
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontFamily: "Roboto",
                  color: ColorLive.ORANGE,
                  fontSize: 24,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            ' 円',
            textAlign: TextAlign.end,
            style: const TextStyle(color: ColorLive.ORANGE, fontSize: 12),
          ),
        ].where((w) => w != null).toList(),
      ),
    );
  }

  Future<void> _onRefresh() async {
    setState(() => _pullToRefreshing = true);
    await _requestEcItem();
    setState(() => _pullToRefreshing = false);
  }

  Future<void> _onTapItem(Purchase purchase) async {
    final result = await Navigator.push(context,
        FadeRoute(builder: (context) => LiverPurchaseDetailsPage(purchase)));

    if (result != null) {
      await _requestEcItem();
    }
  }

  Future<void> _requestEcItem() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);
    setState(() => _isLoading = true);
    final provideUserId = userModel.id;
    final response = await service.getEcItemPurchased(provideUserId);
    setState(() {
      _isLoading = false;
    });
    if (response?.result == true) {
      _monthlySales = response.getByKey('monthly_sales') ?? 0;
      _monthlyFee = response.getByKey('monthly_fee') ?? 0;
      _monthlyBenefit = response.getByKey('monthly_benefit') ?? 0;
      final list = response.getData();
      if (list != null && !list.isEmpty) {
        final histories = List<Purchase>();
        list.forEach((item) => histories.add(Purchase.fromJson(item)));
        setState(() {
          if (widget.isTrading) {
            // 取引中.
            _histories = histories
                .where((x) =>
                    (x.state != PurchaseState.Completed) &&
                    (x.state != PurchaseState.Cancel))
                .toList();
          } else {
            // 販売履歴.
            _histories = histories
                .where((x) =>
                    (x.state == PurchaseState.Completed) ||
                    (x.state == PurchaseState.Cancel))
                .toList();
          }
        });
      } else {
        setState(() {
          _errorMessage = Lang.ERROR_NO_SELLING_HISTORY;
        });
      }
    } else {
      setState(() {
        _errorMessage = Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER;
      });
    }
  }
}
