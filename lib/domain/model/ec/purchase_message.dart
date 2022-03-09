/// チャット用クラス.
class PurchaseMessage {
  final int id;
  final String nickName;
  final String message;
  final String imgUrl;
  final DateTime created;
  final bool isAdmin;
  final bool isSelf;

  PurchaseMessage({
    this.id,
    this.nickName,
    this.message,
    this.imgUrl,
    this.created,
    this.isAdmin,
    this.isSelf,
  });

  factory PurchaseMessage.fromJson(Map<String, dynamic> json) {
    return PurchaseMessage(
      id: json["id"],
      nickName: json["nickname"],
      message: json["message"],
      imgUrl: json["user_img_samll_url"],
      created: DateTime.parse(json["create_date"]),
      isAdmin: json["is_admin_chat"],
      isSelf: json["is_my_chat"],
    );
  }
}
