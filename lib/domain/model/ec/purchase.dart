import 'package:flutter/foundation.dart';
import 'package:live812/domain/model/ec/product.dart';

enum PurchaseState {
  // Published   // 出品
  WaitingForPayment, // 入金待ち
  WaitingForDeliveryDestination, // 配送先指定待ち
  WaitingForDelivery, // 発送待ち
  DeliveryCompleted, // 発送済み
  Completed,// 完了
  Cancel, // キャンセル
  Suspend, // 取引一時中断
}

class Purchase {
  final Map<String, dynamic> _map;
  final String id;
  final String orderId;
  final String itemId;
  final String name;
  final String memo;
  final int shippingPeriod;
  final int price;
  final int fee;
  final int benefit;
  final String purchaseId;
  final String purchaseUserId;
  final String purchaseNickname;
  final String deliveryName;
  final String deliveryPostalCode;
  final String deliveryAddr;
  final String deliveryBuild;
  final String deliveryPhone;
  final String purchaseType;
  final DateTime purchaseDate;
  final DateTime billingDate;
  final DateTime deliveryInfoDate;
  final DateTime deliveryBegin;
  final DateTime deliveryEnd;
  final DateTime completedDate;
  final DateTime cancelDate;
  final List<String> imgUrl;
  final List<String> imgThumbUrl;
  final String purchaseUserNickname;
  final String purchaseUserThumbnailUrl;
  final String itemName;
  final DateTime salesDate;
  final String salesUserNickname;
  final String salesUserId;
  final String salesMemo;
  final String salesUserThumbnailUrl;

  PurchaseState _state;
  PurchaseState get state => _state;
  set state(value) => _state = value;

  bool _badgeChat;
  bool get badgeChat => _badgeChat;
  set badgeChat(value) => _badgeChat = (value == true);
  bool isChatEnable = false;

  String get bankName => _map['bank_name'];
  String get bankBranch => _map['branch_name'];
  String get bankAccountType => _map['bank_type'];
  String get bankAccountNumber => _map['bank_num'];
  String get bankAccountName => _map['bank_account'];

  Purchase._(Map<String, dynamic> map, {
      this.id,
      this.orderId,
      this.itemId,
      this.name,
      this.memo,
      this.shippingPeriod,
      this.price,
      this.fee,
      this.benefit,
      this.purchaseId,
      this.purchaseUserId,
      this.purchaseNickname,
      this.deliveryName,
      this.deliveryPostalCode,
      this.deliveryAddr,
      this.deliveryBuild,
      this.deliveryPhone,
      this.purchaseType,
      this.purchaseDate,
      this.billingDate,
      this.deliveryInfoDate,
      this.deliveryBegin,
      this.deliveryEnd,
      this.completedDate,
      this.cancelDate,
      this.imgUrl,
      this.imgThumbUrl,
      this.purchaseUserNickname,
      this.purchaseUserThumbnailUrl,
      this.itemName,
      this.salesDate,
      this.salesUserNickname,
      this.salesUserId,
      this.salesMemo,
      this.salesUserThumbnailUrl,
      @required PurchaseState state,
      @required bool badgeChat,
      this.isChatEnable = false,
    }) : _map = map, _state = state, _badgeChat = badgeChat;

  factory Purchase.fromJson(Map<String, dynamic> json) {
    final cancelDate = json['cancel_date'] != null
        ? DateTime.parse(json['cancel_date'])
        : null;

    return Purchase._(
      json,
      id: json['id'],
      orderId: json['order_id'],
      itemId: json['item_id'],
      name: json['name'],
      memo: json['memo'],
      shippingPeriod: json['shipping_period'],
      state: _detectState(json['state'], cancelDate),
      badgeChat: json['badge_chat'] ?? false,
      isChatEnable: json['is_chat_enable'] ?? false,
      price: json['price'],
      fee: json['fee'],
      benefit: json['benefit'],
      purchaseId: json['purchase_id'] ?? '',
      purchaseUserId: json['purchase_user_id'] ?? '',
      purchaseNickname: json['purchase_nickname'] ?? '',
      deliveryName: json['delivery_name'] ?? '',
      deliveryPostalCode: json['delivery_postal_code'] ?? '',
      deliveryAddr: json['delivery_addr'] ?? '',
      deliveryBuild: json['delivery_build'] ?? '',
      deliveryPhone: json['delivery_phone'] ?? '',
      purchaseType: json['purchase_type'] ?? '',
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : null,
      billingDate: json['billing_date'] != null
          ? DateTime.parse(json['billing_date'])
          : null,
      deliveryInfoDate: json['delivery_info_date'] != null
          ? DateTime.parse(json['delivery_info_date'])
          : null,
      deliveryBegin: json['delivery_begin'] != null
          ? DateTime.parse(json['delivery_begin'])
          : null,
      deliveryEnd: json['delivery_end'] != null
          ? DateTime.parse(json['delivery_end'])
          : null,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
          : null,
      cancelDate: cancelDate,
      imgUrl: _toStringList(json['img_url']),
      imgThumbUrl: _toStringList(json['img_thumb_url'],),
      purchaseUserNickname: json['purchase_user_nickname'],
      purchaseUserThumbnailUrl: json['purchase_user_img_samll_url'],  // thumbは壊れている（.jpgになってない）ので、ひとまずsmallで
      itemName: json['item_name'],
      salesDate: json['sales_date'] != null
          ? DateTime.parse(json['sales_date'])
          : null,
      salesUserNickname: json['sales_user_nickname'],
      salesUserId: json['sales_user_id'],
      salesMemo: json['sales_memo'],
      salesUserThumbnailUrl: json['sales_user_img_samll_url'],  // thumbは壊れている（.jpgになってない）ので、ひとまずsmallで
    );
  }

  String toString() {
    return 'Purchase{id=$id, name=$name, memo=$memo, price=$price, status=$state}';
  }

  /// チャットすることが可能かどうか.
  bool canChat() {
    return isChatEnable;
  }

  // 足りない情報があるかも、使用には注意
  Product getProductInfo() {
    return Product(
      price: price,
      itemId: itemId,
      name: name ?? itemName,
      memo: salesMemo ?? memo ?? '',
      shippingPeriod: shippingPeriod,
      imgUrlList: imgUrl,
      thumbnailUrlList: imgThumbUrl,
      isBuyable: false,
    );
  }

  // 現在購入の状況
  static PurchaseState _detectState(int state, DateTime cancelDate) {
    if (cancelDate != null)
      return PurchaseState.Cancel;

    switch (state) {
      case _PURCHASE_STATE_PUBLISHED:  // こないはず
        assert(false);
        return PurchaseState.Cancel;
      case _PURCHASE_STATE_WAITING_FOR_PAYMENT:  return PurchaseState.WaitingForPayment;
      case _PURCHASE_STATE_WAITING_FOR_DELIVERY_DESTINATION:  return PurchaseState.WaitingForDeliveryDestination;
      case _PURCHASE_STATE_WAITING_FOR_DELIVERY:  return PurchaseState.WaitingForDelivery;
      case _PURCHASE_STATE_DELIVERY_COMPLETED:  return PurchaseState.DeliveryCompleted;
      case _PURCHASE_STATE_COMPLETED:  return PurchaseState.Completed;
      case _PURCHASE_STATE_SUSPEND: return PurchaseState.Suspend;
      default:
        return PurchaseState.Cancel;
    }
  }
}

List<String> _toStringList(dynamic elem) {
  List<String> list;
  if (elem != null) {
    if (elem is String) {
      list = [elem];
    } else if (elem is List) {
      list = elem.map((e) => e.toString()).toList();
    }
  }
  return list;
}

// https://docs.google.com/spreadsheets/d/1vxL8p31yJXxmpcU9aW5wv30hksL0923C5WHpEiTKJbE/edit?ts=5e1c2ed8#gid=1623515665
// 商品購入履歴 ec/order/history
// "stateの状態は以下のとおりです。
const int _PURCHASE_STATE_PUBLISHED                         = 1;  // {id: 1, state: '出品'},
const int _PURCHASE_STATE_WAITING_FOR_PAYMENT               = 2;  // {id: 2, state: '購入（銀行振込,クレジット)'},
const int _PURCHASE_STATE_WAITING_FOR_DELIVERY_DESTINATION  = 3;  // {id: 3, state: '配送先情報待ち'},
const int _PURCHASE_STATE_WAITING_FOR_DELIVERY              = 4;  // {id: 4, state: '発送待ち'},
const int _PURCHASE_STATE_DELIVERY_COMPLETED                = 5;  // {id: 5, state: '発送済み'},
const int _PURCHASE_STATE_COMPLETED                         = 6;  // {id: 6, state: '取引完了'},"
const int _PURCHASE_STATE_SUSPEND                           =10;  // {id:10, state: '取引中断'},
