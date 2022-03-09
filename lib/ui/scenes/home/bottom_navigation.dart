import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/domain/model/live/room_info.dart';
import 'package:live812/domain/model/user/badge_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/repository/persistent_repository.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/gift_usecase.dart';
import 'package:live812/domain/usecase/live_event_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/home/home.dart';
import 'package:live812/ui/scenes/live/live.dart';
import 'package:live812/ui/scenes/live/live_view_page.dart';
import 'package:live812/ui/scenes/live_event/live_event_detail_page.dart';
import 'package:live812/ui/scenes/live_event/live_event_page.dart';
import 'package:live812/ui/scenes/shop/product_detail_page.dart';
import 'package:live812/ui/scenes/timeline/timeline.dart';
import 'package:live812/ui/scenes/user/liver/liver_purchase_details_page.dart';
import 'package:live812/ui/scenes/user/my_page.dart';
import 'package:live812/ui/scenes/user/notice_details_page.dart';
import 'package:live812/ui/scenes/user/notice_page.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:live812/ui/scenes/user/purchase_chat_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/deep_link_handler.dart';
import 'package:live812/utils/focus_util.dart';
import 'package:live812/utils/gift_downloader.dart';
import 'package:live812/utils/push_notification_manager.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/bottom_bar.dart';
import 'package:live812/utils/widget/fixed_center_docked_fab_location.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:provider/provider.dart';

const _TAB_HOME = 0;
const _TAB_LIVE_EVENT = 1;
const _TAB_TIMELINE = 2;
const _TAB_MY_PAGE = 3;
const _TAB_COUNT = 4;

class BottomNav extends StatefulWidget {
  BottomNav({Key key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> with TickerProviderStateMixin {
  TabController _tabController;
  int _currentTab = 0;
  bool _isLiver = true;
  bool _hideBroadcastButton = false;
  bool _isLoading = false;
  bool _invisibleBlocker = false;
  void Function() _reloadHome;
  void Function() _reloadTimeline;
  void Function() _reloadMyPage;

  @override
  void dispose() {
    DeepLinkHandlerStack.instance().pop();
    PushNotificationManager.instance().popHandler();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    PushNotificationManager.instance().setUp(context);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness: Brightness.dark));

    final userModel = Provider.of<UserModel>(context, listen: false);
    _isLiver = userModel?.isLiver == true;

    _tabController = TabController(vsync: this, length: _TAB_COUNT);

    _requestMyInfoBadge();

    Future(() async {
      // ギフトダウンロード.
      final manifest = await GiftUseCase.loadManifestJson();
      final message = manifest.isEmpty
          ? 'ギフトデータのダウンロード中...\nしばらくお待ち下さい'
          : 'アプリの起動中...\nしばらくお待ち下さい';
      await GiftDownloader.execute(context, message: message);

      DeepLinkHandlerStack.instance().push(DeepLinkHandler(
          showLiverProfile: (liverId) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileViewPage(userId: liverId)));
          },
          showChat: (orderId) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PurchaseChatPage(orderId: orderId)));
          }
      ));

      PushNotificationManager.instance().pushHandler(PushNotificationHandler(
        onReceive: (action, message) {
          if (action == PushAction.RESUME) {
            _handlePushNotificationMessage(message);
          }
        },
      ));

      // プッシュ通知タップで起動した場合の処理
      final launchMessage = PushNotificationManager.instance().launchMessage;
      if (launchMessage != null) {
        PushNotificationManager.instance().clearLaunchMessage();
        _handlePushNotificationMessage(launchMessage);
      }
    });
  }

  void _handlePushNotificationMessage(dynamic message) {
    switch (message['type']) {
      case 'timeline':
        _moveToHome();
        _onTabSelected(_TAB_TIMELINE);
        break;
      case 'info':
        _requestInfo(message['id']);
        break;
      case 'ec_sales':
        _requestSalesProduct(message['sales_id'], message['item_id']);
        break;
      case 'ec_purchase':
        _requestPurchaseProduct(
            message['sales_id'], message['purchase_id'], message['item_id']);
        break;
      case 'broadcast':
        _requestBroadcast(message['liver_id'], message['live_id']);
        break;
      case 'ec_chat':
        _moveToChat(message['order_id']);
        break;
      case 'event_start':
        _requestLiveEvent(message['id']);
        break;
      default:
        print('push notification not handled: $message');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor:
              _currentTab == 0 ? ColorLive.BLUE : ColorLive.MAIN_BG,
          //resizeToAvoidBottomPadding: false,
          extendBody: true,
          body: WillPopScope(
            onWillPop: () => Future.value(!_isLoading),
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Center(
                child: TabBarView(
                  children: <Widget>[
                    Home(
                      onSetUp: (f) => _reloadHome = f,
                      setLoading: (loading, {bool invisible = false}) {
                        setState(() {
                          _isLoading = loading;
                          _invisibleBlocker = invisible;
                        });
                      },
                    ),
                    LiveEventPage(),
                    TimelinePage(
                      onSetUp: (f) => _reloadTimeline = f,
                      setHideBroadcastButton: _setHideBroadcastButton,
                    ),
                    MyPage(onSetUp: (f) => _reloadMyPage = f),
                  ],
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Consumer<BadgeInfo>(
            builder: (context, badgeInfo, _) {
              return FABBottomAppBar(
                activeIndex: _currentTab,
                onTabSelected: (index) {
                  FocusUtil.unFocus(context);
                  _onTabSelected(index);
                },
                normalColor: Colors.grey[400],
                selectedColor: ColorLive.BLUE,
                backgroundColor: Colors.black,
                isFab: _isLiver,
                notchedShape: CircularNotchedRectangle(),
                items: [
                  FABBottomItem(text: 'ホーム', imgUrl: "assets/svg/tabs/play"),
                  FABBottomItem(text: 'イベント', imgUrl: 'assets/svg/tabs/event'),
                  FABBottomItem(text: 'タイムライン', imgUrl: "assets/svg/tabs/time"),
                  FABBottomItem(
                      text: 'マイページ',
                      imgUrl: "assets/svg/tabs/user",
                      notice: badgeInfo.myPageTab),
                ],
              );
            },
          ),
          floatingActionButtonLocation:
              FixedCenterDockedFabLocation.centerDocked,
          floatingActionButton: (!_isLiver || _hideBroadcastButton)
              ? null
              : Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                      color: ColorLive.BORDER2, shape: BoxShape.circle),
                  padding: EdgeInsets.all(1),
                  child: FloatingActionButton(
                    backgroundColor: ColorLive.BLUE,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.asset("assets/svg/camera.svg"),
                          SizedBox(height: 4),
                          Text(
                            "配 信",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    onPressed: _startBroadcast,
                  ),
                ),
        ),
        !_isLoading ? null : SpinningIndicator(invisible: _invisibleBlocker),
      ].where((w) => w != null).toList(),
    );
  }

  void _onTabSelected(int index) {
    if (index == _currentTab) return;

    setState(() {
      _tabController.animateTo(index);
      _currentTab = index;
    });

    switch (index) {
      case _TAB_HOME:
        if (_reloadHome != null) _reloadHome();
        _setHideBroadcastButton(false);
        break;
      case _TAB_LIVE_EVENT:
        _setHideBroadcastButton(false);
        break;
      case _TAB_TIMELINE:
        if (_reloadTimeline != null) _reloadTimeline();
        break;
      case _TAB_MY_PAGE:
        if (_reloadMyPage != null) _reloadMyPage();
        _setHideBroadcastButton(false);
        break;
      default:
        break;
    }
  }

  void _setHideBroadcastButton(bool hide) {
    if (hide != _hideBroadcastButton)
      setState(() => _hideBroadcastButton = hide);
  }

  Future<void> _requestMyInfoBadge() async {
    final badgeInfo = Provider.of<BadgeInfo>(context, listen: false);
    await Future.wait([
      badgeInfo.requestMyInfoBadge(context, force: true),
      badgeInfo.requestNoticeInfo(context, NoticePage.SIZE),
    ]);
  }

  // 配信開始
  void _startBroadcast() {
    Navigator.push(context, FadeRoute(builder: (context) => LivePage()));
  }

  void _moveToHome() {
    // 一番上にBottomNavigationがいる、という前提
    Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
  }

  // お知らせページに遷移
  Future<void> _requestInfo(String infoId) async {
    // TODO: ローディング中のスピナーを表示させたいが、ホーム画面とは限らない
    final infos = await NoticePage.requestInfoList(
      context, /*infoId: infoId*/
    );
    if (infos != null) {
      final index = infos.indexWhere((info) => info.id == infoId);
      if (index != -1) {
        // 見つかったら指定のお知らせ詳細を表示
        final notification = infos[index];
        if (!notification.read) {
          // 既読にする
          notification.read = true;
          Injector.getInjector()
              .get<PersistentRepository>()
              .setNoticeRead(notification.id, true);
        }

        await Navigator.push(
            context,
            FadeRoute(
                builder: (context) => NoticeDetailsPage(
                      model: notification,
                    )));
        return;
      }
    }

    // 一覧ページに遷移
    await Navigator.push(
        context, FadeRoute(builder: (context) => NoticePage(startInfo: true)));
  }

  // ライバーが商品販売を開始した場合
  Future<void> _requestSalesProduct(String salesUserId, String itemId) async {
    // TODO: ローディング中のスピナーを表示させたいが、ホーム画面とは限らない
    final service = BackendService(context);
    final response = await service.getEcItem(salesUserId);
    if (response?.result != true) {
      // TODO: エラーメッセージ？
      return;
    }

    final data = response.getData();
    Product product;
    for (int i = 0; i < data.length; ++i) {
      final p = Product.fromJson(data[i]);
      if (p.itemId == itemId) {
        product = p;
        break;
      }
    }
    if (product != null) {
      await Navigator.push(
        context,
        FadeRoute(
            builder: (context) => ProductDetailPage(
                  product: product,
                  provideUserId: salesUserId,
                  canPurchase: true,
                )),
      );
    } else {
      // 売り切れ？
      // TODO: エラーメッセージ？
      return;
    }
  }

  // 視聴者が商品を購入した場合
  Future<void> _requestPurchaseProduct(
      String salesUserId, String purchaseUserId, String itemId) async {
    // 購入IDから購入情報を取得
    final service = BackendService(context);
    final response = await service.getEcItemPurchased(salesUserId);
    final data = response.getData();
    if (data?.isNotEmpty != true) return null;

    Purchase purchase;
    for (int i = 0; i < data.length; ++i) {
      final p = Purchase.fromJson(data[i]);
      if (p.itemId == itemId) {
        purchase = p;
        break;
      }
    }
    if (purchase != null) {
      await Navigator.push(context,
          FadeRoute(builder: (context) => LiverPurchaseDetailsPage(purchase)));
    } else {
      // 売り切れ？
      // TODO: エラーメッセージ？
      return;
    }
  }

  // ライバーが配信を始めた場合
  Future<void> _requestBroadcast(String liverId, String liveId) async {
    final response =
        await BackendService(context).getStreamingLiveRoom(liveId: liveId);
    if (response?.result != true) {
      await showNetworkErrorDialog(context, msg: response?.getByKey('msg'));
      return;
    }

    final list = List<RoomInfoModel>();
    for (final json in response.getData())
      list.add(RoomInfoModel.fromJson(json));
    if (list.isEmpty) {
      await showInformationDialog(
        context,
        title: '配信終了',
        msg: '配信終了しました',
      );
      return;
    }
    // リレー配信の場合.
    final roomInfo = list[0];
    if (roomInfo.eventType == LiveEventType.relay) {
      if (!roomInfo.isOnAir()) {
        await showInformationDialog(
          context,
          title: 'リレー配信',
          msg: '開始予定時刻 : ${dateFormatTime(roomInfo.liveStartDate)}',
        );
        return;
      }
    }
    // 視聴画面へ.
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LiveViewPage(list, 0)));
  }

  /// チャットにメッセージが来た場合.
  Future _moveToChat(String orderId) async {
    await Future.delayed(Duration(seconds: 1));
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PurchaseChatPage(orderId: orderId)));
  }

  /// イベントが開始された場合.
  Future _requestLiveEvent(String eventId) async {
    LiveEvent liveEvent;
    try {
      liveEvent =
          await LiveEventUseCase.requestLiveEventOverView(context, eventId);
    } catch (e) {
      // エラーの場合は何もしない.
      return;
    }
    // エラーの場合は何もしない.
    if (liveEvent == null) {
      return;
    }
    // イベント詳細へ遷移.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LiveEventDetailPage(
          liveEvent: liveEvent,
        ),
      ),
    );
  }
}
