import 'package:live812/utils/consts/consts.dart';

class Product {
  final String salesUserId;
  final int price;
  final int state;
  final String itemId;
  final String name;
  final String memo;
  final String categoryName;
  final int shippingPeriod;
  final String customerUserId;
  final String customerUserName;
  final bool publicFlag;
  final List<String> imgUrlList;
  final List<String> thumbnailUrlList;
  final bool enabled;
  final List<int> imgListIndices; // 画像リストのインデクス
  final String createDate;
  final bool isBuyable;

  // https://docs.google.com/spreadsheets/d/1vxL8p31yJXxmpcU9aW5wv30hksL0923C5WHpEiTKJbE/edit?ts=5e1c2ed8#gid=1623515665
  // 商品購入履歴	ec/order/history
  // "stateの状態は以下のとおりです。
  bool get isPublished => (state == 1);

  Product({
    this.salesUserId,
    this.price,
    this.state,
    this.itemId,
    this.name,
    this.memo,
    this.categoryName,
    this.shippingPeriod,
    this.customerUserId,
    this.customerUserName,
    this.publicFlag,
    this.imgUrlList,
    this.thumbnailUrlList,
    this.enabled,
    this.imgListIndices,
    this.createDate,
    this.isBuyable,
  });

  ///This method is to deserialize your JSON
  ///Basically converting a string response to an object model
  ///Here key is always a String type and value can be of any type
  ///so we create a map of String and dynamic.
  factory Product.fromJson(Map<String, dynamic> json) {
    // 画像はjsonのリストじゃなく個々にナンバリングされているので、リストに戻す
    // 注意：サーバ側からは1から全て埋まっているわけではなく、間が空いている場合もあり
    // インデクスはずれる可能性がある。
    List<String> imgUrlList = [];
    List<String> thumbnailUrlList = [];
    List<int> imgListIndices = [];
    for (int i = 0; i < Consts.PRODUCT_MAX_PHOTOS; ++i) {
      String imgKey = 'img_url_img${i + 1}';
      String thumbKey = 'img_thumb_url_img${i + 1}';
      if (json[imgKey] != null && json[thumbKey] != null) {
        imgUrlList.add(json[imgKey]);
        thumbnailUrlList.add(json[thumbKey]);
        imgListIndices.add(i);
      }
    }

    return Product(
      salesUserId: json["sales_user_id"],
      price: json["price"] ?? 0,
      state: json["state"] ?? 1,
      itemId: json["item_id"] ?? '',
      name: json["item_name"] ?? '',
      memo: json["memo"] ?? '',
      categoryName: json["category_name"] ?? '',
      shippingPeriod: json["shipping_period"],
      customerUserId: json["customer_user_id"],
      customerUserName: json['customer_user_name'],
      publicFlag: json["public_flag"],
      imgUrlList: imgUrlList,
      thumbnailUrlList: thumbnailUrlList,
      enabled: json['enabled_flag'] == true,
      imgListIndices: imgListIndices,
      createDate: json["create_date"],
      isBuyable: json['is_buyable'] == true,
    );
  }

  String toString() {
    return 'Product{salesUserId=$salesUserId, id=$itemId, name=$name, memo=$memo, price=$price, categoryName=$categoryName, shippingPeriod=$shippingPeriod, customerUserId=$customerUserId, customerUserName=$customerUserName,  publicFlag=$publicFlag, enabled=$enabled, imgUrlList=$imgUrlList}';
  }
}
