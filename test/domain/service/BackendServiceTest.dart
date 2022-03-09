import 'dart:convert';

import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:live812/domain/model/user/signup.dart';
import 'package:live812/domain/model/user/user_info.dart';
import 'package:live812/domain/repository/network_repository.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:mockito/mockito.dart';

class MockNetworkRepository extends Mock implements NetworkRepository {}

void main() {
  tearDown(() {
    Injector.getInjector().dispose();
  });

  test('getUser', () async {
    final apiToken = 'ApiToken';
    final userId = 'UserId';

    final mockNetworkRepo = MockNetworkRepository();

    final injector = Injector.getInjector();
    injector.map<NetworkRepository>((i) => mockNetworkRepo, isSingleton: true );

    BackendService.setApiToken(apiToken);
    when(mockNetworkRepo.sendRequest(
      Method.GET, ApiPath.user,
      query: {
        'token': apiToken,
        'id': userId,
      },
      timeOut: anyNamed('timeOut'),
    )).thenAnswer((_) {
      return Future.value(http.Response(jsonEncode({
        "result": true,
      }), 200));
    });

    final context = null;
    final service = BackendService(context);
    var response = await service.getUser(userId);
    expect(response?.result, true);
  });

  test('postUser', () async {
    final apiToken = 'ApiToken';
    final userId = 'UserId';
    final symbol = 'Symbol';
    final nickname = 'Nickname';
    final password = 'Password';

    final mockNetworkRepo = MockNetworkRepository();

    final injector = Injector.getInjector();
    injector.map<NetworkRepository>((i) => mockNetworkRepo, isSingleton: true );

    BackendService.setApiToken(apiToken);
    when(mockNetworkRepo.sendRequest(
      Method.POST, ApiPath.user,
      body: {
        'token': apiToken,
        'id': userId,
        'nickname': nickname,
        'user_id': symbol,
        'pass': password,
      },
      isJson: true, timeOut: anyNamed('timeOut'),
    )).thenAnswer((_) {
      return Future.value(http.Response(jsonEncode({
        "result": true,
      }), 200));
    });

    var signUpModel = SignUpModel(
      apiToken,
      userId,
      nickname,
      symbol,
      password,
    );
    final context = null;
    final service = BackendService(context);
    var response = await service.postUser(signUpModel);
    expect(response?.result, true);
  });

  test('puttUser', () async {
    final apiToken = 'ApiToken';
    final profile = 'Profile';

    final mockNetworkRepo = MockNetworkRepository();

    final injector = Injector.getInjector();
    injector.map<NetworkRepository>((i) => mockNetworkRepo, isSingleton: true );

    BackendService.setApiToken(apiToken);
    when(mockNetworkRepo.sendRequest(
      Method.PUT, ApiPath.user,
      body: {
        'token': apiToken,
        'profile': profile,
      },
      isJson: true, timeOut: anyNamed('timeOut'),
    )).thenAnswer((_) {
      return Future.value(http.Response(jsonEncode({
        "result": true,
      }), 200));
    });

    var userInfo = UserInfoModel(profile: profile);
    final context = null;
    final service = BackendService(context);
    var response = await service.putUser(userInfo);
    expect(response?.result, true);
  });

  test('deleteTimeline', () async {
    final apiToken = 'ApiToken';
    final timelineId = '1234';

    final mockNetworkRepo = MockNetworkRepository();

    final injector = Injector.getInjector();
    injector.map<NetworkRepository>((i) => mockNetworkRepo, isSingleton: true );

    BackendService.setApiToken(apiToken);
    when(mockNetworkRepo.sendRequest(
      Method.DELETE, ApiPath.timeline,
      query: {
        'token': apiToken,
        'timeline_id': timelineId,
      },
      timeOut: anyNamed('timeOut'),
    )).thenAnswer((_) {
      return Future.value(http.Response(jsonEncode({
        "result": true,
      }), 200));
    });

    final context = null;
    final service = BackendService(context);
    var response = await service.deleteTimeline(timelineId);
    expect(response?.result, true);
  });
}
