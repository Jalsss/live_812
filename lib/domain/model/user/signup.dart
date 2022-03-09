import 'package:flutter/material.dart';

class SignUpModel extends ChangeNotifier {
  final String token;
  final String id;
  final String nickname;
  final String symbol;
  final String password;

  SignUpModel(this.token,
      this.id,
      this.nickname,
      this.symbol,
      this.password);

  Map toMap() {
    return {
      'token': this.token,
      'id': this.id,
      'nickname': this.nickname,
      'user_id': this.symbol,
      'pass': this.password,
    };
  }
}
