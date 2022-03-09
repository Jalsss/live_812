import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/share_util.dart';

class BottomSheetShare extends StatefulWidget {
  final String liveId;
  final UserModel liverUserModel;
  final void Function() onBack;

  BottomSheetShare({@required this.liveId, @required this.liverUserModel, this.onBack});

  @override
  _BottomSheetShareState createState() => _BottomSheetShareState();
}

class _BottomSheetShareState extends State<BottomSheetShare> {
  static final _kShareButtonSvgPaths = [
    "assets/svg/ic_twitter.svg",
    "assets/svg/ic_fb.svg",
    "assets/svg/ic_line.svg",
    "assets/svg/ic_attach.svg",
  ];

  static const _SHARE_TWITTER = 0;
  static const _SHARE_FACEBOOK = 1;
  static const _SHARE_LINE = 2;
  static const _SHARE_COPY = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: EdgeInsets.symmetric(horizontal: 10),
      color: ColorLive.BLUE_BG,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              MaterialButton(
                minWidth: 50,
                padding: EdgeInsets.symmetric(horizontal: 2),
                onPressed: () {
                  widget.onBack();
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 5),
                    Text(
                      Lang.BACK_MENU,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_kShareButtonSvgPaths.length, (i) => Container(
              width: 30,
              child: RawMaterialButton(
                onPressed: () {
                  _share(i);
                },
                padding: EdgeInsets.all(5),
                shape: CircleBorder(),
                child: SvgPicture.asset(
                  _kShareButtonSvgPaths[i],
                  color: Colors.white,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _share(int index) async {
    // BottomSheetShare は視聴者側からしか呼ばれない前提。
    String text = 'LIVE812で${widget.liverUserModel.nickname}さんのライブ配信を視聴しよう♪';

    switch (index) {
      case _SHARE_TWITTER:
        ShareUtil.shareOnTwitterForUser(context, widget.liverUserModel, text: text);
        break;
      case _SHARE_FACEBOOK:
        ShareUtil.shareOnFacebookForUser(context, widget.liverUserModel, text: text);
        break;
      case _SHARE_LINE:
        ShareUtil.shareOnLineForUser(context, widget.liverUserModel, text: text);
        break;
      case _SHARE_COPY:
        {
          final info = ShareUtil.generateUserShareInfo(widget.liverUserModel, text: text);
          var shareText = info.item1;
          final tagStr = info.item2;
          final url = info.item3;
          if (tagStr.isNotEmpty) {
            shareText = '$shareText $tagStr';
          }
          final data = ClipboardData(text: '$shareText\n$url');
          Clipboard.setData(data)
              .then((_) {
                Flushbar(
                  icon: Icon(
                    Icons.info_outline,
                    size: 28.0,
                    color: Colors.blue[300],
                  ),
                  message:  Lang.COPIED,
                  duration:  Duration(milliseconds: 2000),
                  margin: EdgeInsets.all(8),
                  borderRadius: 8,
                )..show(context);
              });
        }
        break;
      default:
        break;
    }
  }
}
