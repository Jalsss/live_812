abstract class EventLoggerRepository {
  static const String CURRENCY = 'JPY';  // 日本円

  // コインをアプリ内購入
  void sendPurchaseCoinEvent(num price, {String currency = CURRENCY});

  // EC商品購入
  void sendPurchaseEcItemEvent(num price, {String currency = CURRENCY});
}
