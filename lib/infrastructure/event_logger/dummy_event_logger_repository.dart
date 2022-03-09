import 'package:flutter/foundation.dart';
import 'package:live812/domain/repository/event_logger_repository.dart';

class DummyEventLoggerRepository implements EventLoggerRepository {
  // コインをアプリ内購入
  @override
  void sendPurchaseCoinEvent(num price, {String currency = EventLoggerRepository.CURRENCY}) {
    debugPrint('sendPurchaseCoinEvent: price=$price, currency=$currency');
  }

  // EC商品購入
  @override
  void sendPurchaseEcItemEvent(num price, {String currency = EventLoggerRepository.CURRENCY}) {
    debugPrint('sendPurchaseEcItemEvent: price=$price, currency=$currency');
  }
}
