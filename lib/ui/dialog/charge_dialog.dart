import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/usecase/purchase_usecase.dart';
import 'package:live812/ui/item/GridCoinItem.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/in_app_purchase.dart';
import 'package:live812/utils/widget/multi_row_grid_view.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:live812/utils/share_util.dart';
import 'package:provider/provider.dart';

class ChargeDialog extends StatefulWidget {
  final void Function(int) callback;

  ChargeDialog({this.callback});

  @override
  _ChargeDialogState createState() => _ChargeDialogState();
}

class _ChargeDialogState extends State<ChargeDialog> {
  var _inAppPurchase = InAppPurchase();
  List<IAPItem> _iapItems;
  bool _isLoading = false;
  bool _isPurchasing = false;
  PurchaseErrorReason _errorReason;

  @override
  void dispose() {
    _inAppPurchase.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _requestCoinItems(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Dialog(
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(Consts.padding),
        // ),
        elevation: 0.0,
        child: _dialogContent(context),
      ),
    );
  }

  Widget _dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            height: MediaQuery.of(context).size.height - 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorLive.BLUE_BG,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorLive.BG2,
                  ),
                  padding: EdgeInsets.only(top: 16, bottom: 23),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          Lang.CHARGE,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          height: 20,
                          child: MaterialButton(
                            minWidth: 50,
                            height: 20,
                            padding: EdgeInsets.all(0),
                            child: SvgPicture.asset(
                              "assets/svg/backButton.svg",
                              color: _isPurchasing ? Colors.grey : null,
                            ),
                            onPressed: _isPurchasing || _isLoading
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                  },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: ColorLive.BORDER4,
                  thickness: 1,
                  height: 1,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _errorReason != null
                          ? _buildError()
                          : _iapItems == null ? null : _buildIapItemList(),
                      _isLoading ? SpinningIndicator() : null,
                    ].where((w) => w != null).toList(),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorLive.MAIN_BG,
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
                          Consumer<UserModel>(
                            builder: (context, userModel, _) {
                              return Text(
                                '${userModel.point}',
                                style: TextStyle(
                                    color: ColorLive.ORANGE,
                                    fontSize: 26,
                                    fontFamily: "Roboto"),
                              );
                            },
                          ),
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
            )),
      ],
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
              SizedBox(height: 10),
              FlatButton(
                child: Text(Lang.RETRY, style: TextStyle(color: Colors.white)),
                onPressed: () {
                  _requestCoinItems(context);
                },
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestCoinItems(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorReason = null;
    });

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

  Future<void> _doPurchase(IAPItem iapItem) async {
    setState(() {
      _isLoading = true;
      _isPurchasing = true;
    });
    await PurchaseUsecase.doPurchase(context, _inAppPurchase, iapItem);
    setState(() {
      _isLoading = false;
      _isPurchasing = false;
    });
    // エラーの場合は強制的に前の画面へ戻す.
    if (!PurchaseUsecase.isSuccessOrCancel) {
      Navigator.of(context).pop();
    }
  }
}
