class StoreProfile {
  int index;
  String itemName;
  String memo;
  bool publicFlag;
  List<String> imgUrls = List<String>(5);
  List<String> imgThumbUrls = List<String>(5);

  StoreProfile({
    this.index,
    this.itemName,
    this.memo,
    this.publicFlag,
    String imgUrl1,
    String imgThumbUrl1,
    String imgUrl2,
    String imgThumbUrl2,
    String imgUrl3,
    String imgThumbUrl3,
    String imgUrl4,
    String imgThumbUrl4,
    String imgUrl5,
    String imgThumbUrl5,
  }) {
    imgUrls[0] = imgUrl1;
    imgUrls[1] = imgUrl2;
    imgUrls[2] = imgUrl3;
    imgUrls[3] = imgUrl4;
    imgUrls[4] = imgUrl5;
    imgThumbUrls[0] = imgThumbUrl1;
    imgThumbUrls[1] = imgThumbUrl2;
    imgThumbUrls[2] = imgThumbUrl3;
    imgThumbUrls[3] = imgThumbUrl4;
    imgThumbUrls[4] = imgThumbUrl5;
  }

  factory StoreProfile.fromJson(Map<String, dynamic> json) => StoreProfile(
        index: json['index'],
        itemName: json['item_name'],
        memo: json['memo'],
        publicFlag: json['public_flag'],
        imgUrl1: json['img_url_1'],
        imgThumbUrl1: json['img_thumb_url_1'],
        imgUrl2: json['img_url_2'],
        imgThumbUrl2: json['img_thumb_url_2'],
        imgUrl3: json['img_url_3'],
        imgThumbUrl3: json['img_thumb_url_3'],
        imgUrl4: json['img_url_4'],
        imgThumbUrl4: json['img_thumb_url_4'],
        imgUrl5: json['img_url_5'],
        imgThumbUrl5: json['img_thumb_url_5'],
      );
}
