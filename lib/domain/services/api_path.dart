// APIのパス定義
class ApiPath {
  ApiPath._();

  static const my = '/my';
  static const myRequest = '/my/request';
  static const mypage = '/mypage';
  static const user = '/user';
  static const iconBadge = '/badge/user';
  static const login = '/login';
  static const signup = '/signup';
  static const passwordReset = '/password/reset';
  static const liverCategory = '/liver/category';
  static const streamingLiveRoom = '/streaming/live/room';
  static const streamingLiveRoomCounts = '/streaming/live/room/counts';
  static const streamingLiveRoomBroadcasting = '/streaming/live/room/broadcasting';
  static const streamingLiveBroadcast = '/streaming/live/broadcast';
  static const streamingLiveStart = '/streaming/live/start';
  static const streamingLiveStop = '/streaming/live/stop';

  static const roomGift = '/room/gift';

  static const point = '/point';
  static const pointHistory = '/point/history';
  static const pointWithdraw = '/point/withdraw';
  static const timeline = '/timeline';
  static const timelineLike = '/timeline/like';
  static const timelineMessage = '/timeline/message';
  static const userFollow = '/user/follow';
  static const userFollower = '/user/follower';
  static const userDeliveryAddress = '/user/delivery_address';
  static const code = '/code';
  static const live_category = 'liver/category';
  static const pointAdd = '/point/add';
  static const ReceiptVerifyIos = '/receipt/verify/ios';
  static const ReceiptVerifyAndroid = '/receipt/verify/android';
  static const liveUsers = '/live/users';
  static const blockListener = '/block/listener';

  static const rankList = '/rank/list';
  static const rankLiverPoint = '/rank/liver/point';
  static const rankLiverGift = '/rank/liver/gift';
  static const rankLiverGiftMonthly = '/rank/liver/gift/point/monthly';
  static const rankLiverPerson = '/rank/liver/person';
  static const rankFun = '/rank/fun';
  static const rankLiveGift = '/rank/live/gift';
  static const rankLiveGiftMonthly = '/rank/live/gift/monthly';
  static const unregist = '/unregist';
  static const deliveryProvider = '/delivery/provider';
  static const rank = '/rank';
  static const info = '/info';
  static const infoEc = '/info/ec';
  static const infoEcRead = '/info/ec/read';

  static const ecItem = '/ec/item';
  static const ecItemPurchased = '/ec/item/purchased';
  static const ecItemSales = '/ec/item/sales';
  static const ecItemCompleted = '/ec/item/completed';
  static const ecItemInvisiblePurchased = '/ec/item/invisible_purchased';
  static const products = '/ec/item/all';
  static const ecPurchase = '/ec/purchase';
  static const ecOrderHistory = '/ec/order/history';
  static const ecCancel = '/ec/cancel';
  static const ecPurchaseDelivery = '/ec/purchase/delivery';
  static const ecStoreProfile = '/ec/store_profile';
  static const receiveItem = '/receive/item';
  static const ecTemplate = '/ec/template';
  static const ecItemFromTemplate = '/ec/item/from_template';
  static const ecItemChat = '/ec/item/chat';

  static const bankBilling = '/bank/billing';
  static const bankBillingInfo = '/bank/billing/info';

  static const creditBilling = '/credit/billing';
  static const creditResult = '/credit/result';

  static const benefitLog = '/benefit/log';

  static const inquiry = '/inquiry';
  static const jasrac = '/jasrac';
  static const webToken = '/web/token';

  static const notificationCheck = '/notification/check';
  static const notificationInfo = '/notification/info';

  static const eventListPlaned = '/event/list/planed';
  static const eventListLive = '/event/list/live';
  static const eventListFinished = '/event/list/finished';
  static const eventListInvited = '/event/list/invited';
  static String eventOverView(String id) => '/event/$id';
  static String eventPrize(String id) => '/event/$id/prize';
  static String eventMember(String id) => '/event/$id/member';
  static String eventRanking(String id) => '/event/$id/ranking';
  static const eventEntry = '/event/entry';
  static const eventFollow = '/event/follow';
}
