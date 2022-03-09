import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live812/domain/build_type.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/ui/routes.dart';
import 'package:live812/ui/scenes/settings/setting_page.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

Widget _boilerplate(UserModel userModel, {List<NavigatorObserver>  navigatorObservers = const []}) {
  return ChangeNotifierProvider<UserModel>(
    create: (_) => userModel,
    lazy: false,
    child: MaterialApp(
      home: SettingPage(),
      routes: routes,
      navigatorObservers: navigatorObservers,
    ),
  );
}

void main() {
  tearDown(() {
    Injector.getInjector().dispose();
  });

  testWidgets('No debug menu on release mode', (WidgetTester tester) async {
    final injector = Injector.getInjector();
    injector.map<BuildType>((i) => BuildType.Release);

    final userModel = UserModel();

    // Build our app and trigger a frame.
    await tester.pumpWidget(_boilerplate(userModel));

    expect(find.text('（デバッグメニュー）'), findsNothing);
  });

  testWidgets('Menu items for liver', (WidgetTester tester) async {
    final injector = Injector.getInjector();
    injector.map<BuildType>((i) => BuildType.Release);

    final userModel = UserModel.fromJson({
      'is_liver': true,
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(_boilerplate(userModel));

    expect(find.text('ブロック設定'), findsOneWidget);
    expect(find.text('LIVE812ストリーミング配信規約'), findsOneWidget);
    expect(find.text('加盟店規約'), findsOneWidget);
    expect(find.text('出品物ガイドライン'), findsOneWidget);
  });

  testWidgets('Menu items for non-liver', (WidgetTester tester) async {
    final injector = Injector.getInjector();
    injector.map<BuildType>((i) => BuildType.Release);

    final userModel = UserModel.fromJson({
      'is_liver': false,
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(_boilerplate(userModel));

    expect(find.text('ブロック設定'), findsNothing);
    expect(find.text('LIVE812ストリーミング配信規約'), findsNothing);
    expect(find.text('加盟店規約'), findsNothing);
    expect(find.text('出品物ガイドライン'), findsNothing);
  });

  testWidgets('Page transition', (WidgetTester tester) async {
    final injector = Injector.getInjector();
    injector.map<BuildType>((i) => BuildType.Release);

    final nickname = 'Nickname';
    final userModel = UserModel.fromJson({
      'nickname': nickname,
    });

    // Build our app and trigger a frame.
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(_boilerplate(
      userModel,
      navigatorObservers: [mockObserver],
    ));

    // 「ニックネーム変更」タップ
    await tester.tap(find.text('ニックネーム変更'));
    await tester.pumpAndSettle();

    /// Verify that a push event happened
    verify(mockObserver.didPush(any, any));

    expect(find.text('ニックネーム変更'), findsOneWidget);
    expect(find.text('現在のニックネーム'), findsOneWidget);
    expect(find.text(nickname), findsOneWidget);
  });
}
