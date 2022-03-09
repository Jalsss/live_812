import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/web_view_page.dart';

/// 出品時の規約をまとめたWidget.
class ProductTerms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _TermText(
                title: Lang.LIVE_COMMERCE_TERMS_AND_CONDITION_TITLE,
                url: 'http://agreement.live812.works/ec.html',
              ),
              Text(
                "・",
                style: TextStyle(color: Colors.white),
              ),
              _TermText(
                title: Lang.MERCHANT_TERMS_TITLE,
                url: 'http://agreement.live812.works/shop.html',
              ),
            ],
          ),
          Row(
            children: <Widget>[
              _TermText(
                title: Lang.LIST_OF_PROHIBITED_ITEMS_TITLE,
                url: 'http://agreement.live812.works/ban_item.html',
              ),
              Text(
                "・",
                style: TextStyle(color: Colors.white),
              ),
              _TermText(
                title: Lang.PRIVACY_POLICY_TITLE,
                url: 'http://agreement.live812.works/privacy.html',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 規約のテキスト.
class _TermText extends StatelessWidget {
  final String title;
  final String url;

  _TermText({this.title, this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        title,
        style: TextStyle(
          color: ColorLive.BLUE,
          decoration: TextDecoration.underline,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          FadeRoute(
            builder: (context) => WebViewPage(
              title: title,
              titleColor: Colors.white,
              appBarColor: ColorLive.MAIN_BG,
              url: url,
              toGivePermissionJs: false,
            ),
          ),
        );
      },
    );
  }
}
