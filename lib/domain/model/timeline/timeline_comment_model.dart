// タイムライン投稿に対するコメント
class TimelineCommentModel {
  final dynamic json;

  String get id => json['id'];
  String get accountId => json['account_id'];
  String get msg => json['msg'];
  String get nickname => json['nickname'];
  DateTime get createDate => DateTime.parse(json['create_date']);
  bool get isLiver => json['is_liver'] == true;

  TimelineCommentModel.fromJson(this.json);

  String toString() {
    return 'TimelineCommentModel{id:$id, nickname:$nickname, msg:$msg}';
  }
}
