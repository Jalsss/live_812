import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/usecase/purchase_usecase.dart';
import 'package:live812/ui/item/GridCoinItem.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/deep_link_handler.dart';
import 'package:live812/utils/in_app_purchase.dart';
import 'package:live812/utils/push_notification_manager.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/multi_row_grid_view.dart';
import 'package:live812/utils/share_util.dart';
import 'package:provider/provider.dart';

class ChargePage extends StatefulWidget {
  @override
  ChargePageState createState() => ChargePageState();
}

class ChargePageState extends State<ChargePage> {
  var _inAppPurchase = InAppPurchase();
  bool _isLoading = true;
  PurchaseErrorReason _errorReason;
  List<IAPItem> _iapItems;

  @override
  void dispose() {
    DeepLinkHandlerStack.instance().pop();

    _inAppPurchase.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _setProducts(context);

    DeepLinkHandlerStack.instance().push(DeepLinkHandler(
      showLiverProfile: (liverId) {
        // 購入している最中に遷移させられるとまずいので無視する。
      },
      showChat: (orderId) {
        // 購入している最中に遷移させられるとまずいので無視する。
      }
    ));
    PushNotificationManager.instance()
        .pushHandler(PushNotificationHandler(onReceive: (action, message) {
      // 購入している最中に遷移させられるとまずいので無視する。
    }));
  }

  void _setProducts(BuildContext context) async {
    // 初期化.
    final int result = await _inAppPurchase.asyncInitState();
    if (result != InAppPurchase.INIT_OK) {
      setState(() {
        switch (result) {
          case InAppPurchase.INIT_UNAVAILABLE:
            _errorReason = PurchaseErrorReason(
              title: 'エラー',
              message: 'チャージをするためにはGoogleアカウントを設定してください',
            );
            break;
          default:
            _errorReason = PurchaseErrorReason(
              title: 'エラー',
              message: 'エラーが発生しました',
            );
            break;
        }
        _isLoading = false;
      });
      return;
    }
    // 保留中のアイテムを取得.
    var userModel = Provider.of<UserModel>(context, listen: false);
    List<PurchasedItem> pendingItems = [];
    if (userModel.isIAPRecovery) {
      pendingItems = await _inAppPurchase.getPendingTransactionsItems();
    }
    for (var item in pendingItems) {
      var response = await PurchaseUsecase.postReceiptVerify(
          context: context, purchasedItem: item);
      // レシート検証の結果.
      if (!PurchaseUsecase.checkReceiptVerify(response)) {
        // エラー.
        setState(() {
          _errorReason = PurchaseUsecase.errorReason(response);
          _isLoading = false;
        });
        return;
      }
      // トランザクションを終了.
      bool finishTransaction = await _inAppPurchase.finishTransaction(item);
      if (!finishTransaction) {
        // エラー.
        setState(() {
          _errorReason = PurchaseErrorReason(
            title: 'エラー',
            message: '購入終了処理に失敗しました。',
          );
          _isLoading = false;
        });
        return;
      }
    }

    // アイテムの取得.
    _iapItems = await _inAppPurchase.getItems(ShareUtil.iapItemNames());
    setState(() {
      _errorReason = _iapItems.length != 0
          ? null
          : PurchaseErrorReason(
              title: 'エラー',
              message: Lang.ERROR_COIN_INFO_FAILED_TRY_AGAIN_AFTER,
            );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: LiveScaffold(
        isLoading: _isLoading,
        backgroundColor: ColorLive.MAIN_BG,
        title: Lang.CHARGE,
        titleColor: Colors.white,
        body: Stack(children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _errorReason != null
                      ? _buildError()
                      : _iapItems == null ? Container() : _buildIapItemList(),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorLive.C26,
                    border:
                        Border(top: BorderSide(color: ColorLive.C97, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(Lang.BALANCE,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                      Row(
                        children: <Widget>[
                          Consumer<UserModel>(builder: (context, userModel, _) {
                            return Text(
                              '${userModel.point}',
                              style: TextStyle(
                                  color: ColorLive.ORANGE,
                                  fontSize: 28,
                                  fontFamily: "Roboto"),
                            );
                          }),
                          Text(
                            " " + Lang.COIN,
                            style: TextStyle(
                                color: ColorLive.ORANGE, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildIapItemList() {
    return MultiRowGridView(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 20),
      crossAxisCount: 3,
      children: List.generate(_iapItems.length, (index) {
        final iapItem = _iapItems[index];
        return [
          GridCoinItem(
            productId: iapItem.productId,
            localizedPrice: iapItem.localizedPrice,
            title: Platform.isAndroid
                ? iapItem.title.replaceFirst(' (LIVE812（ハチイチニ）- ライブ配信アプリ)', '')
                : iapItem.title,
            item: iapItem,
            purchase: _inAppPurchase,
          ),
          InkWell(
            child: Container(
              width: 80,
              padding: EdgeInsets.only(left: 5, right: 5, bottom: 20),
              child: FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: const Text('購入'),
                onPressed: () => _doPurchase(iapItem),
              ),
            ),
          ),
        ];
      }),
    );
  }

  Widget _buildError() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Center(
        child: IntrinsicHeight(
          child: Column(
            children: [
              Text(_errorReason?.title ?? Lang.ERROR,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              SizedBox(height: 10),
              Text(_errorReason?.message ?? '', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  /// 購入処理.
  Future<void> _doPurchase(IAPItem iapItem) async {
    setState(() {
      _isLoading = true;
    });
    await PurchaseUsecase.doPurchase(context, _inAppPurchase, iapItem);
    setState(() {
      _isLoading = false;
    });
    // エラーの場合は強制的に前の画面へ戻す.
    if (!PurchaseUsecase.isSuccessOrCancel) {
      Navigator.of(context).pop();
    }
  }
}
