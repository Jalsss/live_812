// ソケットで送られる「いいね！」情報
class LikeSocketModel {
  final int like;
  final String userId;
  final String nickName;

  LikeSocketModel.fromJson(dynamic json): like = json['like'], userId = json['user_id'], nickName = json['nickname'];
}
