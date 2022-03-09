import 'dart:io';

import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:adjust_sdk/adjust_event_failure.dart';
import 'package:adjust_sdk/adjust_event_success.dart';
import 'package:adjust_sdk/adjust_session_failure.dart';
import 'package:adjust_sdk/adjust_session_success.dart';
import 'package:adjust_sdk/adjust_event.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/repository/event_logger_repository.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/domain/build_type.dart';

class AdjustEventLoggerRepository implements EventLoggerRepository {
  //static const String EVENT_TOKEN_SIMPLE = '';
  //static const String EVENT_TOKEN_CALLBACK = '';
  //static const String EVENT_TOKEN_PARTNER = '';
  static const String CURRENCY = 'JPY';  // 日本円

  void startAdjust() async {
    String appToken = Injector.getInjector().get<String>(key: Consts.KEY_ADJUST_APP_TOKEN);
    AdjustConfig config = new AdjustConfig(appToken, AdjustEnvironment.production);

    final buildType = Injector.getInjector().get<BuildType>();
    config.logLevel = buildType == BuildType.Debug ? AdjustLogLevel.verbose :  AdjustLogLevel.suppress;
    config.isDeviceKnown = false;

    if (buildType == BuildType.Debug) {
      // 現状ログ出力しかしてないようなので、開発版でだけ設定
      config.attributionCallback = (AdjustAttribution attributionChangedData) {
        print('[Adjust]: Attribution changed!');

        if (attributionChangedData.trackerToken != null) {
          print('[Adjust]: Tracker token: ' + attributionChangedData.trackerToken);
        }
        if (attributionChangedData.trackerName != null) {
          print('[Adjust]: Tracker name: ' + attributionChangedData.trackerName);
        }
        if (attributionChangedData.campaign != null) {
          print('[Adjust]: Campaign: ' + attributionChangedData.campaign);
        }
        if (attributionChangedData.network != null) {
          print('[Adjust]: Network: ' + attributionChangedData.network);
        }
        if (attributionChangedData.creative != null) {
          print('[Adjust]: Creative: ' + attributionChangedData.creative);
        }
        if (attributionChangedData.adgroup != null) {
          print('[Adjust]: Adgroup: ' + attributionChangedData.adgroup);
        }
        if (attributionChangedData.clickLabel != null) {
          print('[Adjust]: Click label: ' + attributionChangedData.clickLabel);
        }
        if (attributionChangedData.adid != null) {
          print('[Adjust]: Adid: ' + attributionChangedData.adid);
        }
      };

      // session establish success
      config.sessionSuccessCallback = (AdjustSessionSuccess sessionSuccessData) {
        print('[Adjust]: Session tracking success!');

        if (sessionSuccessData.message != null) {
          print('[Adjust]: Message: ' + sessionSuccessData.message);
        }
        if (sessionSuccessData.timestamp != null) {
          print('[Adjust]: Timestamp: ' + sessionSuccessData.timestamp);
        }
        if (sessionSuccessData.adid != null) {
          print('[Adjust]: Adid: ' + sessionSuccessData.adid);
        }
        if (sessionSuccessData.jsonResponse != null) {
          print('[Adjust]: JSON response: ' + sessionSuccessData.jsonResponse);
        }
      };

      // session establish failure
      config.sessionFailureCallback = (AdjustSessionFailure sessionFailureData) {
        print('[Adjust]: Session tracking failure!');

        if (sessionFailureData.message != null) {
          print('[Adjust]: Message: ' + sessionFailureData.message);
        }
        if (sessionFailureData.timestamp != null) {
          print('[Adjust]: Timestamp: ' + sessionFailureData.timestamp);
        }
        if (sessionFailureData.adid != null) {
          print('[Adjust]: Adid: ' + sessionFailureData.adid);
        }
        if (sessionFailureData.willRetry != null) {
          print('[Adjust]: Will retry: ' + sessionFailureData.willRetry.toString());
        }
        if (sessionFailureData.jsonResponse != null) {
          print('[Adjust]: JSON response: ' + sessionFailureData.jsonResponse);
        }
      };

      // event send success
      config.eventSuccessCallback = (AdjustEventSuccess eventSuccessData) {
        print('[Adjust]: Event tracking success!');

        if (eventSuccessData.eventToken != null) {
          print('[Adjust]: Event token: ' + eventSuccessData.eventToken);
        }
        if (eventSuccessData.message != null) {
          print('[Adjust]: Message: ' + eventSuccessData.message);
        }
        if (eventSuccessData.timestamp != null) {
          print('[Adjust]: Timestamp: ' + eventSuccessData.timestamp);
        }
        if (eventSuccessData.adid != null) {
          print('[Adjust]: Adid: ' + eventSuccessData.adid);
        }
        if (eventSuccessData.callbackId != null) {
          print('[Adjust]: Callback ID: ' + eventSuccessData.callbackId);
        }
        if (eventSuccessData.jsonResponse != null) {
          print('[Adjust]: JSON response: ' + eventSuccessData.jsonResponse);
        }
      };

      // event send failure
      config.eventFailureCallback = (AdjustEventFailure eventFailureData) {
        print('[Adjust]: Event tracking failure!');

        if (eventFailureData.eventToken != null) {
          print('[Adjust]: Event token: ' + eventFailureData.eventToken);
        }
        if (eventFailureData.message != null) {
          print('[Adjust]: Message: ' + eventFailureData.message);
        }
        if (eventFailureData.timestamp != null) {
          print('[Adjust]: Timestamp: ' + eventFailureData.timestamp);
        }
        if (eventFailureData.adid != null) {
          print('[Adjust]: Adid: ' + eventFailureData.adid);
        }
        if (eventFailureData.callbackId != null) {
          print('[Adjust]: Callback ID: ' + eventFailureData.callbackId);
        }
        if (eventFailureData.willRetry != null) {
          print('[Adjust]: Will retry: ' + eventFailureData.willRetry.toString());
        }
        if (eventFailureData.jsonResponse != null) {
          print('[Adjust]: JSON response: ' + eventFailureData.jsonResponse);
        }
      };
    }

    // Start SDK.
    if (Platform.isIOS) {
      if ((await Adjust.getAppTrackingAuthorizationStatus()) == 0) {
        // NotDetermined.
        await Adjust.requestTrackingAuthorizationWithCompletionHandler();
      }
    }
    Adjust.start(config);
  }

  //void sendSimpleEvent() {
  //  AdjustEvent adjustEvent = new AdjustEvent(EVENT_TOKEN_SIMPLE);
  //  Adjust.trackEvent(adjustEvent);
  //}

  // コインをアプリ内購入
  @override
  void sendPurchaseCoinEvent(num price, {String currency = CURRENCY}) {
    String eventToken = Injector.getInjector().get<String>(key: Consts.KEY_ADJUST_EVENT_PURCHASE_COIN);
    AdjustEvent adjustEvent = new AdjustEvent(eventToken);
    adjustEvent.setRevenue(price, currency);
    Adjust.trackEvent(adjustEvent);

    eventToken = Injector.getInjector().get<String>(key: Consts.KEY_ADJUST_EVENT_PURCHASE_COIN_UNIQUE);
    adjustEvent = new AdjustEvent(eventToken);
    adjustEvent.setRevenue(price, currency);
    Adjust.trackEvent(adjustEvent);
  }

  // EC商品購入
  @override
  void sendPurchaseEcItemEvent(num price, {String currency = CURRENCY}) {
    String eventToken = Injector.getInjector().get<String>(key: Consts.KEY_ADJUST_EVENT_PURCHASE_EC_ITEM);
    AdjustEvent adjustEvent = new AdjustEvent(eventToken);
    adjustEvent.setRevenue(price, currency);
    Adjust.trackEvent(adjustEvent);

    eventToken = Injector.getInjector().get<String>(key: Consts.KEY_ADJUST_EVENT_PURCHASE_EC_ITEM_UNIQUE);
    adjustEvent = new AdjustEvent(eventToken);
    adjustEvent.setRevenue(price, currency);
    Adjust.trackEvent(adjustEvent);
  }

  //void sendCallbackEvent(String key, String value) {
  //  AdjustEvent adjustEvent = new AdjustEvent(EVENT_TOKEN_CALLBACK);
  //  adjustEvent.addCallbackParameter(key, value);
  //  Adjust.trackEvent(adjustEvent);
  //}

  //void sendPartnerEvent(String key, String value) {
  //  AdjustEvent adjustEvent = new AdjustEvent(EVENT_TOKEN_PARTNER);
  //  adjustEvent.addPartnerParameter(key, value);
  //  Adjust.trackEvent(adjustEvent);
  //}
}
