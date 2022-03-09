class NoticeModel {
  final String id;
  final String title;
  final String content;
  final DateTime createDate;
  final bool hasEyeCatch;
  final int status;
  final DateTime publicDate;
  final String imageUrl;

  bool read = false;

  NoticeModel({
    this.id,
    this.title,
    this.content,
    this.createDate,
    this.hasEyeCatch,
    this.status,
    this.publicDate,
    this.imageUrl,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json["id"],
      title: json["title"],
      content: json["content"],
      createDate: DateTime.parse(json["create_date"]),
      hasEyeCatch: json["has_eyecatch"],
      status: json["status"],
      publicDate: DateTime.parse(json["public_date"]),
      imageUrl: json['img_url'],
    );
  }

  String toString() {
    return 'NoticeModel{id=$id, title=$title, createDate=$createDate, publicDate=$publicDate, status=$status, read=$read}';
  }
}
