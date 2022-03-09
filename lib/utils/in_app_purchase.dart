import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/repository/event_logger_repository.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/result.dart';
import 'package:live812/utils/share_util.dart';

class InAppPurchase {
  var _purchase = FlutterInappPurchase(FlutterInappPurchase.instance);
  StreamSubscription _purchaseUpdatedSubscription;
  StreamSubscription _purchaseErrorSubscription;
  Completer<Result<PurchasedItem, PurchaseResult>> _completer;

  static const int INIT_OK = 0;
  static const int INIT_UNAVAILABLE = 3;
  static const int INIT_OTHER_ERROR = 99;

  /// 初期化.
  Future<int> asyncInitState() async {
    try {
      // ストアへ接続.
      await _purchase.initConnection;
      // 購入完了時.
      _purchaseUpdatedSubscription =
          FlutterInappPurchase.purchaseUpdated.listen((purchasedItem) {
        _completer.complete(Ok(purchasedItem));
      });
      // 購入失敗時.
      _purchaseErrorSubscription =
          FlutterInappPurchase.purchaseError.listen((purchaseResult) {
        _completer.complete(Err(purchaseResult));
      });
    } on PlatformException catch (e) {
      if (e.message.endsWith('3')) {
        return Future.value(INIT_UNAVAILABLE);
      }
      return Future.value(INIT_OTHER_ERROR);
    }
    return Future.value(INIT_OK);
  }

  /// 破棄.
  Future<void> dispose() async {
    await Future.wait([
      _purchase?.endConnection,
      _purchaseUpdatedSubscription?.cancel(),
      _purchaseErrorSubscription?.cancel(),
    ].where((x) => x != null).toList());
    _completer = null;
  }

  /// 保留中のアイテムを取得.
  Future<List<PurchasedItem>> getPendingTransactionsItems() async {
    try {
      if (Platform.isAndroid) {
        return await _purchase.getAvailablePurchases();
      } else {
        return await _purchase.getPendingTransactionsIOS();
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// ストアのアイテムを取得.
  Future<List<IAPItem>> getItems(List<String> productList) async {
    List<IAPItem> _items = await _purchase.getProducts(productList);
    try {
      if (_items != null) {
        _items.sort(
            (a, b) => double.parse(a.price).compareTo(double.parse(b.price)));
      } else {
        _items = [];
      }
      return _items;
    } on PlatformException {
      // iOSの審査でアイテムが読み込まれない指摘(こちらでは再現せず)をされたので一時対応
      if (Platform.isAndroid) {
        return [];
      } else {
        return _items;
      }
    }
  }

  /// 購入処理.
  Future<Result<PurchasedItem, PurchaseResult>> requestPurchase(
      IAPItem iapItem) async {
    try {
      _completer = Completer<Result<PurchasedItem, PurchaseResult>>();
      _purchase.requestPurchase(iapItem.productId);
      return await _completer.future;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// トランザクションを終了する.
  Future<bool> finishTransaction(PurchasedItem purchasedItem) async {
    try {
      // トランザクションを終了.
      await _purchase.finishTransaction(purchasedItem,
          isConsumable: true);
      // アナリティクスへ送信.
      await _sendPurchaseCoinEvent(purchasedItem);

      return Future.value(true);
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }

  /// 購入イベントをアナリティクスへ送信.
  Future _sendPurchaseCoinEvent(PurchasedItem purchasedItem) async {
    // 購入商品のアイテム情報を取得.
    var iapItems = await getItems(ShareUtil.iapItemNames());
    var iapItem = iapItems.singleWhere(
        (item) => item.productId == purchasedItem.productId,
        orElse: () => null);

    num price = num.tryParse(iapItem?.price);
    if ((iapItem == null) || (price == null)) {
      // エラー.
      return;
    }

    // Adjustへ送信.
    Injector.getInjector()
        .get<EventLoggerRepository>()
        .sendPurchaseCoinEvent(price, currency: iapItem.currency);
  }
}
