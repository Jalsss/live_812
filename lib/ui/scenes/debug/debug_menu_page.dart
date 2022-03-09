import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/news_event.dart';
import 'package:live812/ui/item/SettingItem.dart';
import 'package:live812/ui/scenes/debug/debug_preview_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';

import 'debug_gift_anime_page.dart';

class _DebugMenuItem {
  final String title;
  final void Function(BuildContext context) onTap;

  _DebugMenuItem(this.title, this.onTap);
}

final _menuItems = [
  _DebugMenuItem('ギフトアニメ確認', (BuildContext context) {
    Navigator.push(
        context,
        FadeRoute(builder: (context) => DebugGiftAnimePage()));
  }),
  _DebugMenuItem('ギフトアニメ確認（横）', (BuildContext context) {
    Navigator.push(
        context,
        FadeRoute(builder: (context) => DebugGiftAnimePage(landscape: true)));
  }),
  _DebugMenuItem('イベントPOPアップの既読を削除', (BuildContext context) {
    final model = Provider.of<NewsEventModel>(context, listen: false);
    model.deleteLastReadDate();
    model.deleteLastShowDate();
  }),
  _DebugMenuItem('美顔テスト', (BuildContext context) {
    Navigator.push(
        context,
        FadeRoute(builder: (context) => DebugPreviewPage()));
  }),
];

class DebugMenuPage extends StatefulWidget {
  @override
  DebugMenuPageState createState() => DebugMenuPageState();
}

class DebugMenuPageState extends State<DebugMenuPage> {
  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: 'デバッグメニュー',
      titleColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        children: _menuItems.map<Widget>((elem) {
          return InkWell(
            onTap: () => elem.onTap(context),
            child: SettingItem(
              title: elem.title,
            ),
          );
        }).toList().toList() + [
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: ColorLive.DIVIDER,
          ),
        ],
      ),
    );
  }
}
