import 'dart:convert';

class Inquiry {
  final String token;
  final String type;
  final String terminal;
  final String os;
  final String appVer;
  final String symbol;
  final String nickname;
  final String mail;
  final String message;
  final String orderId;
  final List<String> base64Images;

  Inquiry(this.token, {
    this.type,
    this.terminal,
    this.os,
    this.appVer,
    this.symbol,
    this.nickname,
    this.mail,
    this.message,
    this.orderId,
    this.base64Images,
  });

  Map toMap() {
    Map map = {
      'token': this.token,
      'type': this.type,
      'terminal': this.terminal,
      'os': this.os,
      'app_ver': this.appVer,
      'user_id': this.symbol,  // APIへは user_id として渡す
      'nickname': this.nickname,
      'mail': this.mail,
      'message': this.message,
      'order_id': this.orderId,
    };
    if (base64Images?.isNotEmpty == true) {
      map['thumbs'] = jsonEncode(base64Images);
    }
    return map;
  }
}
