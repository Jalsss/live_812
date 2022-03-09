// IAP購入情報
import 'package:flutter/foundation.dart';

class IapInfo {
  // ステート
  static const int PURCHASED = 1;
  static const int REGISTERED = 2;
  static const int FAILED = 3;

  final String productId;
  final String transactionId;
  final String transactionReceipt;
  final String purchaseToken;
  final String orderId;

  // Android
  final int purchaseStateAndroid;
  final String developerPayloadAndroid;
  final String originalJsonAndroid;
  final String signatureAndroid;

  final int coin;

  final String price;
  final String currency;

  int id;
  int state;
  DateTime createdAt;

  IapInfo({
    @required this.productId,
    @required this.transactionId,
    @required this.transactionReceipt,
    @required this.purchaseToken,
    @required this.orderId,

    @required this.purchaseStateAndroid,
    @required this.developerPayloadAndroid,
    @required this.originalJsonAndroid,
    @required this.signatureAndroid,

    @required this.price,
    @required this.currency,

    @required this.coin,

    this.id,
    this.state = PURCHASED,
    @required this.createdAt,
  });

  String toString() {
    return 'IapInfo{id=$id, state=$state, productId=$productId, transactionId=$transactionId, purchaseToken=$purchaseToken, orderId=$orderId, purchaseStateAndroid=$purchaseStateAndroid, price=$price, currency=$currency, coin=$coin, createdAt=$createdAt}';
  }
}
