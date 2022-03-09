import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live812/domain/model/live/gift_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_gift.dart';
import 'package:live812/ui/scenes/live/widget/liver_profile_background.dart';
import 'package:live812/utils/anim/gift_animation_widget.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:provider/provider.dart';

class DebugGiftAnimePage extends StatefulWidget {
  final bool landscape;

  DebugGiftAnimePage({this.landscape = false});

  @override
  DebugGiftAnimePageState createState() => DebugGiftAnimePageState();
}

class DebugGiftAnimePageState extends State<DebugGiftAnimePage> {
  final List<int> _giftAnimationQueue = [];
  List<GiftInfoModel> _giftInfoList;

  @override
  void dispose() {
    //ステータスバー表示
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if (!widget.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      //ステータスバー非表示
      SystemChrome.setEnabledSystemUIOverlays([]);

      // 右向きを優先させるため、いったん右向きだけを有効にして、ちょっと立った後に両方有効にする
      // iOSとAndroidで逆向きっぽい
      SystemChrome.setPreferredOrientations([
        Platform.isIOS ? DeviceOrientation.landscapeRight : DeviceOrientation.landscapeLeft,
      ]);
      Timer(Duration(seconds: 1), () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      });
    }

    _requestGiftInfo();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    Orientation orientation = widget.landscape ? Orientation.landscape : Orientation.portrait;

    final mq = MediaQuery.of(context);
    final contentWidth = mq.size.width - mq.padding.left - mq.padding.right;

    return Stack(
      children: <Widget>[
        LiverProfileBackground(userModel.id, isLeave: false, cameraOff: true),

        SafeArea(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: GiftAnimationWidget(
                    animationQueue: _giftAnimationQueue,
                  ),
                ),

                // メッセージエリア
                Positioned(
                  bottom: 0,
                  left: 10,
                  right: orientation == Orientation.portrait ? 80 : null,
                  width: orientation == Orientation.portrait ? null : contentWidth * (2.0 / 3),  // ランドスケープの場合：コンテンツ幅の2/3としてみる
                  height: 200,
                  child: Container(
                    color: Color(0x80ff00ff),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildPortraitMenu(context),
                ),

                Positioned(
                  top: orientation == Orientation.portrait ? 6 : 0,
                  left: 0,
                  right: orientation == Orientation.landscape ? 90 : 0,  // ランドスケープの場合右にメニューがあるので、その分幅を狭める
                  child: _buildTopRow(context, orientation),
                ),
              ],
            ),

            bottomNavigationBar: orientation == Orientation.landscape ? null : Container(
              width: MediaQuery.of(context).size.width,
              height: 54,
              color: ColorLive.BLUE_BG,
              child: FlatButton(
                child: Text(
                  'ダミー',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                onPressed: null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopRow(BuildContext context, Orientation orientation) {
    return Container(
      margin: EdgeInsets.only(
        top: orientation == Orientation.portrait ? 0 : 10,
        left: 10,
        right: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container()),
          Container(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Row(
                children: <Widget>[
                  Text(
                    Lang.CLOSE,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      shadows: const [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black,
                          offset: Offset(0, 1),
                        ),
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black,
                          offset: Offset(2, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  ClipOval(
                    child: Container(
                      height: 25,
                      width: 25,
                      padding: EdgeInsets.all(5),
                      color: ColorLive.TRANS_90,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitMenu(BuildContext context) {
    return Column(
      children: <Widget>[
        RawMaterialButton(
          onPressed: () {
            _bottomSheetGift(onTap: _sendGift);
          },
          shape: CircleBorder(),
          elevation: 2.0,
          padding: EdgeInsets.all(5),
          child: Container(
            height: 80.0,
            child:
            Image.asset('assets/images/ico02.png'),
          ),
        ),
      ],
    );
  }

  Future<void> _bottomSheetGift({bool Function(int, GiftInfoModel) onTap}) async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return BottomSheetGift(
            giftInfoList: _giftInfoList,
            onBack: () {
              Navigator.of(context).pop();
              KeyboardUtil.close(context);
            },
            onTap: (int animationIndex, GiftInfoModel giftInfo) {
              if (onTap(animationIndex, giftInfo))
                Navigator.of(context).pop();
            },
          );
        });
  }

  bool _sendGift(int index, GiftInfoModel giftInfo) {
    setState(() => _giftAnimationQueue.add(giftInfo.id));
    return true;
  }

  Future<bool> _requestGiftInfo() async {
//    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);
    // TODO: 仮データじゃなくなったら直接APIを叩く
    final list = await BottomSheetGift.requestGiftInfo(service, null);
    if (list == null)
      return false;
    setState(() {
      _giftInfoList = list;
    });
    return true;
  }
}
