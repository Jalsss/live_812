import 'dart:convert';

import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/repository/network_repository.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/domain/usecase/user_info_usecase.dart';
import 'package:mockito/mockito.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

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

  test('updateMyInfo success', () async {
    final apiToken = 'ApiToken';
    final onetimeToken = 'OnetimeToken';
    final userId = 'UserId';
    final symbol = 'Symbol';
    final name = 'Name';
    final nickname = 'Nickname';
    final emailAddress = 'dummy@live812.works';

    final mockNetworkRepo = MockNetworkRepository();
    final mockUserModel = MockUserModel();

    final injector = Injector.getInjector();
    injector.map<NetworkRepository>((i) => mockNetworkRepo, isSingleton: true );
    injector.mapWithParams<UserModel>((i, p) => mockUserModel);

    BackendService.setApiToken(apiToken);
    when(mockNetworkRepo.sendRequest(
      Method.GET, ApiPath.myRequest, query: {'token': apiToken},
      headers: null, body: null, encoding: null, timeOut: anyNamed('timeOut'),
    )).thenAnswer((_) {
      return Future.value(http.Response(jsonEncode({
        "result": true,
        "onetime_token": onetimeToken,
      }), 200));
    });
    when(mockNetworkRepo.sendRequest(
      Method.GET, ApiPath.my, query: {'token': apiToken, 'onetime_token': onetimeToken},
      headers: null, body: null, encoding: null, timeOut: anyNamed('timeOut'),
    )).thenAnswer((_) {
      return Future.value(http.Response(jsonEncode({
        "result": true,
        "data": {
          "token": apiToken,
          "id": userId,
          "user_id": symbol,
          "name": name,
          "nickname" : nickname,
          "mail": emailAddress,
        },
      }), 200));
    });

    final result = await UserInfoUsecase.updateMyInfo(null);
    expect(result?.item1, UpdateMyInfoResult.SUCCESS);
    expect(mockUserModel.token, apiToken);
    expect(mockUserModel.id, userId);
    expect(mockUserModel.symbol, symbol);
    expect(mockUserModel.nickname, nickname);
    expect(mockUserModel.emailAddress, emailAddress);
  });

  test('updateMyInfo timeout', () async {
    final apiToken = 'ApiToken';

    final mockNetworkRepo = MockNetworkRepository();
    final mockUserModel = MockUserModel();

    final injector = Injector.getInjector();
    injector.map<NetworkRepository>((i) => mockNetworkRepo, isSingleton: true );
    injector.mapWithParams<UserModel>((i, p) => mockUserModel);

    BackendService.setApiToken(apiToken);
    when(mockNetworkRepo.sendRequest(
      Method.GET, ApiPath.myRequest, query: {'token': apiToken},
      headers: null, body: null, encoding: null, timeOut: anyNamed('timeOut'),
    )).thenAnswer((_) {
      return Future.value(http.Response(jsonEncode({
        "result": true,
        "msg": 'Timeout',
      }), 408));
    });

    final result = await UserInfoUsecase.updateMyInfo(null);
    expect(result?.item1, UpdateMyInfoResult.NETWORK_ERROR);
    expect(mockUserModel.token, isNull);
  });
}
