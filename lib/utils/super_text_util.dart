// HTMLじゃないけど、URLの自動リンクができるよう分割するユーティリティ

import 'package:flutter/widgets.dart';
import 'package:live812/utils/widget/url_text_span.dart';

abstract class SuperTextUtil {
  static RegExp reUrl = RegExp(r"\b(https?://[\w!?/+\-~=;.,*&@#$%()'\[\]]+)");

  static List<SuperText> parse(String text) {
    final result = List<SuperText>();
    while (text.isNotEmpty) {
      Match match = reUrl.firstMatch(text);
      if (match == null) {
        result.add(SuperText(SuperTextType.Text, text));
        break;
      }

      if (match.start > 0)
        result.add(SuperText(SuperTextType.Text, text.substring(0, match.start)));
      result.add(SuperText(SuperTextType.Url, match.group(1)));
      text = text.substring(match.end);
    }
    return result;
  }
}

enum SuperTextType {
  Text,
  Url,
}

class SuperText {
  final SuperTextType type;
  final String text;

  SuperText(this.type, this.text);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SuperText &&
            runtimeType == other.runtimeType &&
            type == other.type &&
            text == other.text;
  }

  @override
  int get hashCode => type.hashCode ^ text.hashCode;

  @override
  String toString() {
    return 'SuperText{$type: $text}';
  }
}

class SuperTextWidget extends StatelessWidget {
  final List<SuperText> list;
  final int maxLines;
  final TextAlign textAlign;
  final TextStyle textStyle;
  final bool external;

  SuperTextWidget(this.list,
      {this.maxLines, this.textAlign = TextAlign.start, this.textStyle, this.external = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: list == null ? TextSpan(text: '') : TextSpan(
        children: list.map((st) {
          if (st.type == SuperTextType.Text)
            return TextSpan(text: st.text, style: textStyle);
          return UrlTextSpan(context, st.text, external: external);
        }).toList(),
      ),
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}
