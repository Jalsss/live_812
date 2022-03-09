import 'package:darq/darq.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/ec/store_profile.dart';
import 'package:live812/domain/model/live/live_event.dart';
import 'package:live812/domain/model/live/room_info.dart';
import 'package:live812/domain/model/timeline/timeline_post_model.dart';
import 'package:live812/domain/model/user/following_notify.dart';
import 'package:live812/domain/model/user/other_user.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/timeline_usecase.dart';
import 'package:live812/ui/dialog/following_notify_dialog.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/item/ProductItem.dart';
import 'package:live812/ui/item/TimelineItem.dart';
import 'package:live812/ui/item/store_profile_item.dart';
import 'package:live812/ui/scenes/live/live_view_page.dart';
import 'package:live812/ui/scenes/shop/product_detail_page.dart';
import 'package:live812/ui/scenes/shop/store_profile_detail_page.dart';
import 'package:live812/ui/scenes/timeline/timeline_comment_manager.dart';
import 'package:live812/ui/scenes/user/widget/follower_ranking_fanrank.dart';
import 'package:live812/ui/scenes/user/widget/list_icon_badge_widget.dart';
import 'package:live812/ui/scenes/user/widget/profile_follow_button.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/super_text_util.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:provider/provider.dart';

import 'model/icon_badge_model.dart';

enum TabType {
  TIMELINE,
  PRODUCT,
}

class ProfileViewPage extends StatefulWidget {
  final String userId;

  ProfileViewPage({Key key, @required this.userId}) : super(key: key);

  @override
  _ProfileViewPageState createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {

  bool _isShowLongProfile = false;
  TabType _currentTab = TabType.TIMELINE;
  List<Product> _products;
  List<StoreProfile> _storeProfiles;
  List<TimelinePostModel> _timelinePosts;
  final _commentManager = TimelineCommentManager();
  OtherUserModel _targetUser;
  var _isInitializing = true;
  bool _followed = true;
  bool _notificationEnabled;
  var _isLoading = false;

  /// タイムラインが読込中かどうか.
  var _isTimelineLoading = false;

  /// タイムラインの終端に到達したかどうか.
  var _isTimelineEnd = false;
  var _isSelf = false; // 対象が自分か？
  var _isLiverSelf = false; // 自分がライバーか？
  var _blocked = false;

  bool showAllBadge = false;

  List<IconBadge> listIcon = [];

  @override
  void initState() {
    super.initState();

    final userModel = Provider.of<UserModel>(context, listen: false);
    _isSelf = widget.userId == userModel.id;
    _isLiverSelf = userModel.isLiver;

    _requestUser().then((_) => setState(() => _isInitializing = false));
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return SpinningIndicator();
    }
    if (_targetUser == null) {
      return Container();
    }

    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: ColorLive.BLUE_BG,
          body: SafeArea(
            child: _buildUserData(_targetUser),
          ),
          bottomNavigationBar: _isSelf
              ? null
              : SafeArea(
                  child: ProfileFollowButton(
                    userId: widget.userId,
                    followed: _followed,
                    onChangeFollowed: (newFollowed) {
                      setState(() {
                        _followed = newFollowed;
                        if (_followed)
                          _notificationEnabled = true; // 新規フォローのデフォルトは通知オンで
                      });
                    },
                  ),
                ),
        ),
        !_isLoading ? null : SpinningIndicator(),
      ].where((w) => w != null).toList(),
    );
  }

  Widget _buildUserData(OtherUserModel userData) {
    String _prevProfile;
    List<SuperText> _profileSuperText;
    if (_prevProfile != userData?.profile) {
      _prevProfile = userData?.profile;
      if (_prevProfile != null)
        _profileSuperText = SuperTextUtil.parse(userData?.profile);
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: ColorLive.BLUE_BG,
            title: Text(userData?.nickname ?? ''),
            centerTitle: true,
            elevation: 0,
            floating: true,
            leading: IconButton(
                icon: SvgPicture.asset("assets/svg/backButton.svg"),
                onPressed: () {
                  Navigator.pop(context, _targetUser);
                }),
            actions: <Widget>[
              !_isLiverSelf || _isSelf
                  ? Container()
                  : IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        _openBottomSheet(context);
                      },
                    ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      child: Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white),
                            image: userData?.imgThumbUrl == null
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(userData.imgThumbUrl),
                                    onError: (d, s) {},
                                    fit: BoxFit.cover,
                                  ),
                            color: userData?.imgThumbUrl != null
                                ? null
                                : Color(0xff404040),
                          ),
                        ),
                      ),
                    ),
                    _isSelf
                        ? Container()
                        : Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              Text(
                                _isNotificationEnabled()
                                    ? Lang.NOTIFICATION_ON
                                    : Lang.NOTIFICATION_OFF,
                                style: TextStyle(
                                  color: _isNotificationEnabled()
                                      ? Colors.white
                                      : Color(0xff808080),
                                  fontSize: 10,
                                ),
                              ),
                              IconButton(
                                icon: SvgPicture.asset(
                                  _isNotificationEnabled()
                                      ? 'assets/svg/bell_on.svg'
                                      : 'assets/svg/bell_off.svg',
                                  color: _isNotificationEnabled()
                                      ? null
                                      : Color(0xff808080),
                                ),
                                onPressed: !_followed
                                    ? null
                                    : () async {
                                        await _toggleNotification(context);
                                      },
                              ),
                            ],
                          ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  userData?.nickname ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userData?.symbol ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      color: Colors.white,
                      onPressed: () async {
                        final data =
                            ClipboardData(text: userData?.symbol ?? '');
                        await Clipboard.setData(data);
                        Flushbar(
                          icon: Icon(
                            Icons.info_outline,
                            size: 28.0,
                            color: Colors.blue[300],
                          ),
                          message: Lang.COPIED,
                          duration: const Duration(milliseconds: 2000),
                          margin: const EdgeInsets.all(8),
                          borderRadius: 8,
                        )..show(context);
                      },
                    ),
                  ],
                ),
                Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: _divider(),
              ),
                listIcon.length > 0 ? ListIconBadge(listIconBadge: listIcon,
                  showAllBadge : showAllBadge, showAll: () {
                    setState(() {
                      showAllBadge = !showAllBadge;
                    });
                  }) : SizedBox(),
                userData?.isBroadcasting != true
                    ? Container()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          MaterialButton(
                            minWidth: 20,
                            onPressed: () {
                              _gotoLiveViewPage(userData.liveId);
                            },
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.0),
                            ),
                            color: Colors.yellow,
                            child: Row(
                              children: <Widget>[
                                SvgPicture.asset("assets/svg/rec_icon.svg"),
                                SizedBox(width: 14),
                                Text(
                                  "ライブ配信中",
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 20),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: FollowerRankingFanrankView(
                    followerCount: userData?.followerCount ?? 0,
                    monthlyRanking: userData?.rank ?? '-',
                    userId: userData?.id,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: _divider(),
                ),
                userData?.profile == null
                    ? Container()
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: SuperTextWidget(
                          _profileSuperText,
                          maxLines: _isShowLongProfile ? null : 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                LayoutBuilder(builder: (context, size) {
                  final textPainter = TextPainter(
                    text: TextSpan(
                      text: userData?.profile ?? "",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    maxLines: 2,
                    textDirection: TextDirection.ltr,
                  );
                  textPainter.layout(maxWidth: size.maxWidth);
                  if (textPainter.didExceedMaxLines) {
                    return userData?.profile == null
                        ? Container()
                        : MaterialButton(
                            onPressed: () {
                              setState(() {
                                _isShowLongProfile = !_isShowLongProfile;
                              });
                            },
                            padding: EdgeInsets.all(0),
                            child: Text(
                              _isShowLongProfile ? "戻る" : "…もっと見る",
                              style: TextStyle(
                                  color: ColorLive.BLUE, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          );
                  } else {
                    return Container();
                  }
                }),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: _divider(),
                ),
                Container(
                  child: DefaultTabController(
                    initialIndex: _currentTab.index,
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
                              _setCurrentTab(TabType.values[i]);
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
                              Tab(text: "タイムライン"),
                              Tab(text: "ストア"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_currentTab) {
      case TabType.TIMELINE:
        return _buildTimeline();
      case TabType.PRODUCT:
        return _buildProductList();
    }
    return null;
  }

  Widget _buildTimeline() {
    var length = _timelinePosts?.length ?? 0;
    if(_isTimelineEnd && length == 0) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'タイムラインへの投稿はありません。',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },childCount: 1));
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == length) {
            _requestTimeline(false, offset: length);

            return Container(
              height: 100,
              child: SpinningIndicator(),
            );
          } else if (index > length) {
            return null;
          }

          final post = _timelinePosts[index];
          return GestureDetector(
            onTap: () {
              if (_commentManager.closeAllComments()) {
                setState(() {});
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TimelineItem(
                post: post,
                comments: !_commentManager.isOpen(post.id)
                    ? null
                    : _commentManager.getCommentsFor(post.id),
                onToggleComment: () async {
                  if (_commentManager.isOpen(post.id)) {
                    setState(() {
                      _commentManager.closeComment(post.id);
                    });
                  } else {
                    _commentManager.openComment(post.id);
                    _requestComment(post);
                  }
                },
                onPostComment: (_comment) {
                  _requestComment(post);
                },
                onChangeLike: (like) {
                  _changeLike(post, like);
                },
              ),
            ),
          );
        },
        childCount: _isTimelineEnd ? _timelinePosts?.length ?? 0 : null,
      ),
    );
  }

  Widget _buildProductList() {
    final storeProfileLength = _storeProfiles?.length ?? 0;
    int length = (_products?.length ?? 1) + storeProfileLength;

    int soldOutLength =
        _products != null ? _products.where((x) => !x.isPublished).length : 0;
    if(soldOutLength == 0 && length == 0) {
      return SliverList(
          delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      '出品中の商品はありません。',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },childCount: 1));
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (_products == null) {
            return Container(
              height: 100,
              child: SpinningIndicator(),
            );
          }
          if (index >= length) return Container();

          if (index < storeProfileLength) {
            final storeProfile = _storeProfiles[index];
            return _ProfileViewStoreProfileItem(
              storeProfile: storeProfile,
              onTap: () async {
                await Navigator.push(
                  context,
                  FadeRoute(
                    builder: (context) => StoreProfileDetailPage(
                      isSelf: _isSelf,
                      storeProfile: storeProfile,
                      onUpdate: (storeProfiles) async {
                        setState(() {
                          _storeProfiles = storeProfiles;
                        });
                      },
                    ),
                  ),
                );
              },
            );
          }

          var product = _products[index - storeProfileLength];
          if (index == length - soldOutLength) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  color: ColorLive.C26,
                  child: Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ),
                _ProfileViewProductItem(
                  product: product,
                  onTap: () {
                    _gotoProductDetailPage(product);
                  },
                ),
              ],
            );
          } else {
            return _ProfileViewProductItem(
              product: product,
              onTap: () {
                _gotoProductDetailPage(product);
              },
            );
          }
        },
        childCount: length,
      ),
    );
  }

  Future<void> _setCurrentTab(TabType tab) async {
    if (_currentTab == tab) return;
    setState(() {
      _currentTab = tab;
    });
    switch (tab) {
      case TabType.TIMELINE:
        if (_timelinePosts == null) await _refreshTimeline();
        break;
      case TabType.PRODUCT:
        if (_products == null) await _refreshProducts();
        break;
    }
  }

  Future<void> _onRefresh() async {
    switch (_currentTab) {
      case TabType.TIMELINE:
        await _refreshTimeline();
        break;
      case TabType.PRODUCT:
        await _refreshProducts();
        break;
    }
  }

  Future<void> _refreshTimeline() async {
    if (await _requestTimeline(true)) {
      // コメント更新
      final futures = _commentManager.requestOpenedComments(context);
      if (futures != null) {
        final results = await Future.wait(futures.toList());
        bool updated = false;
        results.forEach((tuple) {
          final comments = tuple?.item2;
          if (comments != null) {
            final post =
                _timelinePosts.firstWhere((post) => post.id == tuple.item1);
            if (post != null && post.commentCount != comments.length) {
              post.setCommentCount(comments.length);
              updated = true;
            }
          }
        });
        if (updated && mounted) {
          setState(() {}); // なにかしら更新があったら画面に反映させる
        }
      }
    }
  }

  Future<void> _refreshProducts() async {
    await _requestProducts();
  }

  Widget _divider({color: ColorLive.DIVIDER, height: 22.0}) {
    return Divider(
      color: color,
      height: height,
      thickness: 0.2,
    );
  }

  Future<void> _requestUser() async {
    final response =
        await BackendService(context).getUser(widget.userId, isLiver: true);
    if (response?.result != true) {
      await showNetworkErrorDialog(context, msg: 'ユーザ情報の取得に失敗しました。');
      Navigator.pop(context);
      return;
    }
    final responseBadge = await BackendService(context).getIconBadge(widget.userId);

    setState(() {
      showAllBadge = listIcon.length > 8 ?  false : true;
      listIcon = responseBadge?.result == true ? getListIconBadge(responseBadge.data.getByKey('badge')) : [];
      _targetUser = OtherUserModel.fromJson(response.getData());
      _followed = _targetUser.followed;
      _notificationEnabled =
          _targetUser.notifyLive || _targetUser.notifyTimeline;
      _blocked = _targetUser.blocked;
      if (_targetUser.blocked == null) _targetUser.setBlocked(_blocked = false);
    });
  }

  Future<bool> _requestTimeline(bool refresh, {int offset = 0}) async {
    if (_isTimelineLoading) {
      // すでに通信中の場合は何もしない.
      return false;
    }
    _isTimelineLoading = true;
    final result = await TimelineUsecase.requestTimeline(context,
        userId: widget.userId, offset: offset);
    _isTimelineLoading = false;
    return result.match(
      ok: (list) {
        setState(() {
          if ((_timelinePosts == null) || refresh) {
            // 初期化.
            _timelinePosts = [];
            _isTimelineEnd = false;
          }
          if (list.length == 0) {
            // これ以上タイムラインが存在しない.
            _isTimelineEnd = true;
          }
          _timelinePosts.addAll(list);
        });
        return true;
      },
      err: (_msg) {
        return false;
      },
    );
  }

  Future<bool> _requestComment(TimelinePostModel post) async {
    final comments = await _commentManager.requestFor(context, post.id);
    if (comments == null) return false;

    setState(() {
      // ポストのコメント数を更新してやる
      post.setCommentCount(comments.length);
    });
    return true;
  }

  void _changeLike(TimelinePostModel post, bool like) {
    if (post.liked == like) return;
    post.setLike(like);
  }

  Future<void> _requestProducts() async {
    final service = BackendService(context);
    final response = await service.getEcItem(widget.userId);
    if (response?.result != true) return;

    final products = List<Product>();
    response.getData().forEach((v) => products.add(Product.fromJson(v)));
    setState(() {
      _products = products
          .orderByDescending((x) => x.isPublished ? 1 : 0)
          .thenByDescending((x) => x.createDate)
          .toList();

      _storeProfiles = [];
      if (response.containsKey("store_data")) {
        final storeData = response.getByKey("store_data") as List;
        if (storeData != null) {
          _storeProfiles =
              storeData.map((x) => StoreProfile.fromJson(x)).toList();
        }
      }
    });
  }

  Future<void> _gotoLiveViewPage(String liveId) async {
    List<RoomInfoModel> list;
    final service = BackendService(context);
    final response = await service.getStreamingLiveRoom(liveId: liveId);
    if (response?.result == true) {
      list = [];
      for (final json in response.getData())
        list.add(RoomInfoModel.fromJson(json));
    }

    if (list?.isNotEmpty != true) {
      setState(() => _targetUser.setIsBroadcasting(false));

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

  Future<void> _gotoProductDetailPage(Product product) async {
    final result = await Navigator.push(
      context,
      FadeRoute(
          builder: (context) => ProductDetailPage(
                product: product,
                provideUserId: widget.userId,
                canPurchase:
                    !_isSelf && product.isBuyable && product.isPublished,
                canEdit: _isSelf,
              )),
    );
    if (result == ProductDetailPageResult.PURCHASED || _isSelf) {
      await _requestProducts();
    }
  }

  bool _isNotificationEnabled() {
    return _followed && _notificationEnabled;
  }

  Future<void> _toggleNotification(BuildContext context) async {
    var notify = FollowingNotify(
        live: _targetUser.notifyLive,
        timeline: _targetUser.notifyTimeline,
        ec: _targetUser.notifyEC);
    // ダイアログの表示.
    await showDialog(
        context: context,
        builder: (context) {
          return FollowingNotifyDialog(notify);
        });
    // 通信処理.
    final response = await BackendService(context).postUserNotification(
        id: _targetUser.id,
        notifyTimeline: notify.timeline,
        notifyLive: notify.live,
        notifyEC: notify.ec);
    if (response?.result == true) {
      _targetUser.setNotify(notify.live, notify.timeline, notify.ec);
    }
    // UIへ反映.
    setState(() => _notificationEnabled = _targetUser.notify);
  }

  Future<void> _openBottomSheet(BuildContext context) async {
    const BLOCK = 1;
    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10 + MediaQuery.of(context).padding.bottom,
              left: 15,
              right: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(5),
                topRight: const Radius.circular(5),
              ),
            ),
            child: Column(
              children: <Widget>[
                _buildBlockButton(
                  _blocked ? Lang.RELEASE_BLOCK : Lang.BLOCK,
                  onTap: () {
                    Navigator.pop(context, BLOCK);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    switch (result) {
      case BLOCK:
        _requestBlock(context);
        break;
      default:
        break;
    }
  }

  Widget _buildBlockButton(String text, {@required void Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          color: Color(0xff404040),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<void> _requestBlock(BuildContext context) async {
    var newBlocked = !_blocked;
    final service = BackendService(context);
    final response = await service.postBlockListener(widget.userId, newBlocked);
    if (response?.result == true) {
      setState(() {
        _blocked = newBlocked;
        if (_blocked) {
          // ブロックしたので前画面に戻る
          Navigator.pop(context);
        }
      });
    }
  }
}

class _ProfileViewProductItem extends StatelessWidget {
  final Product product;
  final Function onTap;

  _ProfileViewProductItem({this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorLive.C26,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Material(
        color: ColorLive.C26,
        child: ProductItem(
          product: product,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _ProfileViewStoreProfileItem extends StatelessWidget {
  final StoreProfile storeProfile;
  final Function onTap;

  _ProfileViewStoreProfileItem({this.storeProfile, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorLive.C26,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Material(
        color: ColorLive.C26,
        child: StoreProfileItem(
          storeProfile: storeProfile,
          onTap: onTap,
        ),
      ),
    );
  }
}
