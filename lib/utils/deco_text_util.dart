import 'package:flutter/material.dart';

// DecoText: String | List<String | HighLight>.

// デコレーションテキスト：
// 文字列 => 通常のテキスト
// 配列 => 以下の組み合わせ
//    文字列 => 通常のテキスト
//    HighLight => ハイライト
class DecoTextUtil {
  static const double FONT_SIZE = 14;
  static const double OPACITY = 1.0;
  static const TextStyle defaultTextStyle = TextStyle(
      color: Color.fromRGBO(255, 255, 255, OPACITY), fontSize: FONT_SIZE);
  static const TextStyle defaultHighLightStyle = TextStyle(
      color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: FONT_SIZE);

  static Widget build(dynamic text,
      {TextStyle style = defaultTextStyle,
       TextStyle highLightStyle = defaultHighLightStyle}) {
    if (text is String) {
      return Text(
        text,
        softWrap: true,
        style: style,
      );
    } else if (text is List) {
      return RichText(
        textAlign: TextAlign.left,
        softWrap: true,
        text: TextSpan(children: text.map((elem) {
          if (elem is String) {
            return TextSpan(
              text: elem,
              style: style,
            );
          } else if (elem is HighLight) {
            return TextSpan(
              text: elem.text,
              style: highLightStyle,
            );
          } else {
            return null;
          }
        }).toList()),
      );
    } else {
      assert(false);
      return null;
    }
  }
}

class HighLight {
  final String text;

  HighLight(this.text);
}
