import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:live812/domain/model/live/live_category.dart';
import 'package:live812/domain/model/live/room_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/domain/usecase/news_event_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/item/LiveItemForRecommend.dart';
import 'package:live812/ui/item/LiveItem.dart';
import 'package:live812/ui/scenes/live/live_view_page.dart';
import 'package:live812/ui/scenes/search/search_live.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/focus_util.dart';
import 'package:live812/utils/gift_downloader.dart';
import 'package:live812/utils/on_memory_cache.dart';
import 'package:live812/utils/result.dart';
import 'package:live812/utils/widget/notice_banner.dart';
import 'package:provider/provider.dart';
import 'package:adjust_sdk/adjust.dart';
import 'package:live812/ui/scenes/maintenance/maintenance_page.dart';
import 'package:live812/ui/scenes/register/missing_symbol_page.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/debug_util.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

const String _CUSTOM_CATEGORY_RECOMMENDATION = 'recommend';
const String _CUSTOM_CATEGORY_FOLLOW = 'follow';

const int _ANIMATION_DURATION = 300;
const int _ANIMATION_SKIP_DURATION = 30;

class Home extends StatefulWidget {
  final void Function(Function) onSetUp;
  final void Function(bool, {bool invisible}) setLoading;

  Home({this.onSetUp, this.setLoading});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with AutomaticKeepAliveClientMixin<Home>, WidgetsBindingObserver, TickerProviderStateMixin {
  TabController _tabController;
  PageController _pageController;
  TextEditingController _textEditingController = TextEditingController();
  List<LiveCategoryModel> _categories;
  Map<String, Result<List<RoomInfoModel>, String>> _categoryRoomInfos = {};
  int _currentPage = 0;
  int _targetPage;
  bool _isButtonEnable = true;// 強制的にボタンタップ不可フラグ

  Map<String,int> _roomLiveCounts = {};
  bool _isSkipTab = false;
  int _skipTargetPage;

  @override
  void dispose() {
    if (mounted) {
      FocusUtil.unFocus(context);
    }
    _tabController.dispose();
    _pageController.dispose();
    _textEditingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    WidgetsBinding.instance.addObserver(this);

    _createTabController(1);

    _requestLiverCategory();

    widget.onSetUp(() {
      _refreshPageInfo(_currentPage);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        final isMaintenance = await MaintenancePage.checkMaintenanceMode(context);
        Adjust.onResume();
        checkMissingSymbol();
        if (!isMaintenance && !GiftDownloader.isExecute) {
          await NewsEventUseCase.checkNewsEvent(context);
        }
        break;
      case AppLifecycleState.paused:
        Adjust.onPause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  void checkMissingSymbol() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    userModel.loadFromStorage();
    if (userModel.symbol == null || userModel.symbol == '') {
      Navigator.of(context).pushReplacement(
          FadeRoute(builder: (context) => MissingSymbolPage()));
    }
  }

  void stopBroadcasting() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    if(userModel.isLiver && userModel.isBroadcasting){
      userModel.setIsBroadcasting(false);
      userModel.saveToStorage();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      onTap: () => FocusUtil.unFocus(context),
      child: Container(
        color: ColorLive.BLUE,
        child: Column(
          children: <Widget>[
            NoticeBanner(),
            Expanded(
              child: _categories == null ? Container() : _buildTabController(_categories),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabController(List<LiveCategoryModel> categories) {
    Color _selectedTabColor = ColorLive.TAB_SELECT_BG;

    return Column(
      children: <Widget>[
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _textEditingController,
                  textInputAction: TextInputAction.search,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  prefix: const Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: const Icon(
                      Icons.search,
                      color: CupertinoColors.placeholderText,
                    ),
                  ),
                  prefixMode: OverlayVisibilityMode.notEditing,
                  placeholder: Lang.SEARCH_HINT,
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) async {
                    FocusUtil.unFocus(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SearchLive(word: value);
                        },
                      ),
                    );
                  },
                ),
              ),
              if (_textEditingController.text.isNotEmpty)
                const SizedBox(width: 10),
              if (_textEditingController.text.isNotEmpty)
                TextButton(
                  onPressed: () {
                    FocusUtil.unFocus(context);
                  },
                  child: const Text(
                    'キャンセル',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 1),
          child: TabBar(
            controller: _tabController,
            tabs: categories.map((category) => Tab(
              text: category.name,
            )).toList(),
            onTap: (index) {
              if (_currentPage != index) {
                _targetPage = index;
                _pageController.animateToPage(index, duration: Duration(milliseconds: _ANIMATION_DURATION), curve: Curves.easeInOut);
                _onPageChangedTo(index);
              }
            },
            isScrollable: true,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            labelColor: Colors.white,
            unselectedLabelStyle: TextStyle(fontSize: 14),
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.blue,
            indicator: BoxDecoration(
              border: Border.all(color: ColorLive.TAB_SELECT_BG),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)),
              color: ColorLive.TAB_SELECT_BG,
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 2,
          color: _selectedTabColor,
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            children: _createTabContent(categories),
            onPageChanged: (index) {
              if (_targetPage == null) {
                _requestLiveRoomCounts(index);
              } else {
                // タブ選択によるページ遷移
                if (_targetPage == index) {
                  _targetPage = null;
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onPageChangedTo(int page) async {
    _skipTargetPage = page;
    _currentPage = page;
    _isSkipTab = false;
    if (_categories != null && page < _categories.length) {
      // カテゴリのルーム情報更新
      await _requestLiveRooms(_categories[page].id);
    }
  }

  Future<void> _onPageAnimateChangedTo(int page) async {
    // アニメーション中なら処理を弾く
    if (_isSkipTab) {
      if (page == _skipTargetPage) {
        _isSkipTab = false;
      }
      return;
    }
    _isSkipTab = true;

    // page が存在するか確認
    if (page != 0 && _categories != null) {
      int add;
      if (_currentPage < page) {
        add = 1;
      } else {
        add = -1;
      }
      while (_checkLiveCount(page) <= 0) {
        page += add;
        if (page >= _categories.length || page < 0) {
          page = 0;
          break;
        }
        setState(() {
          _categoryRoomInfos[_categories[page].id] = Ok([]);
        });
      }
    }

    // 隣あうページならスキップじゃない
    if (_currentPage == (page + 1) || _currentPage == (page - 1) ){
      _isSkipTab = false;
    }

    // page スキップする間、_onPageAnimateChangedTo が何度も呼ばれるので対処
    _skipTargetPage = page;
    _currentPage = page;

    // タブとPage のアニメーション
    _tabController.animateTo(page,
        duration: Duration(milliseconds: _ANIMATION_SKIP_DURATION),
        curve: Curves.easeInOut);
    _pageController.animateToPage(page,
        duration: Duration(milliseconds: _ANIMATION_SKIP_DURATION),
        curve: Curves.easeInOut);

    if (_categories != null && page < _categories.length) {
      // カテゴリのルーム情報更新
      await _requestLiveRooms(_categories[page].id);
    }
  }

  // そのタブにライブは存在するのか？
  int _checkLiveCount(int page) {
    if (_categories == null) {
      DebugUtil.log("_categories is null");
      return 1; // 強制表示
    }
    if (page >= _categories.length || page < 0) {
      // 判定が存在しない
      DebugUtil.log("判定が存在しない");
      return 0;
    }
    if (_categories[page].id == "recommend" || _categories[page].id == "follow") {
      return 1; // 強制表示
    }
    return _roomLiveCounts[_categories[page].id] ?? 0;
  }

  List<Widget> _createTabContent(List<LiveCategoryModel> categories) {
    return categories.map((category) {
      final roomInfos = _categoryRoomInfos[category.id];
      return Container(
        color: ColorLive.MAIN_BG,
        child: RefreshIndicator(
          child: Container(
            margin: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
            child: categories[_currentPage].id == "recommend" ? _buildTabContentRecommend(roomInfos) : _buildTabContent(roomInfos),
          ),
          onRefresh: _onRefresh,
        ),
      );
    }).toList();
  }

  Widget _buildTabContent(Result<List<RoomInfoModel>, String> result) {
    if (result == null) {
      // まだ読み込まれてない
      return Container();
    }

    return result.match(
      ok: (roomInfos) {
        final rooms = roomInfos.where((element) => element.isOnAir()).toList();
        if (rooms.isEmpty) {
          //プルダウン有効にするためListView使用
          return ListView(
            children: <Widget>[
              Container(
                child: Column(children: <Widget>[
                  SizedBox(height: 50),
                  Text('現在、配信はありません',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ]),
              ),
            ],
          );
        }

        final mq = MediaQuery.of(context);
        return Consumer<UserModel>(
          builder: (context, userModel, _) {
            return GridView.count(
              padding: EdgeInsets.only(top: 0, bottom: mq.padding.bottom + (userModel.isLiver ? 40 : 0)),
              crossAxisCount: 2,
              children: List.generate(rooms.length, (i) {
                final roomInfo = rooms[i];
                return LiveItem(
                  roomInfo,
                  onTap: (){
                    FocusUtil.unFocus(context);
                    if(this._isButtonEnable)
                      _startWatching(roomInfo);
                  },
                );
              }).toList(),
            );
          },
        );
      },
      err: (msg) {
        return Container(
          child: Column(children: <Widget>[
            SizedBox(height: 50),
            Text(
              '取得できませんでした',
              style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 30),
            MaterialButton(
              onPressed: _onRefresh,
              padding: EdgeInsets.symmetric(horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: ColorLive.BLUE,
              child: Text(
                'リトライ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _buildTabContentRecommend(Result<List<RoomInfoModel>, String> result) {
    if (result == null) {
      // まだ読み込まれてない
      return Container();
    }

    return result.match(
      ok: (roomInfos) {
        final rooms = roomInfos.where((element) => element.isOnAir()).toList();
        if (rooms.isEmpty) {
          //プルダウン有効にするためListView使用
          return ListView(
            children: <Widget>[
              Container(
                child: Column(children: <Widget>[
                  SizedBox(height: 50),
                  Text('現在、配信はありません',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ]),
              ),
            ],
          );
        }
        List<RoomInfoModel> listLive = [];
        List<RoomInfoModel> listInfo = [];
        rooms.forEach((element) {
          if(element.broadcasting) {
            listLive.add(element);
          } else {
            listInfo.add(element);
          }
        });
        final mq = MediaQuery.of(context);
        return Consumer<UserModel>(
          builder: (context, userModel, _) {
            return Container(
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                    Center(
                      child: listLive.length > 0
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              SvgPicture.asset('assets/svg/electric.svg'),
                              SizedBox(width: 5),
                              Text(
                                '只今配信中',
                                style: TextStyle(color: Colors.white),
                              )
                            ])
                          : SizedBox(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Wrap(
                      spacing: 13.9,
                      children: List.generate(listLive.length, (i) {
                        return listLive[i].broadcasting
                            ? LiveItemForRecommend(
                                listLive[i],
                                onTap: () {
                                  if (rooms[i].broadcasting) {
                                    FocusUtil.unFocus(context);
                                    if (this._isButtonEnable)
                                      _startWatching(listLive[i]);
                                  } else {
                                    Navigator.push(
                                        context,
                                        FadeRoute(
                                            builder: (context) =>
                                                ProfileViewPage(
                                                    userId:
                                                        listLive[i].liverId)));
                                  }
                                },
                              )
                            : Visibility(
                                child: SizedBox(),
                                visible: false,
                              );
                      }).toList(),
                    ),
                    listLive.length > 0
                        ? Divider(color: Color(0xff868a95))
                        : SizedBox(),
                    Wrap(
                      spacing: 13.9,
                      children: List.generate(listInfo.length, (i) {
                        return !listInfo[i].broadcasting
                            ? LiveItemForRecommend(
                                listInfo[i],
                                onTap: () {
                                  if (listInfo[i].broadcasting) {
                                    FocusUtil.unFocus(context);
                                    if (this._isButtonEnable)
                                      _startWatching(listInfo[i]);
                                  } else {
                                    Navigator.push(
                                        context,
                                        FadeRoute(
                                            builder: (context) =>
                                                ProfileViewPage(
                                                    userId:
                                                        listInfo[i].liverId)));
                                  }
                                },
                              )
                            : Visibility(
                                child: SizedBox(),
                                visible: false,
                              );
                      }).toList(),
                    ),
                    SizedBox(
                      height: 90,
                    )
                  ])),
              margin: EdgeInsets.only(bottom: 50),
            );
          },
        );
      },
      err: (msg) {
        return Container(
          child: Column(children: <Widget>[
            SizedBox(height: 50),
            Text(
                '取得できませんでした',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 30),
            MaterialButton(
              onPressed: _onRefresh,
              padding: EdgeInsets.symmetric(horizontal: 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: ColorLive.BLUE,
              child: Text(
                'リトライ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ]),
        );
      },
    );
  }

  void _createTabController(int length) {
    int index = _tabController?.index ?? 0;
    _tabController?.dispose();
    _pageController?.dispose();
    _tabController = TabController(initialIndex: index, vsync: this, length: length);
    _pageController = PageController(initialPage: index, keepPage: true);
  }

  Future<void> _onRefresh() async {
    await _refreshPageInfo(_currentPage, force: true);
  }

  Future<void> _refreshPageInfo(int page, {bool force = false}) async {
    await NewsEventUseCase.showNewsEvent(context);
    if (_categories != null && page < _categories.length && _categories[page] != null)
      await _requestLiveRooms(_categories[page].id, force: force);
  }

  Future<void> _requestLiverCategory() async {
    final response = await OnMemoryCache.fetch(ApiPath.liverCategory, Duration(hours: 1), () async {
      final service = BackendService(context);
      final response = await service.getLiverCategory();
      return response?.result == true ? response : null;
    });
    if (response?.result == true) {
      setState(() {
        _categories = _createCategoryList(response.getData());

        _createTabController(_categories.length);
      });
      await _refreshPageInfo(_currentPage);
    }
  }

  static List<LiveCategoryModel> _createCategoryList(List<dynamic> categories) {
    final list = List<LiveCategoryModel>();
    // APIで取得したカテゴリに加えて、「おすすめ」「フォロー」を追加
    list.add(LiveCategoryModel(
      id: _CUSTOM_CATEGORY_RECOMMENDATION,
      name: 'おすすめ',
      isCustomType: true,
    ));
    list.add(LiveCategoryModel(
      id: _CUSTOM_CATEGORY_FOLLOW,
      name: 'フォロー',
      isCustomType: true,
    ));
    for (final category in categories) {
      list.add(LiveCategoryModel.fromJson(category));
    }
    return list;
  }

  Future<bool> _requestLiveRooms(String categoryId, {bool force = false}) async {
    final key = '${ApiPath.streamingLiveRoom}/$categoryId';
    final response = await OnMemoryCache.fetch(key, Duration(minutes: 1), () async {
      final service = BackendService(context);
      final response = await service.getStreamingLiveRoom(categoryId: categoryId);
      return response?.result == true ? response : null;
    }, force: force);
    if (response?.result != true) {
      setState(() {
        _categoryRoomInfos[categoryId] = Err(response?.getByKey('msg'));
      });
      return false;
    }

    final data = response.getData();
    List<RoomInfoModel> list = [];
    data.forEach((j) => list.add(RoomInfoModel.fromJson(j)));
    setState(() {
      _categoryRoomInfos[categoryId] = Ok(list);
    });
    return true;
  }

  Future<bool> _requestLiveRoomCounts(int page, {bool force = false}) async {
    final key = '${ApiPath.streamingLiveRoom}/counts';
    final response =
        await OnMemoryCache.fetch(key, Duration(minutes: 1), () async {
      final service = BackendService(context);
      final response = await service.getStreamingLiveRoomCounts();
      return response?.result == true ? response : null;
    }, force: force);
    if (response?.result != true) {
      DebugUtil.log(response?.getByKey('msg'));
      // 受信失敗時は旧式で対応
      _onPageChangedTo(page);
      return false;
    }

    _roomLiveCounts = {}; // リセット
    final data = response.getData();
    data.forEach((j) => _roomLiveCounts[j["category"]] = j["count"]);
    _onPageAnimateChangedTo(page);
    return true;
  }

  // 視聴開始
  Future<void> _startWatching(RoomInfoModel roomInfo) async {
    // 強制的にボタンをタップ不可にする
    this._isButtonEnable = false;

    var broadcasting = false;
    if (roomInfo.liveId != null) {
      // 現在配信中かどうか再度確認
      final service = BackendService(context);
      widget.setLoading(true);
      final response = await service.getStreamingLiveRoomBroadcasting(roomInfo.id);
      widget.setLoading(true, invisible: true);  // スピナーは解除し、タッチ防止は継続
      if (response?.result == true)
        broadcasting = response.getByKey('broadcasting');
    }
    if (!broadcasting) {
      // リストから除外するため、更新する
      _requestLiveRooms(_categories[_currentPage].id, force: true);

      widget.setLoading(false);  // 入力ブロック解除
      this._isButtonEnable = true;// 強制的にボタンをタップ可能に戻す

      await showInformationDialog(
        context,
        title: '配信終了',
        msg: '配信終了しました',
      );
      return;
    }
    // 入力ブロックを継続したまま画面を遷移させる

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            //return LiveViewPage(roomInfos, i);
            // 他のライブルームにいいねやギフトが飛ぶ？という現象があるらしく
            // ライブIDが混じってないか？対策として複数のライブルーム情報を渡さないようにする。
            return LiveViewPage([roomInfo], 0);
          },
        ));
    this._isButtonEnable = true;// 強制的にボタンをタップ可能に戻す
    widget.setLoading(false);  // 入力ブロック解除
  }

  @override
  bool get wantKeepAlive => true;
}
