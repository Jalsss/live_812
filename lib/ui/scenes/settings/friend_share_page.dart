import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/ui/item/SettingItem.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/share_util.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

const int _FACEBOOK = 0;
const int _TWITTER = 1;
const int _LINE = 2;
const int _COPY = 3;

class FriendSharePage extends StatelessWidget {
  static const List<String> settings = [
    'シェア',
  ];

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.REFER_FRIEND,
      titleColor: Colors.white,
      body: Consumer<UserModel>(
        builder: (context, userModel, _) {
          return ListView(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            children: List<Widget>.generate(settings.length, (index) {
              return InkWell(
                onTap: () {
                  String text, url;
                  if (userModel.isLiver) {
                    text = Lang.SHARE_LIVER_TO_FRIEND;
                    url = ShareUtil.urlForLiver(userModel.id);
                  } else {
                    text = Lang.SHARE_TEXT;
                    url = Lang.SHARE_URL;
                  }
                  Share.share('$text\n$url');
                },
                child: SettingItem(
                  title: settings[index],
                ),
              );
            }) + [
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: ColorLive.DIVIDER,
              ),
                userModel.isLiver
                    ? Container(
                        height: 40,
                        child: const Center(
                          child: Text(
                            "アフィリエイトリンクではございません。",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : Container(),
              ],
          );
        }
      ),
    );
  }
}
