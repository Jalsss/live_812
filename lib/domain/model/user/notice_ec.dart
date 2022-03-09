class NoticeEcModel {
  final String itemId;
  final String userId;
  final DateTime createDate;
  final String title;
  final String message;
  bool isRead;
  final bool isPurchase;

  NoticeEcModel({
    this.itemId,
    this.userId,
    this.createDate,
    this.title,
    this.message,
    this.isRead,
    this.isPurchase,
  });

  factory NoticeEcModel.fromJson(Map<String, dynamic> json) {
    return NoticeEcModel(
      itemId: json["item_id"],
      userId: json["user_id"],
      createDate: DateTime.parse(json["create_date"]),
      title: json["title"],
      message: json["message"],
      isRead: json["is_read"],
      isPurchase: json['is_purchase'],
    );
  }

  String toString() {
    return 'NoticeEcModel{id=$itemId, message=$message, isRead=$isRead}';
  }
}
