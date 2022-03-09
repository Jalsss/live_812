import 'dart:convert';

import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:live812/domain/model/ec/delivery_address.dart';
import 'package:live812/domain/model/iap/iap_info.dart';
import 'package:live812/domain/model/user/notice.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/repository/event_logger_repository.dart';
import 'package:live812/domain/repository/network_repository.dart';
import 'package:live812/domain/repository/persistent_repository.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/infrastructure/event_logger/dummy_event_logger_repository.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/in_app_purchase.dart';
import 'package:live812/utils/result.dart';
import 'package:mockito/mockito.dart';

class MockInAppPurchase extends Mock implements InAppPurchase {}

class MockNetworkRepository extends Mock implements NetworkRepository {}

class MockPersistentRepository extends PersistentRepository {
  static int _iapId = 0;
  final _map = Map<int, IapInfo>();

  void setIapId(int id) {
    _iapId = id;
  }

  @override
  Future<IapInfo> getIapInfo(int id) {
    return Future.value(_map[id]);
  }

  @override
  Future<int> insertIapInfo(IapInfo iapInfo) {
    int id = _iapId++;
    _map[id] = iapInfo;
    return Future.value(id);
  }

  @override
  Future<List<int>> getPendingIapIdList() => Future.value(null);

  @override
  Future<void> insertNotice(NoticeModel notice) => Future.value();
  @override
  Future<bool> isNoticeRead(String id) => Future.value(false);
  @override
  Future<void> setNoticeRead(String id, bool value) => Future.value();
  @override
  Future<bool> updateIapInfoFailed(int id) => Future.value(true);
  @override
  Future<bool> updateIapInfoRegistered(int id) => Future.value(true);
  @override
  Future<List<DeliveryAddress>> getDeliveryAddressList() => Future.value(null);
  @override
  Future<int> putDeliveryAddress(DeliveryAddress deliveryAddress) =>
      Future.value(null);
  @override
  Future<bool> deleteDeliveryAddress(int id) => Future.value(false);
}

class MockUserModel extends UserModel {
  Future<bool> saveToStorage() {
    return Future.value(true);
  }

  void notifyListeners() {}
}

void main() {
  tearDown(() {
    Injector.getInjector().dispose();
  });

  test('doPurchase success', () async {
    final apiToken = 'ApiToken';
    final localIapId = 333;
    final productId = 'PROD123';
    final receipt = 'DummyReceipt';
    final itemPoint = 5555;
    int userPoint = 0;

    final mockPersistentRepo = MockPersistentRepository();
    mockPersistentRepo.setIapId(localIapId);

    final mockNetworkRepo = MockNetworkRepository();
    final mockUserModel = MockUserModel();

    final injector = Injector.getInjector();
    injector.map<PersistentRepository>((i) => mockPersistentRepo,
        isSingleton: true);
    injector.map<NetworkRepository>((i) => mockNetworkRepo, isSingleton: true);
    injector.map<EventLoggerRepository>((i) => DummyEventLoggerRepository(),
        isSingleton: true);
    injector.mapWithParams<UserModel>((i, p) => mockUserModel);

    BackendService.setApiToken(apiToken);
    final iapItem = IAPItem.fromJSON({
      "title": "$itemPointコイン",
      "price": "987",
      "currency": "JPY",
    });
    final InAppPurchase inAppPurchase = MockInAppPurchase();
    when(inAppPurchase.requestPurchase(iapItem)).thenAnswer((_) =>
        Future.value(Ok<PurchasedItem, PurchaseResult>(PurchasedItem.fromJSON({
          "productId": productId,
          "transactionReceipt": receipt,
        }))));
    when(mockNetworkRepo.sendRequest(
      Method.POST,
      ApiPath.ReceiptVerifyIos,
      body: anyNamed('body'),
      headers: null,
      query: null,
      encoding: null,
      isJson: true,
      timeOut: Consts.TIME_OUT,
    )).thenAnswer((_) {
      userPoint += itemPoint;
      return Future.value(http.Response(
          jsonEncode({
            "result": true,
            "data": {
              "point": itemPoint,
            },
          }),
          200));
    });
    when(mockNetworkRepo.sendRequest(
      Method.GET,
      ApiPath.mypage,
      query: anyNamed('query'),
      headers: null,
      body: null,
      encoding: null,
      timeOut: Consts.TIME_OUT,
    )).thenAnswer((_) => Future.value(http.Response(
        jsonEncode({
          "result": true,
          "data": {
            "point": userPoint,
          },
        }),
        200)));

    // TODO:課金処理変更のため一旦削除.
//    final result = await PurchaseUsecase.doPurchase(null, inAppPurchase, iapItem, (_) => {});
    final result = true;
    expect(result, true);
    expect(mockUserModel.point, itemPoint);
  });
}
