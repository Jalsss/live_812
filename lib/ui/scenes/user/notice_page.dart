import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/domain/model/user/badge_info.dart';
import 'package:live812/domain/model/user/notice.dart';
import 'package:live812/domain/model/user/notice_ec.dart';
import 'package:live812/domain/repository/persistent_repository.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/item/NoticeEcItem.dart';
import 'package:live812/ui/item/NoticeItem.dart';
import 'package:live812/ui/scenes/user/liver/liver_purchase_details_page.dart';
import 'package:live812/ui/scenes/user/notice_details_page.dart';
import 'package:live812/ui/scenes/user/purchase_details_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:provider/provider.dart';

class NoticePage extends StatefulWidget {
  static const int SIZE = 30;

  final bool startInfo;

  NoticePage({this.startInfo = false});

  @override
  _NoticePageState createState() => _NoticePageState();

  static Future<List<NoticeModel>> requestInfoList(BuildContext context, {String infoId}) async {
    List<NoticeModel> notices;
    final service = BackendService(context);
    final response = await service.getInfo(size: NoticePage.SIZE, offset: 0, infoId: infoId);
    if (response?.result == true) {
      final data = response.getData();
      notices = [];
      for (final info in data) {
        final notice = NoticeModel.fromJson(info);
        notices.add(notice);
      }

      // 既読かどうかを取得
      final repo = Injector.getInjector().get<PersistentRepository>();
      final results = await Future.wait(notices.map((notice) => repo.isNoticeRead(notice.id)));
      final futures = List<Future>();
      for (var i = 0; i < notices.length; ++i) {
        final notice = notices[i];
        if (results[i] != null) {
          notice.read = results[i] == true;
        } else {
          futures.add(repo.insertNotice(notice));
        }
      }
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
    }
    return notices;
  }
}

class _NoticePageState extends State<NoticePage> {
  int _currentTab = 0;
  List<NoticeEcModel> _noticeEcs;
  bool _noticeEcsUnread = false;
  List<NoticeModel> _notices;
  bool _noticesUnread = false;
  bool _updated = false;

  @override
  void initState() {
    super.initState();

    final badgeInfo = Provider.of<BadgeInfo>(context, listen: false);
    _noticeEcsUnread = badgeInfo.unread;
    _noticesUnread = badgeInfo.info;

    if (widget.startInfo)
      _currentTab =  1;

    _requestInfoEc();
    _requestInfo();
  }

  void _onBack() {
    if (_updated) {
      final badgeInfo = Provider.of<BadgeInfo>(context, listen: false);
      badgeInfo.requestMyInfoBadge(context);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.NOTICE,
      titleColor: Colors.white,
      onClickBack: _onBack,
      body: WillPopScope(
        onWillPop: () {
          _onBack();
          return Future.value(false);
        },
        child: Column(
          children: <Widget>[
            DefaultTabController(
              initialIndex: _currentTab,
              length: 2,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 7),
                    child: TabBar(
                      unselectedLabelColor: ColorLive.BORDER4,
                      unselectedLabelStyle: TextStyle(
                        fontSize: 16,
                      ),
                      onTap: (i) {
                        setState(() {
                          _currentTab = i;
                        });
                      },
                      indicatorColor: ColorLive.BORDER4,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: <Widget>[
                        _buildTab('あなた宛', notice: _noticeEcsUnread),
                        _buildTab('全体', notice: _noticesUnread),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            _currentTab == 0 ? _buildInfoEc() : _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoEc() {
    if (_noticeEcs == null)
      return SpinningIndicator();

    return Expanded(
      child: ListView(
        padding: EdgeInsets.only(top: 0),
        children: List<Widget>.generate(_noticeEcs.length, (index) {
          return NoticeEcItem(
            noticeEc: _noticeEcs[index],
            onTap: () => _showEcDetail(_noticeEcs[index]),
          );
        }) + [_divider()],
      ),
    );
  }

  Widget _buildInfo() {
    if (_notices == null)
      return SpinningIndicator();

    return Expanded(
      child: ListView(
        padding: EdgeInsets.only(top: 0),
        children: List<Widget>.generate(_notices.length, (index) {
          return NoticeItem(
            notice: _notices[index],
            onTap: () => _showInfoDetail(_notices[index]),
          );
        }) + [_divider()],
      ),
    );
  }

  Widget _buildTab(String text, {bool notice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Tab(text: text),
        !notice ? null : Text('●', style: TextStyle(fontSize: 10, color: Colors.red)),
      ].where((w) => w != null).toList(),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withAlpha(20),
    );
  }

  Future<void> _requestInfo() async {
    final badgeInfo = Provider.of<BadgeInfo>(context, listen: false);
    final notices = await badgeInfo.requestNoticeInfo(context, NoticePage.SIZE);
    if (notices != null) {
      _notices = notices;
      _updateNoticeUnread();
    }

    final newNotices = await NoticePage.requestInfoList(context);
    if (newNotices != null) {
      setState(() => _notices = newNotices);
      _updateNoticeUnread();
    }
  }

  Future<void> _requestInfoEc() async {
    final service = BackendService(context);
    final response = await service.getInfoEc();
    if (response?.result == true) {
      final data = response.getData();
      List<NoticeEcModel> notices = [];
      for (final info in data) {
        final notice = NoticeEcModel.fromJson(info);
        notices.add(notice);
      }

      setState(() => _noticeEcs = notices);
      _updateNoticeEcsUnread();
    }
  }

  void _updateNoticeEcsUnread() {
    bool unread = _noticeEcs.any((e) => !e.isRead);
    if (unread != _noticeEcsUnread) {
      setState(() {
        _noticeEcsUnread = unread;
        Provider.of<BadgeInfo>(context, listen: false).unread = unread;
      });
    }
  }

  void _updateNoticeUnread() {
    bool unread = _notices.any((e) => !e.read);
    if (unread != _noticesUnread) {
      setState(() {
        _noticesUnread = unread;
        Provider.of<BadgeInfo>(context, listen: false).info = unread;
      });
    }
  }

  Future<void> _showEcDetail(NoticeEcModel noticeEc) async {
    // 取引情報を取得、既読状態にしてから取引詳細画面に遷移
    List<Future> list = [
      _requestEcInfo(noticeEc),
    ];
    if (!noticeEc.isRead)
      list.add(_postInfoEcRead(noticeEc));

    final results = await Future.wait(list);

    final purchase = results[0];
    if (purchase == null) {
      // TODO: エラー表示
      return;
    }

    if (noticeEc.isPurchase) {
      /*final result =*/ await Navigator.push(
          context,
          FadeRoute(
              builder: (context) => PurchaseDetailsPage(purchase)));
    } else {
      /*final result =*/ await Navigator.push(
          context,
          FadeRoute(
              builder: (context) => LiverPurchaseDetailsPage(purchase)));
   }
  }

  Future<void> _showInfoDetail(NoticeModel notice) async {
    if (!notice.read) {
      notice.read = true;
      Injector.getInjector().get<PersistentRepository>()
          .setNoticeRead(notice.id, true);
      _updateNoticeUnread();
      setState(() => _updated = true);
    }

    await Navigator.push(
        context,
        FadeRoute(
            builder: (context) => NoticeDetailsPage(
              model: notice,
            )));
  }

  Future<bool> _postInfoEcRead(NoticeEcModel noticeEc) async {
    final service = BackendService(context);
    final response = await service.postInfoEcRead(noticeEc.itemId);
    if (response?.result != true)
      return false;

    noticeEc.isRead = true;
    _updateNoticeEcsUnread();
    setState(() => _updated = true);
    return true;
  }

  Future<Purchase> _requestEcInfo(NoticeEcModel noticeEc) async {
    final service = BackendService(context);
    final response = await service.getEcOrderHistory(itemId: noticeEc.itemId);
    if (response?.result != true)
      return null;

    final data = response.getData();
    if (data?.isNotEmpty != true)
      return null;

    return Purchase.fromJson(data[0]);
  }
}
