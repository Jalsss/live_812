// ソケットで送られるギフト情報
class GiftSocketModel {
  final String id;
  final String userId;  // 送ったユーザID
  final String nickName;  // 送ったユーザのニックネーム
  final int point;  // ポイント

  GiftSocketModel.fromJson(dynamic json): userId = json['user_id'], nickName = json['nickname'], id = json['gift_id'].toString(), point = json['gift_point'];
}
