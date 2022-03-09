class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 45.0;

  static const int MAX_NICKNAME_LENGTH = 16;
  static const int MIN_SYMBOL_LENGTH = 6;
  static const int MAX_SYMBOL_LENGTH = 12;
  static const int MIN_PASSWORD_LENGTH = 8;
  static const int MAX_PASSWORD_LENGTH = 12;
  static const int MAX_PROFILE_LENGTH = 300;

  /// 発送予定(最小).
  static const int MIN_SHIPPING_DAY = 1;

  /// 発送予定(最大).
  static const int MAX_SHIPPING_DAY = 30;

  /// 登録できる配送先の最大数.
  static const int MAX_DELIVERY_ADDRESS = 10;

  static const int MAX_CHAT_MESSAGE_LENGTH = 50;

  static const int PROFILE_IMAGE_WIDTH = 512;

  static const int TIMELINE_IMAGE_WIDTH = 512;

  static const int PRODUCT_MAX_PHOTOS = 5; // 商品に添付できる写真の最大枚数
  static const int PRODUCT_IMAGE_WIDTH = 512;
  static const int PRODUCT_MAX_NAME_LENGTH = 50;
  static const int PRODUCT_MAX_DESCRIPTION_LENGTH = 1000;

  /// ライブ配信中に表示する商品の数.
  static const int PRODUCT_LIVE_VIEW_MAX_LENGTH = 30;

  /// ストアプロフィールの最大数.
  static const int STORE_PROFILE_MAX_LENGTH = 30;

  /// ストアプロフィールのタイトルの最大文字数.
  static const int STORE_PROFILE_MAX_TITLE_LENGTH = 50;

  /// ストアプロフィールの説明の最大文字数.
  static const int STORE_PROFILE_MAX_DESCRIPTION_LENGTH = 1000;

  static const int CONTACT_IMAGE_WIDTH = 512; // お問い合わせで送信する画像サイズ

  static const int MAX_LIKE_PARTICLE = 256;

  //AGORAのデフォルトConfig
  static const int AGORA_LIVE_WIDTH = 1120;
  static const int AGORA_LIVE_HEIGHT = 630;
  static const int AGORA_LIVE_FRAMERATE = 30;
  static const int AGORA_LIVE_BITRATE = 2760;

  // タイムアウト時間（秒）
  static const TIME_OUT = 10;
  static const TIME_OUT_IAP = 30;

  // ロード中のプレースホルダー用画像パス
  static const String LOADING_PLACE_HOLDER_IMAGE = 'assets/anim/square.png';

  // 出金可能な最低金額
  static const int WITHDRAW_AVAILABLE_MINIMUM_AMOUNT = 10000;

  // IAP
  static const List<String> IAP_ITEM_NAMES_IOS = [
    'coin2_180',
    'coin2_755',
    'coin2_1672',
    'coin2_4682',
    'coin2_7731',
    'coin2_15500',
    'coin2_47424',
    'coin2_78186',
    'coin2_157684'
  ];
  static const List<String> IAP_ITEM_NAMES_ANDROID = [
    'coin2_180',
    'coin2_755',
    'coin2_1672',
    'coin2_4682',
    'coin2_7731',
    'coin2_15500',
    'coin2_31100',
    'coin2_46800',
    'coin2_75360'
  ];

  // Agora
  static const AGORA_APP_ID = 'dbc1eb22d5ca43b4bba036fe5fb5b145';

  static const int SE_MIXING_VOLUME_PERCENT = 50; // 効果音のミキシングボリューム [%]

  // ストア情報
  static const String ANDROID_APP_ID = 'works.live812.app';
  static const String IOS_APP_ID = '1496553517';

  // Adjustアプリトークン
  static const String ADJUST_APP_TOKEN = 'bcqqlcoeg4xs';
  static const String ADJUST_APP_TOKEN_DEV = 'ythkti261khs';

  static const String ADJUST_EVENT_PURCHASE_COIN = 'bwgo71';
  static const String ADJUST_EVENT_PURCHASE_COIN_UNIQUE = '8zwlf9';
  static const String ADJUST_EVENT_PURCHASE_COIN_DEV = 'o06hd1';
  static const String ADJUST_EVENT_PURCHASE_COIN_UNIQUE_DEV = '1lghdg';

  static const String ADJUST_EVENT_PURCHASE_EC_ITEM = 'm7xmn5';
  static const String ADJUST_EVENT_PURCHASE_EC_ITEM_UNIQUE = 'ch1vbe';
  static const String ADJUST_EVENT_PURCHASE_EC_ITEM_DEV = 'rmpaq4';
  static const String ADJUST_EVENT_PURCHASE_EC_ITEM_UNIQUE_DEV = 'k0i9jg';

  // Injector用
  static const String KEY_DOMAIN = 'domain';
  static const String KEY_SOCKET_URL = 'socketUrl';
  static const String KEY_JASRAC_URL = 'jasracUrl';
  static const String KEY_MAINTENANCE_URL = 'maintenanceIosUrl';
  static const String KEY_LIVE_EVENT_URL = 'liveEventUrl';
  static const String KEY_GIFT_URL = 'giftUrl';
  static const String KEY_ADJUST_APP_TOKEN = 'adjustAppToken';
  static const String KEY_ADJUST_EVENT_PURCHASE_COIN =
      'adjustEventPurchaseCoin';
  static const String KEY_ADJUST_EVENT_PURCHASE_COIN_UNIQUE =
      'adjustEventPurchaseCoinUnique';
  static const String KEY_ADJUST_EVENT_PURCHASE_EC_ITEM =
      'adjustEventPurchaseEcItem';
  static const String KEY_ADJUST_EVENT_PURCHASE_EC_ITEM_UNIQUE =
      'adjustEventPurchaseEcItemUnique';
}
