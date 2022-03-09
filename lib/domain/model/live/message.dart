class MessageModel {
  final dynamic decoText;
  final String userId;
  final MessageType type;

  MessageModel(this.type, this.decoText, this.userId);
}

enum MessageType {
  CHAT,
  LIKE,
  GIFT,
  SALES,
  SOLD,
  SYSTEM,
}
