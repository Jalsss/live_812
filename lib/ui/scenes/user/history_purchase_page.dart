import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/item/PurchaseItem.dart';
import 'package:live812/ui/scenes/user/purchase_details_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';

// 購入履歴
class HistoryPurchasePage extends StatefulWidget {
  /// 取引中かどうか.
  final bool isTrading;

  HistoryPurchasePage({this.isTrading});

  @override
  HistoryPurchasePageState createState() => HistoryPurchasePageState();
}

class HistoryPurchasePageState extends State<HistoryPurchasePage> {
  bool _isLoading = false;
  List<Purchase> _histories;
  String _errorMessage;
  bool _pullToRefreshing = false;

  @override
  void initState() {
    super.initState();
    _requestEcOrder();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      isLoading: _isLoading && !_pullToRefreshing,
      backgroundColor: ColorLive.MAIN_BG,
      title: widget.isTrading ? Lang.TRADING : Lang.PURCHASE_HISTORY,
      titleColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Builder(
          builder: (context) {
            if (_errorMessage != null || _histories == null) {
              return _isLoading
                  ? Container()
                  : Center(
                      child: Text(_isLoading ? '' : _errorMessage,
                          style: TextStyle(color: Colors.white)),
                    );
            }

            return ListView(
              padding: EdgeInsets.only(top: 0),
              children: _histories.map((purchase) {
                return PurchaseItem(
                  purchase: purchase,
                  onTap: () => _showDetails(purchase),
                  isPurchase: true,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDetails(Purchase purchase) async {
    /*final result =*/ await Navigator.push(context,
        FadeRoute(builder: (context) => PurchaseDetailsPage(purchase)));

    // ひとまず常に更新で
    //if (result != null) {
    await _requestEcOrder();
    //}
  }

  Future<void> _onRefresh() async {
    setState(() => _pullToRefreshing = true);
    await _requestEcOrder();
    setState(() => _pullToRefreshing = false);
  }

  Future<void> _requestEcOrder() async {
    final service = BackendService(context);
    setState(() => _isLoading = true);
    final response = await service.getEcOrderHistory();
    setState(() {
      _isLoading = false;
    });
    if (response?.result == true) {
      final list = response.getData();
      if (list != null && !list.isEmpty) {
        final histories = List<Purchase>();
        list.forEach((item) => histories.add(Purchase.fromJson(item)));
        try {
          setState(() {
            if (widget.isTrading) {
              // 取引中.
              _histories = histories
                  .where((x) =>
                      (x.state != PurchaseState.Completed) &&
                      (x.state != PurchaseState.Cancel))
                  .toList();
            } else {
              // 購入履歴.
              _histories = histories
                  .where((x) =>
                      (x.state == PurchaseState.Completed) ||
                      (x.state == PurchaseState.Cancel))
                  .toList();
            }
          });
        } catch (e, s) {
          print(s);
        }
      } else {
        setState(() {
          _errorMessage = Lang.ERROR_NO_PURCHASE_HISTORY;
        });
      }
    } else {
      setState(() {
        _errorMessage = Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER;
      });
    }
  }
}
