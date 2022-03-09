import 'package:flutter/foundation.dart';

class DeepLinkHandler {
  final void Function(String) showLiverProfile;
  final void Function(String) showChat;

  const DeepLinkHandler({this.showLiverProfile, this.showChat});
}

class DeepLinkHandlerStack {
  static DeepLinkHandlerStack _instance;
  static DeepLinkHandlerStack instance() {
    if (_instance == null)
      _instance = DeepLinkHandlerStack._internal();
    return _instance;
  }

  // 外部からインスタンスが作られないようにする
  factory DeepLinkHandlerStack() => instance();

  final _handlers = List<DeepLinkHandler>();

  // 内部から呼び出してインスタンスを作る為のコンストラクタ
  DeepLinkHandlerStack._internal();

  void push(DeepLinkHandler callback) {
    _handlers.add(callback);
  }

  void pop() {
    _handlers.removeLast();
  }

  void showLiverProfile(String liverId) {
    if (_handlers.isNotEmpty) {
      _handlers.last.showLiverProfile(liverId);
    } else {
      debugPrint('No deep link handler');
    }
  }

  void showChat(String orderId) {
    if (_handlers.isNotEmpty) {
      _handlers.last.showChat(orderId);
    } else {
      debugPrint('No deep link handler');
    }
  }
}
