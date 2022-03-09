// ソケットで送られるギフト情報
class ChatSocketModel {
  final String message;
  final String id;
  final String userId;  // 送ったユーザID
  final String nickName;  // 送ったユーザのニックネーム

  ChatSocketModel.fromJson(dynamic json): message = json['message'], userId = json['user_id'], nickName = json['nickname'] ?? json['user_id'], id = json['gift_id'];
}
