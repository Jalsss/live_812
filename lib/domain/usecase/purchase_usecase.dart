import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/model/json_data.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/in_app_purchase.dart';

// アプリ内課金ユースケース
class PurchaseUsecase {
  static bool isSuccessOrCancel = false;

  PurchaseUsecase._();

  /// 購入処理.
  static Future doPurchase(BuildContext context, InAppPurchase inAppPurchase,
      IAPItem iapItem) async {
    // 初期化.
    isSuccessOrCancel = false;

    // 購入処理.
    var result = await inAppPurchase.requestPurchase(iapItem);

    return await result.match(ok: (purchasedItem) async {
      // 購入成功.
      return await _doPurchaseSuccess(context, inAppPurchase, purchasedItem);
    }, err: (purchaseResult) async {
      // 購入失敗.
      return await _doPurchaseFailed(context, purchaseResult);
    });
  }

  /// 購入処理成功.
  static Future _doPurchaseSuccess(BuildContext context,
      InAppPurchase inAppPurchase, PurchasedItem purchasedItem) async {
    // レシート検証.
    var response =
        await postReceiptVerify(context: context, purchasedItem: purchasedItem);

    // レシート検証の結果.
    if (PurchaseUsecase.checkReceiptVerify(response)) {
      // 成功.
      // トランザクションを終了.
      if (await inAppPurchase.finishTransaction(purchasedItem)) {
        // 購入完了表示.
        isSuccessOrCancel = true;
        await _showDialog(
            context: context, title: "購入完了", content: "購入が完了しました。");
      } else {
        // 購入失敗.
        await _showDialog(
            context: context, title: "エラー", content: "購入終了処理に失敗しました。");
      }
    } else {
      // エラー.
      final reason = errorReason(response);
      // エラー表示.
      await _showDialog(
          context: context,
          title: reason.title,
          content: reason.message,
          barrierDismissible: false);
    }
  }

  /// 購入処理失敗.
  static Future _doPurchaseFailed(
      BuildContext context, PurchaseResult purchaseResult) async {
    if (purchaseResult != null && purchaseResult.code != 'E_USER_CANCELLED') {
      // 購入失敗.
      await _showDialog(
          context: context,
          title: '購入エラー',
          content: '購入に失敗しました。(${purchaseResult?.responseCode ?? -1})',
          barrierDismissible: false);
      print(purchaseResult?.toString());
    } else if (purchaseResult != null &&
        purchaseResult.code == 'E_USER_CANCELLED') {
      // キャセル.
      isSuccessOrCancel = true;
      await _showDialog(
          context: context, title: "購入キャンセル", content: "購入をキャンセルしました。");
    }
  }

  /// レシート検証.
  static Future<JsonData> postReceiptVerify(
      {@required BuildContext context,
      @required PurchasedItem purchasedItem}) async {
    // サーバーにてレシートを検証.
    final service = BackendService(context);
    JsonData response;
    if (Platform.isIOS || Platform.environment.containsKey('FLUTTER_TEST')) {
      response = await service.postReceiptIos(purchasedItem.transactionReceipt);
    } else if (Platform.isAndroid) {
      response = await service.postReceiptAndroid(
          json.decode(purchasedItem.originalJsonAndroid != null
              ? purchasedItem.originalJsonAndroid
              : purchasedItem.transactionReceipt),
          purchasedItem.signatureAndroid);
    }

    // ポイントを反映.
    if (response?.containsKey('point') ?? false) {
      _updatePoint(context, response?.getByKey('point'));
    }
    return response;
  }

  /// ポイント(コイン)の反映.
  static void _updatePoint(BuildContext context, int point) {
    final userModel = Injector.getInjector()
        .get<UserModel>(additionalParameters: {'context': context});
    if ((userModel != null) && (point != null)) {
      userModel.setPoint(point);
      userModel.saveToStorage();
    }
  }

  /// レスポンスデータを解析.
  static bool checkReceiptVerify(JsonData response) {
    try {
      // 成功.
      if (response?.result ?? false) {
        return true;
      }
      // 重複レシート(成功).
      // result : false, add_log : false
      if (response?.containsKey('add_log') ?? false) {
        return response?.getByKey('add_log') == false;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  /// レスポンスデータからメッセージを生成.
  static PurchaseErrorReason errorReason(JsonData response) {
    try {
      // 通信エラー.
      if (response?.containsKey('_exception') ?? false) {
        return PurchaseErrorReason(
          title: 'エラー',
          message: '通信エラーが発生しました。',
        );
      }
      // 支払い保留中.
      if (response?.containsKey('pending_err') ?? false) {
        if (response?.getByKey('pending_err') ?? false) {
          return PurchaseErrorReason(
            title: response?.getByKey('title') ?? 'お知らせ',
            message: response?.getByKey('msg') ?? 'まだお支払いが完了しておりません。お支払い状況をご確認ください。',
          );
        }
      }
      // レシートの検証エラー.
      if (response?.containsKey('validation_err') ?? false) {
        if (response?.getByKey('validation_err') ?? false) {
          return PurchaseErrorReason(
            title: 'エラー',
            message: '不正な購入を検出しました。',
          );
        }
      }
      // ポイントの付与失敗。
      if (response?.containsKey('point_err') ?? false) {
        if (response?.getByKey('point_err') ?? false) {
          return PurchaseErrorReason(
            title: 'エラー',
            message: '無効な商品です。',
          );
        }
      }
    } catch (e) {
      print(e);
    }
    return PurchaseErrorReason(
      title: 'エラー',
      message: 'エラーが発生しました。',
    );
  }

  /// ダイアログの表示.
  static Future _showDialog(
      {BuildContext context,
      String title,
      String content,
      bool barrierDismissible = true}) async {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text(Lang.CLOSE),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _PurchaseError {
  final String message;
  final bool validationErr;
  final bool retryEnable;
  final String exceptionName;

  _PurchaseError(this.message,
      {this.validationErr, this.retryEnable, this.exceptionName});

  String toString() {
    return '_PurchaseError {message=$message, validationErr=$validationErr, retryEnable=$retryEnable, exceptionName=$exceptionName}';
  }
}

class PurchaseErrorReason {
  PurchaseErrorReason({this.title, this.message});

  final String title;
  final String message;
}

enum _RegisterPurchaseResult {
  FAILED,
  SUCCEEDED,
  CANCELED,
}
