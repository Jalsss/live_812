import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/repository/network_repository.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/ui/item/LiverGridItem.dart';
import 'package:live812/ui/scenes/search/search_live.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../_aux/image_test_utils.dart';
import '../../../_aux/test_aux.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockNetworkRepository extends Mock implements NetworkRepository {}

Widget _boilerplate(UserModel userModel) {
  return ChangeNotifierProvider<UserModel>(
    create: (_) => userModel,
    lazy: false,
    child: MaterialApp(
      home: Scaffold(
        body: SearchLive(),
      ),
    ),
  );
}

void main() {
  tearDown(() {
    Injector.getInjector().dispose();
  });

  testWidgets('Show recommendations in initial', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      final userId = 'UserId';
      final testLiverUserId = 'LiverId';
      final testLiverNickname = 'LiverNickname';
      final thumbUrl = '//localhost/dummy.jpg';

      final mockNetworkRepo = MockNetworkRepository();

      final injector = Injector.getInjector();
      injector.map<NetworkRepository>((i) => mockNetworkRepo,
          isSingleton: true);
      when(mockNetworkRepo.sendRequest(
        Method.GET,
        ApiPath.user,
        query: {'recommend_liver': 'true', 'user_id': userId},
        timeOut: anyNamed('timeOut'),
      )).thenAnswer((_) {
        return Future.value(http.Response(
            jsonEncode({
              "result": true,
              "data": [
                {
                  'id': testLiverUserId,
                  'nickname': testLiverNickname,
                  'img_thumb_url': thumbUrl,
                  'img_small_url': thumbUrl,
                },
              ],
            }),
            200));
      });

      final userModel = UserModel.fromJson({
        'id': userId,
      });

      // Build our app and trigger a frame.
      await tester.pumpWidget(_boilerplate(userModel));
      await tester.pumpAndSettle();

      expect(find.text('おすすめのライバー'), findsOneWidget);
      expect(find.byType(LiverGridItem), findsOneWidget);
      expect(find.text(testLiverNickname), findsOneWidget);
      expect(findDecorationNetworkImage(url: thumbUrl), findsOneWidget);
    });
  });

  testWidgets('Show search result', (WidgetTester tester) async {
    provideMockedNetworkImages(() async {
      final userId = 'UserId';
      final query = 'someone';
      final testLiverUserId = 'LiverId';
      final testLiverNickname = 'LiverNickname';
      final thumbUrl = '//localhost/dummy.jpg';

      final mockNetworkRepo = MockNetworkRepository();

      final injector = Injector.getInjector();
      injector.map<NetworkRepository>((i) => mockNetworkRepo,
          isSingleton: true);
      when(mockNetworkRepo.sendRequest(
        Method.GET,
        ApiPath.user,
        query: {'recommend_liver': 'true', 'user_id': userId},
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
        ApiPath.user,
        query: {'kwd': query, 'is_liver': true, 'size': null, 'offset': null},
        timeOut: anyNamed('timeOut'),
      )).thenAnswer((_) {
        return Future.value(http.Response(
            jsonEncode({
              "result": true,
              "data": [
                {
                  'id': testLiverUserId,
                  'nickname': testLiverNickname,
                  'img_thumb_url': thumbUrl,
                  'img_small_url': thumbUrl,
                },
              ],
            }),
            200));
      });

      final userModel = UserModel.fromJson({
        'id': userId,
        'is_liver': false,
      });

      // Build our app and trigger a frame.
      await tester.pumpWidget(_boilerplate(userModel));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), query);
      await tester.tap(find.text(Lang.SEARCH));
      await tester.pumpAndSettle();

      expect(find.text('おすすめのライバー'), findsNothing);
      expect(find.byType(LiverGridItem), findsOneWidget);
      expect(find.text(testLiverNickname), findsOneWidget);
      expect(findDecorationNetworkImage(url: thumbUrl), findsOneWidget);
    });
  });
}
