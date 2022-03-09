import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/route/slide_up_route.dart';
import 'package:live812/utils/widget/web_view_page.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlTextSpan extends TextSpan {
  UrlTextSpan(BuildContext context, String text, {
    TextStyle style = const TextStyle(color: Colors.blue),
    String url,
    bool external = false,
  }) : super(
    text: text,
    style: style,
    recognizer: TapGestureRecognizer()..onTap = () async {
      if (external != true) {
        Navigator.push(
            context,
            SlideUpRoute(
                page: WebViewPage(
                  appBarColor: ColorLive.MAIN_BG,
                  url: url ?? text,
                  toGivePermissionJs: true,
                )));
      } else {
        await launch(url ?? text);
      }
    },
  );
}
