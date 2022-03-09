import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/ui/item/SettingItem.dart';
import 'package:live812/ui/scenes/debug/debug_menu_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/domain/build_type.dart';
import 'package:live812/utils/gift_downloader.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/web_view_page.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLiver =
        Provider.of<UserModel>(context, listen: false)?.isLiver == true;
    final isDebug = Injector.getInjector().get<BuildType>() == BuildType.Debug;

    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.SETTING,
      titleColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 0,
        ),
        children: [
          SettingItem(
            title: 'ニックネーム変更',
            onTap: () => Navigator.pushNamed(context, '/setting/nickname'),
          ),
          SettingItem(
            title: 'メールアドレス変更',
            onTap: () => Navigator.pushNamed(context, '/setting/email'),
          ),
          SettingItem(
            title: 'パスワード変更',
            onTap: () => Navigator.pushNamed(context, '/setting/password'),
          ),
          if (isLiver)
            SettingItem(
              title: 'ブロック設定',
              onTap: () => Navigator.pushNamed(context, '/setting/block'),
            ),
          SettingItem(
            title: '友達に紹介',
            onTap: () => Navigator.pushNamed(context, '/setting/share'),
          ),
          SettingItem(
            title: '特定商取引法に基づく表記',
            onTap: () =>
                Navigator.pushNamed(context, '/setting/specified_commercial'),
          ),
          SettingItem(
            title: 'LIVE812利用規約',
            onTap: () => _openWebView(
              context,
              title: 'LIVE812利用規約',
              url: 'http://agreement.live812.works/use.html',
              toGivePermissionJs: true,
            ),
          ),
          if (isLiver)
            SettingItem(
              title: 'LIVE812ストリーミング配信規約',
              onTap: () => _openWebView(
                context,
                title: 'LIVE812ストリーミング配信規約',
                url: 'http://agreement.live812.works/liver.html',
                toGivePermissionJs: false,
              ),
            ),
          SettingItem(
            title: Lang.LIVE_COMMERCE_TERMS_AND_CONDITION_TITLE,
            onTap: () => _openWebView(
              context,
              title: Lang.LIVE_COMMERCE_TERMS_AND_CONDITION_TITLE,
              url: 'http://agreement.live812.works/ec.html',
              toGivePermissionJs: false,
            ),
          ),
          if (isLiver)
            SettingItem(
              title: Lang.MERCHANT_TERMS_TITLE,
              onTap: () => _openWebView(
                context,
                title: Lang.MERCHANT_TERMS_TITLE,
                url: 'http://agreement.live812.works/shop.html',
                toGivePermissionJs: false,
              ),
            ),
          if (isLiver)
            SettingItem(
              title: Lang.LIST_OF_PROHIBITED_ITEMS_TITLE,
              onTap: () => _openWebView(
                context,
                title: Lang.LIST_OF_PROHIBITED_ITEMS_TITLE,
                url: 'http://agreement.live812.works/ban_item.html',
                toGivePermissionJs: false,
              ),
            ),
          SettingItem(
            title: Lang.PRIVACY_POLICY_TITLE,
            onTap: () => _openWebView(
              context,
              title: Lang.PRIVACY_POLICY_TITLE,
              url: 'http://agreement.live812.works/privacy.html',
              toGivePermissionJs: false,
            ),
          ),
          SettingItem(
            title: Lang.CONTACT,
            onTap: () => Navigator.pushNamed(context, '/setting/contact'),
          ),
          SettingItem(
            title: Lang.LOGOUT,
            onTap: () => Navigator.pushNamed(context, '/setting/logout'),
          ),
          if (GiftDownloader.isTargetPlatform)
            SettingItem(
              title: 'ファイル再ダウンロード',
              onTap: () => GiftDownloader.execute(
                context,
                force: true,
              ),
            ),
          _buildVersion(),
          SettingItem(
            title: Lang.QUIT_SERVICE,
            onTap: () => Navigator.pushNamed(context, '/setting/quit_service'),
          ),
          if (isDebug)
            SettingItem(
              title: '（デバッグメニュー）',
              onTap: () => Navigator.push(
                context,
                FadeRoute(
                  builder: (context) => DebugMenuPage(),
                ),
              ),
            ),
          const Divider(
            height: 0.5,
            thickness: 0.5,
            color: ColorLive.DIVIDER,
          ),
        ],
      ),
    );
  }

  Future<void> _openWebView(
    BuildContext context, {
    String title,
    String url,
    bool toGivePermissionJs = false,
  }) async {
    await Navigator.push(
      context,
      FadeRoute(
        builder: (context) => WebViewPage(
          title: title,
          titleColor: Colors.white,
          appBarColor: ColorLive.MAIN_BG,
          url: url,
          toGivePermissionJs: toGivePermissionJs,
        ),
      ),
    );
  }

  Widget _buildVersion() {
    return FutureProvider<String>(
      create: (_) => _getAppVersion(),
      child: Consumer<String>(
        builder: (_context, version, _child) {
          return version == null
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: ColorLive.DIVIDER,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: const Text(
                              'バージョン',
                              softWrap: true,
                              maxLines: 3,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            version,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

// アプリバージョン
  Future<String> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    if (Injector.getInjector().get<BuildType>() == BuildType.Debug)
      return '$version (Debug)';
    return version;
  }
}
