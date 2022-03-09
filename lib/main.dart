import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/build_type.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/repository/event_logger_repository.dart';
import 'package:live812/domain/repository/network_repository.dart';
import 'package:live812/domain/repository/persistent_repository.dart';
import 'package:live812/domain/usecase/gift_usecase.dart';
import 'package:live812/infrastructure/event_logger/adjust_event_logger_repository.dart';
import 'package:live812/infrastructure/http_network_repository.dart';
import 'package:live812/infrastructure/sqlite_persistent_repository.dart';
import 'package:live812/ui/my_app.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _initInjector();

  // Initializing FlutterFire.
  await Firebase.initializeApp();

  // Initialize Crash report.
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }

  // FutureProviderでうまく設定できなかったので、ここで取得.
  await GiftUseCase.initialize();

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Errors outside of Flutter
  Isolate.current.addErrorListener(RawReceivePort((List<dynamic> pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last as StackTrace,
    );
  }).sendPort);

  // Zoned Errors
  runZonedGuarded<Future<void>>(() async {
    runApp(MyApp());
  }, FirebaseCrashlytics.instance.recordError);
}

void _initInjector() {
  final injector = Injector.getInjector();

  const String MAINTENANCE_BASE_PATH = 'http://asset.live812.works/maintenance';

  var isRelease = const bool.fromEnvironment('dart.vm.product');
  if (isRelease) {
    injector.map<BuildType>((i) => BuildType.Release);
    injector.map<String>((i) => 'api.live812.works', key: Consts.KEY_DOMAIN);
    injector.map<String>((i) => 'https://socket.live812.works/socket', key: Consts.KEY_SOCKET_URL);

    String maintenanceUrl;
    if (Platform.isAndroid) {
      maintenanceUrl = '$MAINTENANCE_BASE_PATH/android.json';
    } else /*if (Platform.isIOS)*/ {
      maintenanceUrl = '$MAINTENANCE_BASE_PATH/ios.json';
    }
    injector.map<String>((i) => 'https://jasrac.live812.works/', key: Consts.KEY_JASRAC_URL);
    injector.map<String>((i) => maintenanceUrl, key: Consts.KEY_MAINTENANCE_URL);
    injector.map<String>((i) => 'https://event.live812.works/', key: Consts.KEY_LIVE_EVENT_URL);
    injector.map<String>((i) => 'https://asset.live812.works/gift', key: Consts.KEY_GIFT_URL);

    injector.map<String>((i) => Consts.ADJUST_APP_TOKEN, key: Consts.KEY_ADJUST_APP_TOKEN);
    injector.map<String>((i) => Consts.ADJUST_EVENT_PURCHASE_COIN, key: Consts.KEY_ADJUST_EVENT_PURCHASE_COIN);
    injector.map<String>((i) => Consts.ADJUST_EVENT_PURCHASE_COIN_UNIQUE, key: Consts.KEY_ADJUST_EVENT_PURCHASE_COIN_UNIQUE);
    injector.map<String>((i) => Consts.ADJUST_EVENT_PURCHASE_EC_ITEM, key: Consts.KEY_ADJUST_EVENT_PURCHASE_EC_ITEM);
    injector.map<String>((i) => Consts.ADJUST_EVENT_PURCHASE_EC_ITEM_UNIQUE, key: Consts.KEY_ADJUST_EVENT_PURCHASE_EC_ITEM_UNIQUE);
  } else {
    injector.map<BuildType>((i) => BuildType.Debug);
    injector.map<String>((i) => 'dev-api.live812.works', key: Consts.KEY_DOMAIN);
    injector.map<String>((i) => 'https://dev-socket.live812.works/socket', key: Consts.KEY_SOCKET_URL);

    String maintenanceUrl;
    if (Platform.isAndroid) {
      maintenanceUrl = '$MAINTENANCE_BASE_PATH/android_stage.json';
    } else /*if (Platform.isIOS)*/ {
      maintenanceUrl = '$MAINTENANCE_BASE_PATH/ios_stage.json';
    }
    injector.map<String>((i) => 'https://dev-jasrac.live812.works/', key: Consts.KEY_JASRAC_URL);
    injector.map<String>((i) => maintenanceUrl, key: Consts.KEY_MAINTENANCE_URL);
    injector.map<String>((i) => 'https://dev-event.live812.works/', key: Consts.KEY_LIVE_EVENT_URL);
    injector.map<String>((i) => 'https://asset.live812.works/gift_dev', key: Consts.KEY_GIFT_URL);

    injector.map<String>((i) => Consts.ADJUST_APP_TOKEN_DEV, key: Consts.KEY_ADJUST_APP_TOKEN);
    injector.map<String>((i) => Consts.ADJUST_EVENT_PURCHASE_COIN_DEV, key: Consts.KEY_ADJUST_EVENT_PURCHASE_COIN);
    injector.map<String>((i) => Consts.ADJUST_EVENT_PURCHASE_COIN_UNIQUE_DEV, key: Consts.KEY_ADJUST_EVENT_PURCHASE_COIN_UNIQUE);
    injector.map<String>((i) => Consts.ADJUST_EVENT_PURCHASE_EC_ITEM_DEV, key: Consts.KEY_ADJUST_EVENT_PURCHASE_EC_ITEM);
    injector.map<String>((i) => Consts.ADJUST_EVENT_PURCHASE_EC_ITEM_UNIQUE_DEV, key: Consts.KEY_ADJUST_EVENT_PURCHASE_EC_ITEM_UNIQUE);
  }

  injector.map<EventLoggerRepository>((i) => _createAdjustRepo(), isSingleton: true );
  injector.map<PersistentRepository>((i) => SqlitePersistentRepository(), isSingleton: true );
  injector.map<NetworkRepository>((i) => HttpNetworkRepository(), isSingleton: true );
  injector.mapWithParams<UserModel>((i, params) => Provider.of<UserModel>(params['context'], listen: false));
}

AdjustEventLoggerRepository _createAdjustRepo() {
  final adjustRepo = AdjustEventLoggerRepository();
  adjustRepo.startAdjust();
  return adjustRepo;
}
