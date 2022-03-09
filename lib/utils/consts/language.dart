import 'package:live812/utils/consts/consts.dart';

class Lang {
  Lang._();

  static const String APP_NAME = "Live812";
  static const String CHANGE = "変更する";
  static const String OPEN_MENU = "メニューを開く";
  static const String END = "終了";
  static const String CLOSE = "とじる";
  static const String CLOSE_CC = "閉じる";
  static const String CANCEL = "キャンセル";
  static const String FINISH = "終了する";
  static const String DO_SEND = "送信する";
  static const String SEND = "送信";
  static const String PUBLISH = "公開する";
  static const String DO_EDIT = "編集する";
  static const String DECIDE = "決定";
  static const String ADD = "追加";

  static const String REPLY = "返信";
  static const String MORE = "もっと見る";
  static const String DELETE = "削除する";
  static const String BACK = "戻る";

  static const String EDIT = "編集";
  static const String SUSPEND = "削除";

  static const String ERROR = "エラー";
  static const String RETRY = "リトライ";

  static const String NO_IMAGE = "No Image";
  static const String COPIED = "コピーしました";

  static const String UPDATE = "アップデート";

  //-------------- Message -------------------
  static const String MESSAGE_END_STREAMING = "ライブ配信を終了しますか？";
  static const String MESSAGE_LOGOUT = "ログアウトしますか？";
  static const String MESSAGE_QUIT_SERVICE = "すべてのデータが消去されます。\n本当に退会しますか？";
  static const String MESSAGE_QUIT_SERVICE_LIVER =
      "【ご注意】\n退会するとMyOffice812にログインできなくなり、報酬の支払いも行われません。";
  static const String MESSAGE_CONFIRM_QUIT_SERVICE =
      "退会は、取り消すことができません。\n本当によろしいですか？";
  static const String UPDATE_REQUIRED_MESSAGE =
      '最新版のアプリがリリースされました。\nアプリをアップデートしてください。';

  //---------------- valid message ----------------
  static const String ENTER_EMAIL = "有効なメールアドレスを入力してください";
  static const String ENTER_TEXT = "入力してください";
  static const String ENTER_NICKNAME = "ニックネームは３文字以上にしてください";
  static const String ENTER_PASSWORD =
      "半角英数小文字${Consts.MIN_PASSWORD_LENGTH}〜${Consts.MAX_PASSWORD_LENGTH}文字です";
  static const String PASSWORD_NOT_MATCHING = "パスワードが合いません";
  static const String REQUIRED = "必須項目です";
  static const String NUMBER_REQUIRED = "数値を入力してください";
  static const String SHIPPING_REQUIRED =
      "${Consts.MIN_SHIPPING_DAY}〜${Consts.MAX_SHIPPING_DAY}日までです";
  static const String PRICE_REQUIRED = "価格を入力してください";
  static const String ONE_OR_MORE_PICTURE_REQUIRED = "画像を１枚以上添付してください";
  static const String CHAT_MESSAGE_TOO_LONG =
      "メッセージは${Consts.MAX_CHAT_MESSAGE_LENGTH}文字以内です";
  static const String PHONE_NUMBER_REQUIRED = "電話番号を入力してください";

  static const String SKIP = "スキップ";
  static const String FAVORITE_CHOOSE_DESC = "最低1つ以上を選択してください";

  //------------- Pin Screen ----------------
  static const String pinSubTitle = "メールに認証コードを送信しました";
  static const String pinBottomText = "PINコード10回エラーで再発行\n再発行ボタンをつけた画面も必要";
  static const String pinRequired = "認証コード *";
  static const String pinNoReceive = "認証コードが届かない方は";
  static const String pinDialogMessageText1 =
      "お使いのメールアドレス、メールソフト、ウィルス対策ソフト等の設定により「迷惑メール」と認識され、メールが届かない場合があります。その場合は「迷惑メールフォルダー」等をご確認いただくかお使いのサービス、ソフトウェアの設定をご確認ください。";
  static const String pinDialogMessageText2 =
      "また、それでもメールが届かない場合は、ドメイン指定受信で「@live812.works」を許可するように設定してください。";

  //------------------- Search ------------
  static const String SEARCH = "検索";
  static const String SEARCH_HINT = "ニックネーム、ユーザーIDで検索";

  //-------------- hint -----------------------------
  static const String HINT_INPUT = "入力してください";
  static const String HINT_CONTACT = "お問い合わせの内容を記入してください";
  static const String HINT_NEW_NICKNAME = "新しいニックネームを入力してください";
  static const String HINT_NEW_EMAIL = "新しいメールアドレスを入力してください";
  static const String HINT_CURRENT_PASSWORD = "現在のパスワードを入力してください";
  static const String HINT_NEW_PASSWORD = "新しいパスワードを入力してください";
  static const String HINT_NEW_PASSWORD2 = "新しいパスワードを再度入力してください";
  static const String HINT_PRODUCT_TEMPLATE_NAME =
      "テンプレート名（${Consts.PRODUCT_MAX_NAME_LENGTH}文字以内）";
  static const String HINT_PRODUCT_NAME =
      "商品名（${Consts.PRODUCT_MAX_NAME_LENGTH}文字以内）";
  static const String HINT_PRODUCT_DESCR =
      "商品の説明（${Consts.PRODUCT_MAX_DESCRIPTION_LENGTH}文字以内）\n例文：手作りピアスです。手作りなので世界に１つのオリジナルになってます。素材に〇〇を使用していますので、金属アレルギーがある方は、ご注文をお控えください。価格は送料込みの記載です。配送方法はゆうパックにて配送いたします。";
  static const String HINT_PRODUCT_NOTE =
      "※アレルギー表記（特定原材料、特定原材料に準ずるもの、素材）、サイズなどがあれば必ず記入して下さい。";
  static const String HINT_TIMELINE = "タイムラインに投稿";
  static const String HINT_TIMELINE_COMMENT = "コメントする";
  static const String HINT_HASH_TAG = "ハッシュタグ（10文字まで）";
  static const String HINT_PRODUCT_PURCHASE =
      "お客様情報は、入力後変更は出来かねますので、\n必ずご確認をお願いします。";
  static const String HINT_STORE_PROFILE_TITLE =
      "タイトル（${Consts.STORE_PROFILE_MAX_TITLE_LENGTH}文字以内）";
  static const String HINT_STORE_PROFILE_DESCRIPTION =
      "説明（${Consts.STORE_PROFILE_MAX_DESCRIPTION_LENGTH}文字以内）\nストアに掲載する内容を記入してください";

  //-------------------- Live -----------
  static const String GIFT = "ギフト";
  static const String HEART = "いいね";
  static const String CHAT = "メッセージ";
  static const String SOUND_EFFECT = "効果音";
  static const String BEAUTIFY_OPTION = '美顔設定';
  static const String BEAUTIFY_EFFECT_ON = "美肌 ON";
  static const String BEAUTIFY_EFFECT_OFF = "美肌 OFF";
  static const String PRODUCT_SALES = "商品販売";
  static const String CAMERA_SWITCH = "カメラ切替";
  static const String CAMERA_ON = "カメラ ON";
  static const String CAMERA_OFF = "カメラ OFF";
  static const String UNMUTE = "ミュート解除";
  static const String MUTE = "ミュート";
  static const String PRODUCT_LIST = "商品一覧";
  static const String AUDIENCE = "視聴者";
  static const String SHARE = "シェア";
  static const String BACK_MENU = "メニューへ戻る";
  static const String CHAT_HINT = "ライバーに声をかけてみよう";
  static const String CHAT_HINT_LIVER = "視聴者に声をかけてみよう";
  static const String FOLLOW = "フォロー";
  static const String THIS_DEL = "この配信";
  static const String THIS_MONTH = "今月";
  static const String THIS_MONTH_LIVE_TIME = "今月配信時間合計";
  static const String THIS_MONTH_GIFT_POINT = "今月獲得ギフト";
  static const String BALANCE = "残高";
  static const String PURCHASE = "購入する";
  static const String CREDIT_CARD_PAYMENT = "クレジットカード決済";
  static const String PURCHASE_BANK_TRANS = "銀行振込で購入";
  static const String TO_PURCHASE_HISTORY = "購入履歴へ";
  static const String THANK_YOU = "ありがとうございます！";
  static const String START_LIVE = "配信を開始する";
  static const String PREVIEW_LIVE = "配信プレビューへ";
  static const String LIVE_BROADCAST = "ライブ配信";
  static const String POINT_DEFICIT = "不足";
  static const String INCLUDING_POSTAGE = "(送料込み)";

  //-------------------- Login Screen -----------
  static const String SIGNUP = "新規登録";
  static const String LOGIN = "ログイン";

  //-------------------- My Page ----------------
  static const String COIN = "コイン";
  static const String YEN = "円";
  static const String HOURS = "時間";
  static const String MINUTES = "分";
  static const String HISTORY = "履歴";
  static const String CHARGE = "チャージ";
  static const String FOLLOWING = "フォロー中";
  static const String FOLLOWER = "フォロワー";
  static const String STORE = "ストア";
  static const String EXHIBIT = "出品";
  static const String EXHIBITING = "出品中";
  static const String DRAFTS = "下書き";
  static const String TRADING = "取引中";
  static const String BUYING = "購入";
  static const String TEMPLATES = "テンプレート";
  static const String NEW_REGISTRATION = "新規登録";
  static const String PURCHASE_HISTORY = "購入履歴";
  static const String PURCHASE_HISTORY_LIVER = "販売履歴";
  static const String STORE_PROFILE = "ストアプロフィール";
  static const String PRODUCT_SALE_LIST = "出品中の商品";
  static const String PRODUCT_DRAFT_LIST = "下書き中の商品";
  static const String HELP_HOWUSE = "ヘルプ・使い方";
  static const String QUESTION_AND_ANSWER = 'Q&A';
  static const String SETTING = "設定";
  static const String FOLLOWING1 = "フォローする";
  static const String FANRANK = "ファンランク";
  static const String RANKING = "ランキング";
  static const String TOP100 = "トップ100";
  static const String LIVE_THIS = "この配信";
  static const String LIVE_MONTHLY = "今月";
  static const String PRODUCT_DET = "商品詳細";
  static const String PROFILE = "プロフィール";
  static const String NOTICE = "お知らせ";
  static const String EARNING_CHARGING = "獲得/チャージ履歴";
  static const String USAGE_HIS = "使用履歴";
  static const String PURCHASE_CANCEL = "取引をキャンセルする";
  static const String COIN_MESSAGE = "を本当に購入しますか？";
  static const String WITHDRAW_AMOUNT = "出金可能額";
  static const String DO_WITHDRAW = "出金する";
  static const String WITHDRAW_ESTIMATE_AMOUNT = "振込予定額";
  static const String NOTIFICATION_ON = "通知ON";
  static const String NOTIFICATION_OFF = "通知OFF";

  static const String BLOCK = "ブロック";
  static const String RELEASE_BLOCK = "ブロックを解除";

  //-------------------- Payment -----------
  static const String PAYMENT_SUCCESS = "決済成功";
  static const String PAYMENT_FAILED = "決済失敗";

  //--------------------- Settings -----------
  static const String REFER_FRIEND = "友達に紹介";
  static const String LOGOUT = "ログアウト";
  static const String QUIT_SERVICE = "退会";
  static const String DO_QUIT_SERVICE = "退会する";
  static const String TERMS = "利用規約";
  static const String COMMERCIAL = "特定商取引法に基づく表記";
  static const String ADDRESS_TITLE = "配送先設定";
  static const String ADDRESS_BODY = "配送先情報を指定しておくと、商品購入時に都度配送先を入力せずに購入でき便利です。";
  static const String CONTACT = "お問い合わせ";
  static const String LIVE_COMMERCE_TERMS_AND_CONDITION_TITLE = "ライブコマース利用規約";
  static const String MERCHANT_TERMS_TITLE = "加盟店規約";
  static const String LIST_OF_PROHIBITED_ITEMS_TITLE = "出品物ガイドライン";
  static const String PRIVACY_POLICY_TITLE = "プライバシーポリシー";

  //-------------------- Product ------------
  static const String ADD_NEW_PRODUCT = "新規商品登録";
  static const String EDIT_PRODUCT = "商品編集";
  //-------------------- Timeline ------------
  static const String EDIT_TIMELINE = "投稿を編集";
  static const String DO_POST = "投稿する";

  //-------------------- Share ------------
  static const String SHARE_TEXT = 'ライブ配信アプリ「LIVE812」をいますぐダウンロードしよう！';
  static const String SHARE_URL = 'https://share.live812.works/';
  // マイページ＞友達に紹介からシェアする場合
  static const String SHARE_LIVER_TO_FRIEND =
      'LIVE812でライブ配信しています♪アプリをダウンロードしてフォローしてね！';
  // 配信前画面からシェアする場合
  static const String SHARE_LIVER_BROADCAST =
      'LIVE812でライブ配信中♪アプリをダウンロードしてフォローしてね！';

  //-------------------- 振込申請 -----------
  static const String WITHDRAW_REQUEST = '振込申請';

  //-------------- Error message -------------------
  static const String ERROR_WRONG_MAIL_OR_PASSWORD = 'メールアドレスまたはパスワードに誤りがあります';
  static const String ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER =
      '通信エラーが発生しました。電波をご確認の上、時間をおいて再度お試しください';
  static const String ERROR_COIN_INFO_FAILED_TRY_AGAIN_AFTER =
      'コイン情報の取得に失敗しました。電波をご確認の上、時間をおいて再度お試しください';
  static const String ERROR_NO_PRODUCTS = '出品中の商品はありません';
  static const String ERROR_NO_DRAFT = '下書き中の商品はありません';
  static const String ERROR_NO_SELLING_HISTORY = '販売履歴はありません';
  static const String ERROR_NO_PURCHASE_HISTORY = '購入履歴はありません';
  static const String ERROR_NO_PRODUCT_TEMPLATES = 'テンプレートはありません';
  static const String ERROR_NETWORK_TIME_OUT =
      '通信がタイムアウトしました。電波状態をご確認の上、再度お試しください。';
}
