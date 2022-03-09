import 'package:flutter/foundation.dart';

class AudienceModel {
  final String id;
  final String symbol;
  final String nickname;
  final String imgUrl;
  final String imgThumbUrl;
  final String imgSmallUrl;

  AudienceModel({
    @required this.id,
    @required this.symbol,
    @required this.nickname,
    @required this.imgUrl,
    @required this.imgThumbUrl,
    @required this.imgSmallUrl,
  });

  factory AudienceModel.fromJson(Map<String, dynamic> json) {
    return AudienceModel(
      id: json['audience_id'],
      symbol: json['audience_user_id'],
      nickname: json['audience_nickname'],
      imgUrl: json['img_url'],
      imgThumbUrl: json['img_thumb_url'],
      imgSmallUrl: json['img_small_url'],
    );
  }

  String toString() {
    return 'AudienceModel{id=$id, symbol=$symbol, nickname=$nickname, imgUrl=$imgUrl}';
  }
}
