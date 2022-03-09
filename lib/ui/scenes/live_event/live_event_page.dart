import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/ui/scenes/live_event/live_event_closed_page.dart';
import 'package:live812/ui/scenes/live_event/live_event_management_page.dart';
import 'package:live812/ui/scenes/live_event/live_event_open_page.dart';
import 'package:live812/ui/scenes/live_event/live_event_wanted_page.dart';
import 'package:live812/ui/scenes/live_event/live_event_schedule_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:provider/provider.dart';

class LiveEventPage extends StatefulWidget {
  @override
  _LiveEventPageState createState() => _LiveEventPageState();
}

class _LiveEventPageState extends State<LiveEventPage> {
  var _tabs = <Tab>[
    Tab(text: '開催中'),
    Tab(text: '開催予定'),
    Tab(text: '終了'),
  ];

  var _pages = <Widget>[
    LiveEventOpenPage(),
    LiveEventSchedulePage(),
    LiveEventClosedPage(),
  ];

  @override
  void initState() {
    super.initState();

    final userModel = Provider.of<UserModel>(context, listen: false);
    if (userModel?.isLiver ?? false) {
      // ライバーの場合はページを追加.
      _tabs.add(Tab(text: '参加募集'));
      _pages.add(LiveEventWantedPage());
      // イベント作成権限がある人のみイベント管理を追加.
      if (userModel.enableEvent) {
        _tabs.add(Tab(text: 'イベント管理'));
        _pages.add(LiveEventManagementPage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DefaultTabController(
        length: _tabs.length,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Center(
                child: const Text(
                  'イベント',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TabBar(
              isScrollable: true,
              tabs: _tabs,
              indicatorColor: ColorLive.YELLOW,
              labelColor: Colors.white,
              unselectedLabelColor: ColorLive.C99,
            ),
            Expanded(
              child: TabBarView(
                children: _pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
