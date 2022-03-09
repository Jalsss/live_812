import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/utils/route/slide_up_route.dart';
import 'package:live812/utils/widget/web_view_page.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:live812/utils/consts/consts.dart';

import 'consts/ColorLive.dart';
import 'consts/language.dart';

class ShareUtil {
  static const String _FACEBOOK_APP_ID = '179552570023004';
  static const String _SHARE_URL = 'https://share.live812.works/';
  static const String _FACEBOOK_REDIRECT_URL = 'https://share.live812.works/';  // TODO: シェアしてくれてありがとう！的なページに遷移させる

  // ライバーのシェアページURL
  static String urlForLiver(String userId) {
    return 'https://share.live812.works/user/$userId';
  }

  static List<String>iapItemNames() {
    if (Platform.isIOS) {
      return Consts.IAP_ITEM_NAMES_IOS;
    } else if (Platform.isAndroid) {
      return Consts.IAP_ITEM_NAMES_ANDROID;
    }
  }

  static Future<void> shareOnFacebook(BuildContext context, String text, {String url}) {
    if (url == null)
      url = _SHARE_URL;

    return _share(context,
        'https://m.facebook.com/dialog/feed?' +
            'app_id=$_FACEBOOK_APP_ID' +
            '&display=touch' +
            '&quote=${Uri.encodeQueryComponent(text)}' +
            '&link=${Uri.encodeQueryComponent(url)}' +
            '&redirect_uri=${Uri.encodeQueryComponent(_FACEBOOK_REDIRECT_URL)}');
  }

  static Future<void> shareOnTwitter(BuildContext context, String text, {String url}) {
    if (url != null) {
      text = text.substring(0, min(139, text.length)) + '\n' + url;
    } else {
      text = text.substring(0, min(140, text.length));
    }

    return _share(context,
        'https://twitter.com/intent/tweet?text=${Uri.encodeQueryComponent(text)}');
  }

  static Future<void> shareOnLine(BuildContext context, String text, {String url}) {
    if (url != null)
      text = '$text\n$url';

    if (Platform.isIOS) {
      return _open('https://line.me/R/msg/text/?${Uri.encodeQueryComponent(text)}');
    } else {
      return _share(context,
          'https://line.me/R/msg/text/?${Uri.encodeQueryComponent(text)}');
    }
  }

  static Future<void> shareOnFacebookForUser(BuildContext context, UserModel userModel, {List<String> tags, String text}) {
    final info = generateUserShareInfo(userModel, tags: tags, text: text);
    var shareText = info.item1;
    final tagStr = info.item2;
    final url = info.item3;
    if (tagStr.isNotEmpty) {
      shareText = '$shareText $tagStr';
    }
    return shareOnFacebook(context, shareText, url: url);
  }

  static Future<void> shareOnTwitterForUser(BuildContext context, UserModel userModel, {List<String> tags, String text}) {
    final info = generateUserShareInfo(userModel, tags: tags, text: text);
    var shareText = info.item1;
    final tagStr = info.item2;
    final url = info.item3;
    if (tagStr.isNotEmpty) {
      if (tagStr.length < 140 && shareText.length + tagStr.length >= 140) {
        shareText = shareText.substring(0, 140 - 1 - tagStr.length) + ' ' + tagStr;
      } else {
        shareText = '$shareText $tagStr';
      }
    }
    return shareOnTwitter(context, shareText, url: url);
  }

  static Future<void> shareOnLineForUser(BuildContext context, UserModel userModel, {List<String> tags, String text}) {
    final info = generateUserShareInfo(userModel, tags: tags, text: text);
    var shareText = info.item1;
    final tagStr = info.item2;
    final url = info.item3;
    if (tagStr.isNotEmpty) {
      shareText = '$shareText $tagStr';
    }
    return shareOnLine(context, shareText, url: url);
  }

  static Tuple3<String, String, String> generateUserShareInfo(UserModel userModel, {List<String> tags, String text}) {
    text ??= Lang.SHARE_LIVER_BROADCAST;
    final tagStr = tags == null ? '' : tags.where((tag) => tag != null && tag.isNotEmpty).map((tag) => '#$tag').join(' ');
    final url = urlForLiver(userModel.id);
    return Tuple3<String, String, String>(text, tagStr, url);
  }

  static _open(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _open('https://apps.apple.com/jp/app/line/id443904275');
      throw 'Could not Launch $url';
    }
    return Future.value(null);
  }

  static Future<void> _share(BuildContext context, String url) {
    return Navigator.push(
        context,
        SlideUpRoute(
            page: WebViewPage(
              title: Lang.SHARE,
              url: url,
              appBarColor: ColorLive.MAIN_BG,
              titleColor: Colors.white,
              toGivePermissionJs: true,
            )));
  }
}
