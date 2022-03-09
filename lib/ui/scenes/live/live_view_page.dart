import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinity_page_view/infinity_page_view.dart';
import 'package:live812/domain/model/live/room_info.dart';
import 'package:live812/ui/scenes/live/live_view_content.dart';
import 'package:live812/utils/deep_link_handler.dart';
import 'package:live812/utils/push_notification_manager.dart';
import 'package:screen/screen.dart';
import 'package:home_indicator/home_indicator.dart';

class LiveViewPage extends StatefulWidget {
  final List<RoomInfoModel> roomInfos;
  final int initialPage;

  LiveViewPage(this.roomInfos, this.initialPage);

  @override
  _LiveViewPageState createState() => _LiveViewPageState();
}

class _LiveViewPageState extends State<LiveViewPage> {
  bool disableRoomChange = true;
  InfinityPageController _infinityPageController;

  @override
  void dispose() {
    HomeIndicator.show();
    DeepLinkHandlerStack.instance().pop();
    PushNotificationManager.instance().popHandler();

    Screen.keepOn(false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    HomeIndicator.hide();
    Screen.keepOn(true);

    final roomInfo = widget.roomInfos[widget.initialPage];
    // 画面の向きを変更.
    _setOrientations(isPortrait : roomInfo.isPortrait);
    _infinityPageController = new InfinityPageController(initialPage: widget.initialPage);

    DeepLinkHandlerStack.instance().push(DeepLinkHandler(
      showLiverProfile: (liverId) {
        // ライブ中はプロフィール画面に遷移させない
      },
      showChat: (orderId) {
        // ライブ中はチャット画面に遷移させない
      }
    ));

    PushNotificationManager.instance().pushHandler(PushNotificationHandler(
      onReceive: (action, message) {
        // ライブ中は遷移させない
      },
    ));
  }

  /// 視聴画面の向きの設定を変更.
  void _setOrientations({bool isPortrait}) {
    if (isPortrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    if (disableRoomChange) {
      return LiveViewContent(
        roomInfo: widget.roomInfos[widget.initialPage],
        setOrientation: (value) {
          _setOrientations(isPortrait: value);
        },
      );
    }

    if (widget.roomInfos.length <= 1) {
      return LiveViewContent(
        roomInfo: widget.roomInfos[widget.initialPage],
        setOrientation: (value) {
          _setOrientations(isPortrait: value);
        },
      );
    }

    return InfinityPageView(
      controller: _infinityPageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.roomInfos.length,
      itemBuilder: (BuildContext context, int index) {
        return LiveViewContent(
          roomInfo: widget.roomInfos[index],
          setOrientation: (value) {
            _setOrientations(isPortrait: value);
          },
        );
      },
      onPageChanged: (int index) {
      },
    );
  }
}
