import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:live812/domain/model/user/badge_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/repository/network_repository.dart';
import 'package:live812/domain/repository/persistent_repository.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/ui/scenes/home/bottom_navigation.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../_aux/image_test_utils.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockNetworkRepository extends Mock implements NetworkRepository {}

class MockPersistentRepository extends Mock implements PersistentRepository {}

Widget _boilerplate(UserModel userModel, BadgeInfo badgeInfo) {
  return ChangeNotifierProvider<UserModel>(
    create: (_) => userModel,
    lazy: false,
    child: ChangeNotifierProvider<BadgeInfo>(
      create: (_) => badgeInfo,
      child: MaterialApp(
        home: Scaffold(
          body: BottomNav(),
        ),
      ),
    ),
  );
}

void main() {
  tearDown(() {
    Injector.getInjector().dispose();
  });

  testWidgets('Liver has broadcast FAButton', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      final userId = 'UserId';

      final mockNetworkRepo = MockNetworkRepository();
      final mockPersistentRepo = MockPersistentRepository();

      final injector = Injector.getInjector();
      injector.map<NetworkRepository>((i) => mockNetworkRepo,
          isSingleton: true);
      injector.map<PersistentRepository>((i) => mockPersistentRepo,
          isSingleton: true);
      when(mockNetworkRepo.sendRequest(
        Method.GET,
        ApiPath.liverCategory,
        query: {},
        timeOut: anyNamed('timeOut'),
      )).thenAnswer((_) {
        return Future.value(http.Response(
            jsonEncode({
              "result": true,
              "data": [
                {
                  'id': 'cat1',
                  'name': 'Category-1',
                },
              ],
            }),
            200));
      });
      when(mockNetworkRepo.sendRequest(
        Method.GET, ApiPath.streamingLiveRoom,
        query: anyNamed('query'), // {'category': 'recommend', 'live_id': null},
        timeOut: anyNamed('timeOut'),
      )).thenAnswer((_) {
        return Future.value(http.Response(
            jsonEncode({
              "result": true,
              "data": [],
            }),
            200));
      });
      when(mockNetworkRepo.sendRequest(
        Method.GET,
        ApiPath.mypage,
        query: anyNamed('query'),
        timeOut: anyNamed('timeOut'),
      )).thenAnswer((_) {
        return Future.value(http.Response(
            jsonEncode({
              "result": true,
              "data": {},
            }),
            200));
      });
      when(mockNetworkRepo.sendRequest(
        Method.GET,
        ApiPath.info,
        query: anyNamed('query'),
        timeOut: anyNamed('timeOut'),
      )).thenAnswer((_) {
        return Future.value(http.Response(
            jsonEncode({
              "result": true,
              "data": [],
            }),
            200));
      });

      final userModel = UserModel.fromJson({
        'id': userId,
        'is_liver': true,
      });
      final badgeInfo = BadgeInfo();

      // Build our app and trigger a frame.
      await tester.pumpWidget(_boilerplate(userModel, badgeInfo));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('配 信'), findsOneWidget);
    });
  });

  testWidgets('Listener does not has broadcast FAButton',
      (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      final userId = 'UserId';

      final mockNetworkRepo = MockNetworkRepository();
      final mockPersistentRepo = MockPersistentRepository();

      final injector = Injector.getInjector();
      injector.map<NetworkRepository>((i) => mockNetworkRepo,
          isSingleton: true);
      injector.map<PersistentRepository>((i) => mockPersistentRepo,
          isSingleton: true);
      when(mockNetworkRepo.sendRequest(
        Method.GET,
        ApiPath.liverCategory,
        query: {},
        timeOut: anyNamed('timeOut'),
      )).thenAnswer((_) {
        return Future.value(http.Response(
            jsonEncode({
              "result": true,
              "data": [
                {
                  'id': 'cat1',
                  'name': 'Category-1',
                },
              ],
            }),
            200));
      });
      when(mockNetworkRepo.sendRequest(
        Method.GET, ApiPath.streamingLiveRoom,
        query: anyNamed('query'), // {'category': 'recommend', 'live_id': null},
        timeOut: anyNamed('timeOut'),
      )).thenAnswer((_) {
        return Future.value(http.Response(
            jsonEncode({
              "result": true,
              "data": [],
            }),
            200));
      });
      when(mockNetworkRepo.sendRequest(
        Method.GET,
        ApiPath.mypage,
        query: anyNamed('query'),
        timeOut: anyNamed('timeOut'),
      )).thenAnswer((_) {
        return Future.value(http.Response(
            jsonEncode({
              "result": true,
              "data": {},
            }),
            200));
      });
      when(mockNetworkRepo.sendRequest(
        Method.GET,
        ApiPath.info,
        query: anyNamed('query'),
        timeOut: anyNamed('timeOut'),
      )).thenAnswer((_) {
        return Future.value(http.Response(
            jsonEncode({
              "result": true,
              "data": [],
            }),
            200));
      });

      final userModel = UserModel.fromJson({
        'id': userId,
        'is_liver': false,
      });
      final badgeInfo = BadgeInfo();

      // Build our app and trigger a frame.
      await tester.pumpWidget(_boilerplate(userModel, badgeInfo));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('配 信'), findsNothing);
    });
  });
}
