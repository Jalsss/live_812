// タイムライン投稿の親記事
class TimelinePostModel {
  final dynamic json;

  // コメント数といいねしたかどうかは、ローカルで手持ちの情報を更新する
  int _commentCount;
  bool _like;

  String get id => json['id'];
  String get accountId => json['account_id'];
  String get msg => json['msg'];
  String get nickname => json['nickname'];
  String get imgUrl => json['img_url'];
  String get imgThumbUrl => json['img_thumb_url'];
  DateTime get createDate => DateTime.parse(json['create_date']);
  int get commentCount => _commentCount ?? json['comment_count'];

  bool get liked => _like ?? json['liked'];
  int get likeCount {
    int count = json['like_count'];
    // いいねをローカルで変更していたら、その分カウントを増減
    if (_like != null && _like != json['liked'])
      count += _like == true ? 1 : -1;
    return count;
  }

  TimelinePostModel.fromJson(this.json);

  String toString() {
    return 'TimelinePostModel{id:$id, accountId:$accountId, nickname:$nickname, msg:$msg, like=#$likeCount/$liked, comments=#$commentCount}';
  }

  void setCommentCount(int count) {
    _commentCount = count;
  }

  void setLike(bool like) {
    _like = like;
  }
}
