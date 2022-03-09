import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:live812/domain/model/user/badge_info.dart';
import 'package:live812/domain/model/user/news_event.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/ui/routes.dart';
import 'package:live812/ui/scenes/splash/splash_screen.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/widget/fallback_cupertino_localizations_delegate.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  final _badgeInfo = BadgeInfo();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness: Brightness.dark));
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserModel>(
          create: (_) => UserModel(),
          lazy: false,
        ),
        ChangeNotifierProvider<BadgeInfo>(
          create: (_) => _badgeInfo,
        ),
        ChangeNotifierProvider<NewsEventModel>(
          create: (context) => NewsEventModel(),
        ),
      ],
      child: GestureDetector(
        onTap: () => KeyboardUtil.close(context),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Lang.APP_NAME,
          navigatorObservers: [BotToastNavigatorObserver()],
          theme: ThemeData(
            fontFamily: 'NotoSansJP',
            primarySwatch: Colors.blue,
          ),
          home: SplashScreen(),
          routes: routes,

          supportedLocales: [
            const Locale('ja', 'JP'),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FallbackCupertinoLocalizationsDelegate(),
          ],
        ),
      ),
    );
  }
}
