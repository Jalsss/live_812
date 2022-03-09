import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:live812/domain/model/ec/credit_payment_result.dart';
import 'package:live812/domain/model/ec/delivery_address.dart';
import 'package:live812/domain/model/ec/purchase_delivery.dart';
import 'package:live812/domain/model/json_data.dart';
import 'package:live812/domain/model/live/gift_info.dart';
import 'package:live812/domain/model/live/jasrac.dart';
import 'package:live812/domain/model/live/live.dart';
import 'package:live812/domain/model/user/coin_history.dart';
import 'package:live812/domain/model/user/inquiry.dart';
import 'package:live812/domain/model/user/signup.dart';
import 'package:live812/domain/model/user/user_info.dart';
import 'package:live812/domain/repository/network_repository.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/debug_util.dart';
import 'package:tuple/tuple.dart';

class BackendService {
  static String get socketUrl => Injector.getInjector().get<String>(key: Consts.KEY_SOCKET_URL);

  static String getUserThumbnailUrl(String userId, {bool small = false}) {
    if (userId == null)
      return null;
    return 'http://asset.live812.works/${small ? 'small' : 'thumb'}/user/$userId.jpg';
  }

  /// イベント用サムネイルURL.
  static String getEventThumbnailUrl(String eventId) {
    return 'http://asset.live812.works/event/$eventId.jpg';
  }

  // APIトークン
  static String _apiToken;

  static void setApiToken(String token) {
    _apiToken = token;
  }

  final BuildContext _context;

  BackendService(BuildContext context) : _context = context;

  // GETで送れるのはクエリパラメータのみ、bodyは使用できない。
  Future<http.Response> _sendGet(String api, {Map<String, String> headers, Map<String, dynamic> query, int timeOut = Consts.TIME_OUT}) {
    if (query == null)
      query = Map();
    if (!query.containsKey('token') && _apiToken != null)
      query['token'] = _apiToken;

    final network = Injector.getInjector().get<NetworkRepository>();
    return network.sendRequest(Method.GET, api, headers: headers, query: query, timeOut: timeOut);
  }

  // POSTはbodyをJSONで送る。クエリパラメータはなし。
  Future<http.Response> _sendPost(String api, {Map<String, String> headers, Map body, Encoding encoding, int timeOut = Consts.TIME_OUT}) {
    if (body == null)
      body = Map();
    if (!body.containsKey('token') && _apiToken != null)
      body['token'] = _apiToken;

    final network = Injector.getInjector().get<NetworkRepository>();
    return network.sendRequest(Method.POST, api, headers: headers, body: body, encoding: encoding, isJson: true, timeOut: timeOut);
  }

  // PUTはbodyをJSONで送る。クエリパラメータはなし。
  Future<http.Response> _sendPut(String api, {Map<String, String> headers, Map body, Encoding encoding, int timeOut = Consts.TIME_OUT}) {
    if (body == null)
      body = Map();
    if (!body.containsKey('token') && _apiToken != null)
      body['token'] = _apiToken;

    final network = Injector.getInjector().get<NetworkRepository>();
    return network.sendRequest(Method.PUT, api, headers: headers, body: body, encoding: encoding, isJson: true, timeOut: timeOut);
  }

  // DELETEで送れるのはクエリパラメータのみ、bodyは使用できない。
  Future<http.Response> _sendDelete(String api, {Map<String, String> headers, Map<String, dynamic> query, int timeOut = Consts.TIME_OUT}) {
    if (query == null)
      query = Map();
    if (!query.containsKey('token') && _apiToken != null)
      query['token'] = _apiToken;

    final network = Injector.getInjector().get<NetworkRepository>();
    return network.sendRequest(Method.DELETE, api, headers: headers, query: query, timeOut: timeOut);
  }

  JsonData _detect401(http.Response response) {
    if (response?.statusCode == 401) {
      DebugUtil.log(
          'detect 401: request=${response.request.url}, response-body=${utf8.decode(response.bodyBytes)}');
      DebugUtil.dumpStackTrace(5, startLevel: 2);

      final navigator = Navigator.of(_context);
      while (navigator.canPop()) {
        navigator.pop();
      }
      navigator.pushReplacementNamed('/login');
      return null;
    } else {
      try {
        return JsonData(utf8.decode(response?.bodyBytes));
      } on FormatException catch (e) {
        DebugUtil.log(e.toString());
        return null;
      } catch (e) {
        DebugUtil.log('catch exception: ${e.toString()}');
        return null;
      }
    }
  }

  Future<JsonData> postLogin(String mail, String pass) async {
    final response = await _sendPost(ApiPath.login, body: {'mail': mail, 'pass': pass});
    // ログイン画面のみ401エラーで画面遷移しない
    return Future.value(JsonData(utf8.decode(response.bodyBytes)));
  }

  Future<JsonData> postSignUp(String mail) async {
    var body = {
      'mail': mail,
    };
    final response = await _sendPost(ApiPath.signup, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postPasswordReset(String mail) async {
    var body = {
      'mail': mail,
    };
    final response = await _sendPost(ApiPath.passwordReset, body: body);
    return Future.value(_detect401(response));
  }

  // 個人情報ワンタイムトークン取得
  Future<Tuple2<JsonData, http.Response>> getMyRequest() async {
    final response = await _sendGet(ApiPath.myRequest);
    try {
      // 401判定なし
      return Future.value(Tuple2(JsonData(utf8.decode(response.bodyBytes)), response));
    } catch (e) {
      DebugUtil.log(e.toString());
      return Tuple2(null, null);
    }
  }

  // 自分の情報を取得
  Future<JsonData> getMy(String onetimeToken) async {
    final query = {
      'onetime_token': onetimeToken,
    };

    final response = await _sendGet(ApiPath.my, query: query);
    return Future.value(_detect401(response));
  }

  // マイページ情報を取得
  Future<JsonData> getMypage() async {
    final response = await _sendGet(ApiPath.mypage);
    return Future.value(_detect401(response));
  }

  // マイページ情報を取得
  Future<JsonData> getIconBadge(String idUser) async {
    final Map<String, dynamic> query = {
      'id': idUser,
    };
    final response = await _sendGet(ApiPath.iconBadge,query: query);
    return Future.value(_detect401(response));
  }

  // 対象ユーザの情報を取得
  Future<JsonData> getUser(String targetUserId, {bool isLiver}) async {
    final Map<String, dynamic> query = {
      'id': targetUserId,
    };
    if (isLiver != null) {
      query['is_liver'] = isLiver;
    }

    final response = await _sendGet(ApiPath.user, query: query);
    return Future.value(_detect401(response));
  }

  // ライバーカテゴリ取得
  Future<JsonData> getLiverCategory() async {
    final response = await _sendGet(ApiPath.liverCategory);
    return Future.value(_detect401(response));
  }

  // 配信ルーム取得
  Future<JsonData> getStreamingLiveRoom({String categoryId, String liveId}) async {
    final Map<String, String> query = {
      'category_id': categoryId,
      'live_id': liveId,
    };

    final response =
        await _sendGet(ApiPath.streamingLiveRoom, query: query);
    return Future.value(_detect401(response));
  }

  // 配信ルーム数一覧取得
  Future<JsonData> getStreamingLiveRoomCounts() async {
    final response = await _sendGet(ApiPath.streamingLiveRoomCounts);
    return Future.value(_detect401(response));
  }

  // 配信中チェック
  Future<JsonData> getStreamingLiveRoomBroadcasting(String roomId) async {
    final Map<String, String> query = {
      'id': roomId,
    };

    final response = await _sendGet(ApiPath.streamingLiveRoomBroadcasting, query: query);
    return Future.value(_detect401(response));
  }

  // ブロードキャスト開始
  Future<JsonData> postStreamingLiveBroadcast(String liveId) async {
    final Map<String, dynamic> body = {
      'live_id': liveId,
    };

    final response = await _sendPost( ApiPath.streamingLiveBroadcast, body: body);
    return Future.value(_detect401(response));
  }

  // ユーザ情報更新
  Future<JsonData> putUser(UserInfoModel userInfo, {bool ignoreServerError = false}) async {
    final body = userInfo.getMap();

    final response = await _sendPut(ApiPath.user, body: body);
    if (!ignoreServerError) {
      return Future.value(_detect401(response));
    } else {
      return Future.value(JsonData(utf8.decode(response.bodyBytes)));
    }
  }

  Future<JsonData> putUserThumb(String base64) async {
    final body = {
      'thumb': base64,
    };

    final response = await _sendPut(ApiPath.user, body: body);

    return Future.value(_detect401(response));
  }

  Future<JsonData> getRecommendation(String userId) async {
    final Map<String, String> query = {
      'recommend_liver': 'true',
      'user_id': userId,
    };

    final response = await _sendGet(ApiPath.user, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getFollowers() async {
    final response = await _sendGet(ApiPath.user);
    return Future.value(_detect401(response));
  }

  Future<JsonData> searchLiver(String keyword,
      {int size, int offset, bool isLiver = true}) async {
    final query = {
      'kwd': keyword,
      'is_liver': isLiver,
      'size': size,
      'offset': offset,
    };

    final response = await _sendGet(ApiPath.user, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postLiveRoom(LiveModel model) async {
    final body = model.toMap();
    final response = await _sendPost(ApiPath.streamingLiveRoom, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postLiveStart({
    @required String liveId,
    @required String userId,
    @required bool isLandscape,
    @required bool cameraOff,
  }) async {
    final body = {
      'live_id': liveId,
      'user_id': userId,
      'is_landscape': isLandscape,
      'camera_off': cameraOff,
    };
    final response = await _sendPost(ApiPath.streamingLiveStart, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postLiveStop(String liveId, String userId) async {
    final Map<String, String> body = {
      'live_id': liveId,
      'user_id': userId
    };
    final response = await _sendPost(ApiPath.streamingLiveStop, body: body);
    return Future.value(_detect401(response));
  }

  Future<List<GiftInfoModel>> getRoomGift() async {
    final response = await _sendGet(ApiPath.roomGift);
    final json = _detect401(response);
    List<GiftInfoModel> list;
    if (json != null && json.result) {
      final data = json?.getData();
      if (data != null) {
        list = [];
        data.forEach((j) => list.add(GiftInfoModel.fromJson(j)));
      }
    }
    return list;
  }

  // 商品取得
  Future<JsonData> getEcItem(String provideUserId) async {
    final query = {
      'provide_user_id': provideUserId,
    };

    final response = await _sendGet(ApiPath.ecItem, query: query);
    return Future.value(_detect401(response));
  }

  // 商品取得（ライバー取引中）
  Future<JsonData> getEcItemPurchased(String provideUserId) async {
    final query = {
      'provide_user_id': provideUserId,
    };

    final response = await _sendGet(ApiPath.ecItemPurchased, query: query);
    return Future.value(_detect401(response));
  }

  // 販売中商品取得
  Future<JsonData> getEcItemSales(String provideUserId) async {
    final query = {
      'provide_user_id': provideUserId,
    };

    final response = await _sendGet(ApiPath.ecItemSales, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getEcItemCompleted({String userId}) async {
    final query = {
      'auth_id': userId,
      'provide_user_id': userId,
    };

    final response = await _sendGet(ApiPath.ecItemCompleted, query: query);
    return Future.value(_detect401(response));
  }

  // 商品削除
  Future<JsonData> deleteEcItem(String provideUserId, String itemId) async {
    final query = {
      'provide_user_id': provideUserId,
      'item_id': itemId,
    };

    final response = await _sendDelete(ApiPath.ecItem, query: query);
    return Future.value(_detect401(response));
  }

  // 商品登録
  Future<JsonData> postEcItem(String userId,
      {@required String name, // 商品名
      @required String memo, // 商品説明
      @required int price, // 価格
      @required int shipping, // 発送予定日.
      @required bool enabledFlag, // 提供状態
      Map<int, String> base64Images, // 画像（base64エンコード済み）
      List<int> deleteImageIndices, // 削除する画像
      bool isRelease = true, // 公開フラグ.
      String itemId,
      String customerUserId}) async {
    final body = {
      'user_id': userId,
      'provide_user_id': userId, // 必ず提供者＝自分でよい？
      'name': name,
      'memo': memo,
      'price': price,
      'shipping_period': shipping,
      'enabled_flag': enabledFlag,
      'item_id': itemId,
      'public_flag': isRelease,
      'customer_user_id': customerUserId,
    };
    if (base64Images != null) {
      base64Images.forEach((int index, String base64Image) {
        body['img${index + 1}'] = base64Image;
      });
    }
    if (deleteImageIndices != null) {
      for (final index in deleteImageIndices) {
        body['delete_img${index + 1}'] = true;
      }
    }

    final response = await _sendPost(ApiPath.ecItem, body: body);
    return _detect401(response);
  }

  // 商品購入
  Future<JsonData> postPurchase({
      @required String userId,
      @required String provideUserId,
      @required String itemId,
  }) async {
    final body = {
      'user_id': userId,
      'provide_user_id': provideUserId,
      'item_id': itemId,
    };

    final response = await _sendPost(ApiPath.ecPurchase, body: body);
    return _detect401(response);
  }

  // 商品購入履歴
  Future<JsonData> getEcOrderHistory({String itemId}) async {
    final Map<String, String> query = {};
    if (itemId != null)
      query['item_id'] = itemId;

    final response = await _sendGet(ApiPath.ecOrderHistory, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postPurchaseCancel(String provideUserId, String orderId, String cancelMemo, bool isTargetProvider) async {
    final body = {
      'provide_user_id': provideUserId,
      'order_id': orderId,
      'cancel_memo': cancelMemo,
      'cancel_target': isTargetProvider ? 1 : 2,
    };
    final response = await _sendPost(ApiPath.ecCancel, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postPurchaseDelivery({
    @required String itemId,
    bool updateInfo,
    String deliveryName,
    String deliveryPostalCode,
    String deliveryAddr,
    String deliveryBuild,
    String deliveryPhone,
    bool updateBegin,
    bool updateEnd,
    String deliveryProviderId,
    String trackingNum,
    bool trackingFlag,
    bool irregular,
  }) async {
    var purchaseDelivery = PurchaseDelivery(
      itemId,
      updateInfo: updateInfo,
      deliveryName: deliveryName,
      deliveryPostalCode: deliveryPostalCode,
      deliveryAddr: deliveryAddr,
      deliveryBuild: deliveryBuild,
      deliveryPhone: deliveryPhone,
      updateBegin: updateBegin,
      updateEnd: updateEnd,
      deliveryProviderId: deliveryProviderId,
      trackingNum: trackingNum,
      trackingFlag: trackingFlag,
      irregular: irregular,
    );

    final response = await _sendPost(ApiPath.ecPurchaseDelivery,
        body: purchaseDelivery.toMap());
    return Future.value(_detect401(response));
  }

  /// ストアプロフィールの取得.
  Future<JsonData> getStoreProfile() async {
    final response = await _sendGet(ApiPath.ecStoreProfile);
    return Future.value(_detect401(response));
  }

  /// ストアプロフィールの登録.
  Future<JsonData> postStoreProfile({
    @required int index,
    @required String itemName, // 説明の概要.
    @required String memo, // ショップの説明.
    @required bool publicFlag, // 下書き時はfalse.
    List<dynamic> base64Images, // 画像(base64エンコード済み).
    List<String> imageUrls, // 画像(URL).
  }) async {
    final body = {
      'index': index,
      'item_name': itemName,
      'memo': memo,
      'public_flag': publicFlag,
    };
    for (int i = 0; i < Consts.PRODUCT_MAX_PHOTOS; i++) {
      if (base64Images[i] != null) {
        body['img${i + 1}'] = base64Images[i];
        continue;
      } else if (imageUrls[i] == null) {
        body['img${i + 1}'] = null;
      }
    }
    final response = await _sendPost(ApiPath.ecStoreProfile, body: body);
    return _detect401(response);
  }

  Future<JsonData> deleteStoreProfile({int index}) async {
    final Map<String, dynamic> query = {
      'index': index,
    };
    final response = await _sendDelete(ApiPath.ecStoreProfile, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getTimeline({String id, int size, int offset}) async {
    final query = {'id': id, 'size': size, 'offset': offset};
    final response = await _sendGet(ApiPath.timeline, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postTimeline(String text,
      {String base64Image, String timelineId}) async {
    final Map<String, String> body = {
      'text': text,
    };
    if (timelineId != null) {
      body['timeline_id'] = timelineId;
    }
    if (base64Image != null) {
      body['image'] = base64Image;
    }
    final response = await _sendPost(ApiPath.timeline,
        body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> deleteTimeline(String timelineId) async {
    final response = await _sendDelete(ApiPath.timeline, query: {'timeline_id': timelineId});
    return Future.value(_detect401(response));
  }

  Future<JsonData> postTimelineLike(String timelineId, bool newLiked) async {
    final body = {
      'timeline_id': timelineId,
      'like': newLiked,
    };
    final response = await _sendPost(ApiPath.timelineLike, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getTimelineMessage(String timelineId) async {
    final response = await _sendGet(ApiPath.timelineMessage, query: {
      'timeline_id': timelineId,
    });
    return Future.value(_detect401(response));
  }

  Future<JsonData> postTimelineMessage(String timelineId, String message) async {
    final body = {
      'timeline_id': timelineId,
      'message': message,
    };
    final response = await _sendPost(ApiPath.timelineMessage, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getUserFollow(String id, String userId) async {
    final response = await _sendGet(ApiPath.userFollow, query: {
      'id': id,
      'user_id': userId,
    });
    return Future.value(_detect401(response));
  }

  Future<JsonData> postUserFollow({String followId, String unfollowId}) async {
    final Map<String, String> body = {};
    if (followId != null) {
      body['follow_id'] = followId;
    } else {
      body['unfollow_id'] = unfollowId;
    }
    final response = await _sendPost(ApiPath.userFollow, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postUserNotification(
      {@required String id,
      @required bool notifyTimeline,
      @required bool notifyLive,
      @required bool notifyEC}) async {
    final body = {
      'follow_id': id, // <= これを与えないと失敗する
      'id': id,
      'notify_timeline': notifyTimeline,
      'notify_live': notifyLive,
      'notify_ec': notifyEC,
    };

    // API的には/user/followとまとめられてしまっているが、
    // 内容はかぶらないので別メソッドとする。
    final response = await _sendPost(ApiPath.userFollow, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getUserFollower(String id) async {
    final response = await _sendGet(ApiPath.userFollower, query: {
      'id': id,
    });
    return Future.value(_detect401(response));
  }

  Future<JsonData> getProducts(String userId, {String providerUserId}) async {
    final query = {
      'user_id': userId,
      'provide_user_id': providerUserId,
    };
    final response = await _sendGet(ApiPath.products, query: query);
    return Future.value(_detect401(response));
  }

  /// ランキング種別を取得.
  Future<JsonData> getRankList({String userId}) async {
    final query = {
      'id': userId,
    };
    final response = await _sendGet(ApiPath.rankList, query: query);
    return Future.value(_detect401(response));
  }

  /// ランキングを取得.
  Future<JsonData> getRank({String url, String userId}) async {
    final query = {
      'id': userId,
    };
    final response = await _sendGet(url, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getRankLiverPoint() async {
    final response = await _sendGet(ApiPath.rankLiverPoint);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getRankLiverGift() async {
    final response = await _sendGet(ApiPath.rankLiverGift);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getRankLiverGiftMonthly({String userId}) async {
    final query = {
      'id': userId,
    };
    final response = await _sendGet(ApiPath.rankLiverGiftMonthly, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getRankLiverPerson() async {
    final response = await _sendGet(ApiPath.rankLiverPerson);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getRankFun(String userId) async {
    final query = {
      'user_id': userId,
    };
    final response = await _sendGet(ApiPath.rankFun, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getRankLiveGift(String liverId) async {
    final query = {
      'liver_id': liverId,
    };
    final response = await _sendGet(ApiPath.rankLiveGift, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getRankLiveGiftMonthly(String liverId) async {
    final query = {
      'liver_id': liverId,
    };
    final response = await _sendGet(ApiPath.rankLiveGiftMonthly, query: query);
    return Future.value(_detect401(response));
  }

  Future<CoinHistory> getCoinHistory(String userId, {int size, int offset}) async {
    final query = {
      'auth_id': userId,
    };
    final response =
        await _sendGet(ApiPath.pointHistory, query: query);
    return CoinHistory.fromJson(_detect401(response));
  }

  Future<JsonData> getInfo({int size, int offset, String infoId}) async {
    final Map<String, dynamic> query = {
      'size': size,
      'offset': offset,
    };
    if (infoId != null)
      query['id'] = infoId;

    final response = await _sendGet(ApiPath.info, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getInfoEc() async {
    final response = await _sendGet(ApiPath.infoEc);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postInfoEcRead(String itemId) async {
    final body = {
      'item_id': itemId,
    };
    final response = await _sendPost(ApiPath.infoEcRead, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getInfoBanner({int size, int offset}) async {
    final query = {
      'size': size,
      'has_eyecatch': true,
    };

    final response = await _sendGet(ApiPath.info, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postCode(int pinCode, String userId) async {
    final body = {'code': pinCode, 'user_id': userId};
    final response = await _sendPost(ApiPath.code, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postUser(SignUpModel model) async {
    final response = await _sendPost(ApiPath.user, body: model.toMap());
    return Future.value(_detect401(response));
  }

  Future<JsonData> postReceiptIos(String receipt) async {
    final Map<String, dynamic> body = {
      'receipt': receipt,
    };
    final response = await _sendPost(ApiPath.ReceiptVerifyIos,
        body: body, timeOut: Consts.TIME_OUT_IAP);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postReceiptAndroid(Map receipt, String signature) async {
    final Map<String, dynamic> body = {
      "orderId": receipt["orderId"],
      "packageName": receipt["packageName"],
      "productId": receipt["productId"],
      "purchaseTime": receipt["purchaseTime"],
      "purchaseState": receipt["purchaseState"],
      "purchaseToken": receipt["purchaseToken"],
      "acknowledged": receipt["acknowledged"],
      "signature": signature,
    };
    final response = await _sendPost(ApiPath.ReceiptVerifyAndroid,
        body: body, timeOut: Consts.TIME_OUT_IAP);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getLiveUsers(String liveId, {int offset=0}) async {
    final Map<String, dynamic> query = {
      'live_id': liveId,
      'offset': offset,
    };
    final response = await _sendGet(ApiPath.liveUsers, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getBlockListener() async {
    final response = await _sendGet(ApiPath.blockListener);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postBlockListener(String targetUserId, bool block) async {
    final body = {
      'id': targetUserId,
      'is_block': block,
    };
    final response = await _sendPost(ApiPath.blockListener, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postUnregist() async {
    final response = await _sendPost(ApiPath.unregist);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getDeliveryProvider() async {
    final response = await _sendGet(ApiPath.deliveryProvider);
    return Future.value(_detect401(response));
  }

  Future<JsonData> getMonthlyRank() async {
    final response = await _sendGet(ApiPath.rank);
    return Future.value(_detect401(response));
  }

  // Bank

  Future<JsonData> postBankBilling({
    @required String itemId,
    @required int bankId,
    @required DeliveryAddress deliveryAddress,
  }) async {
    final Map<String, dynamic> body = {
      'item_id': itemId,
      'bank_id': bankId,
    };
    body.addAll(deliveryAddress.toMap());

    final response = await _sendPost(ApiPath.bankBilling, body: body);
    return _detect401(response);
  }

  // 振込先情報取得
  Future<JsonData> getBankBillingInfo() async {
    final response = await _sendGet(ApiPath.bankBillingInfo);
    return Future.value(_detect401(response));
  }

  // Credit

  Future<JsonData> postCreditBilling(String itemId, DateTime requestDate, {
    @required DeliveryAddress deliveryAddress,
  }) async {
    final requestDateStr = DateFormat('yyyyMMddHHmmss').format(requestDate);
    final Map<String, dynamic> body = {
      'item_id': itemId,
      'request_date': requestDateStr,
    };
    body.addAll(deliveryAddress.toMap());
    final response = await _sendPost(ApiPath.creditBilling, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postCreditResult(CreditResultType resultType, String result, String itemId) async {
    int type;
    switch (resultType) {
      case CreditResultType.Payment:   type = 1; break;
      case CreditResultType.Register:  type = 2; break;
    }
    final body = {
      'type': type,
      'result': result,
      'item_id': itemId,
    };
    final response = await _sendPost(ApiPath.creditResult, body: body);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postInquiry(Inquiry inquiry) async {
    final response = await _sendPost(ApiPath.inquiry, body: inquiry.toMap(), timeOut: 120);
    return Future.value(_detect401(response));
  }

  // 商品受け取り
  Future<JsonData> postReceiveItem(String itemId) async {
    final body = {
      'item_id': itemId,
    };
    final response = await _sendPost(ApiPath.receiveItem, body: body);
    return Future.value(_detect401(response));
  }

  // 出金申請
  Future<JsonData> postPointWithdraw(int price) async {
    final body = {
      'price': price,
    };
    final response = await _sendPost(ApiPath.pointWithdraw, body: body);
    return Future.value(_detect401(response));
  }

  // 報酬履歴
  Future<JsonData> getBenefitLog({@required bool onlyWithdraw}) async {
    final query = {
      'only_withdraw': onlyWithdraw,
    };
    final response = await _sendGet(ApiPath.benefitLog, query: query);
    return Future.value(_detect401(response));
  }

  Future<JsonData> postJasrac(Jasrac jasrac) async {
    final response = await _sendPost(ApiPath.jasrac, body: jasrac.toMap());
    return Future.value(_detect401(response));
  }

  /// 配送先を取得.
  Future<JsonData> getUserDeliveryAddress() async {
    final response = await _sendGet(ApiPath.userDeliveryAddress);
    return Future.value(_detect401(response));
  }

  /// 配送先を登録.
  Future<JsonData> postUserDeliveryAddress({
    int id,
    @required String name,
    @required String postalCode,
    @required String address,
    @required String building,
    @required String phoneNumber,
  }) async {
    final body = {
      'id': id,
      'name': name,
      'postal_code': postalCode,
      'addr': address,
      'build': building,
      'phone': phoneNumber,
    };
    final response = await _sendPost(
      ApiPath.userDeliveryAddress,
      body: body,
    );
    return Future.value(_detect401(response));
  }

  /// 配送先を削除.
  Future<JsonData> deleteUserDeliveryAddress({@required int id}) async {
    final Map<String, dynamic> query = {
      'id': "$id",
    };
    final response =
        await _sendDelete(ApiPath.userDeliveryAddress, query: query);
    return Future.value(_detect401(response));
  }

  /// テンプレートの取得.
  Future<JsonData> getEcTemplate() async {
    final response = await _sendGet(ApiPath.ecTemplate);
    return Future.value(_detect401(response));
  }

  /// テンプレートの作成 or 編集.
  Future<JsonData> postEcTemplate({
    @required int id,
    @required String name,
    @required String itemName,
    @required String memo,
    @required int shippingPeriod,
    @required int price,
    List<dynamic> base64Images,
    List<String> imageUrls,
  }) async {
    final body = {
      'id': id,
      'name': name,
      'item_name': itemName,
      'memo': memo,
      'shipping_period': shippingPeriod,
      'price': price,
    };
    for (int i = 0; i < Consts.PRODUCT_MAX_PHOTOS; i++) {
      if (base64Images[i] != null) {
        body['img${i + 1}'] = base64Images[i];
      } else if (imageUrls[i] == null) {
        body['img${i + 1}'] = null;
      }
    }
    final response = await _sendPost(ApiPath.ecTemplate, body: body);
    return _detect401(response);
  }

  /// テンプレートから商品を作成.
  Future<JsonData> postEcItemFromTemplate({@required int id}) async {
    final Map<String, dynamic> body = {
      'id': id,
    };
    final response = await _sendPost(ApiPath.ecItemFromTemplate, body: body);
    return _detect401(response);
  }

  /// 販売済みの商品の表示を消す.
  Future<JsonData> postEcItemInvisiblePurchased({@required List<String> itemIds}) async {
    final Map<String, dynamic> body = {
      'item_ids': itemIds,
    };
    final response = await _sendPost(ApiPath.ecItemInvisiblePurchased, body: body);
    return _detect401(response);
  }

  /// チャットのメッセージ取得.
  Future<JsonData> getEcItemChat({
    @required String orderId,
  }) async {
    final Map<String, dynamic> query = {
      'order_id': orderId,
    };
    final response = await _sendGet(ApiPath.ecItemChat, query: query);
    return _detect401(response);
  }

  /// チャットにメッセージを登録.
  Future<JsonData> postEcItemChat({
    @required String orderId,
    @required String message,
  }) async {
    final Map<String, dynamic> body = {
      'order_id': orderId,
      'message': message,
    };
    final response = await _sendPost(ApiPath.ecItemChat, body: body);
    return _detect401(response);
  }

  /// イベント広告の確認.
  Future<JsonData> getNotificationCheck() async {
    final response = await _sendGet(ApiPath.notificationCheck);
    return _detect401(response);
  }

  /// イベント広告の取得.
  Future<JsonData> getNotificationInfo() async {
    final Map<String, dynamic> query = {
      '_token': '',
    };
    final response = await _sendGet(ApiPath.notificationInfo, query:query);
    return _detect401(response);
  }

  /// ウェブトークンの取得.
  Future<JsonData> getWebToken() async {
    final response = await _sendGet(ApiPath.webToken);
    return _detect401(response);
  }

  /// イベント開催予定一覧の取得.
  Future<JsonData> getEventListPlaned() async {
    final response = await _sendGet(ApiPath.eventListPlaned);
    return _detect401(response);
  }

  /// イベント開催中一覧の取得.
  Future<JsonData> getEventListLive() async {
    final response = await _sendGet(ApiPath.eventListLive);
    return _detect401(response);
  }

  /// イベント終了一覧の取得.
  Future<JsonData> getEventListFinished() async {
    final response = await _sendGet(ApiPath.eventListFinished);
    return _detect401(response);
  }

  /// イベント参加募集一覧の取得.
  Future<JsonData> getEventListInvited() async {
    final response = await _sendGet(ApiPath.eventListInvited);
    return _detect401(response);
  }

  /// イベント概要の取得.
  Future<JsonData> getEventOverView({
    @required String id,
  }) async {
    final response = await _sendGet(ApiPath.eventOverView(id));
    return _detect401(response);
  }

  /// イベントランキングの取得.
  Future<JsonData> getEventRanking({
    @required String id,
  }) async {
    final response = await _sendGet(ApiPath.eventRanking(id));
    return _detect401(response);
  }

  /// イベントプライズの取得.
  Future<JsonData> getEventPrize({
    @required String id,
  }) async {
    final response = await _sendGet(ApiPath.eventPrize(id));
    return _detect401(response);
  }

  /// イベント参加者の取得.
  Future<JsonData> getEventMember({
    @required String id,
  }) async {
    final response = await _sendGet(ApiPath.eventMember(id));
    return _detect401(response);
  }

  /// イベントへ参加.
  Future<JsonData> postEventEntry({
    @required String id,
  }) async {
    var body = {
      'event_id': id,
    };
    final response = await _sendPost(ApiPath.eventEntry, body: body);
    return _detect401(response);
  }

  /// イベント参加解除.
  Future<JsonData> deleteEventEntry({
    @required String id,
  }) async {
    var query = {
      'event_id': id,
    };
    final response = await _sendDelete(ApiPath.eventEntry, query: query);
    return _detect401(response);
  }

  /// イベントフォロー.
  Future<JsonData> postEventFollow({
    @required String id,
  }) async {
    var body = {
      'event_id': id,
    };
    final response = await _sendPost(ApiPath.eventFollow, body: body);
    return _detect401(response);
  }

  /// イベントフォロー解除.
  Future<JsonData> deleteEventFollow({
    @required String id,
  }) async {
    var query = {
      'event_id': id,
    };
    final response = await _sendDelete(ApiPath.eventFollow, query: query);
    return _detect401(response);
  }
}
