import 'package:flutter/widgets.dart';

// urlがnullの場合にエラーを回避するImageProvider

// ignore: non_constant_identifier_names
ImageProvider SafeNetworkImage(String url) {
  if (url == null)
    return AssetImage('assets/images/white.png');
  else
    return NetworkImage(url);
}
