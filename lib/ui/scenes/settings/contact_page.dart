import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live812/domain/model/user/inquiry.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/image_util.dart';
import 'package:live812/utils/super_text_util.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/url_text_span.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

const MARGIN_HORZ = 15.0;

const List<String> _deviceTypes = ['iOS', 'Android'];

enum _ContactType {
  GENERAL_SERVICE, // サービス全般
  COMMODITY_TRADING, //　商品取引
  REQUEST_REFUNDS, // 返金
  COIN_CHARGE, //　コインチャージ
  LIVER_REGISTRATION, // ライバー登録
  APP_FAILURE, // アプリの不具合
  TROUBLE, // トラブル
  OTHER, // その他
}

const List<_ContactType> _contactTypes = [
  _ContactType.GENERAL_SERVICE,
  _ContactType.COMMODITY_TRADING,
  _ContactType.REQUEST_REFUNDS,
  _ContactType.LIVER_REGISTRATION,
  _ContactType.APP_FAILURE,
  _ContactType.COIN_CHARGE,
  _ContactType.TROUBLE,
  _ContactType.OTHER,
];

const Map<_ContactType, String> _contactTypeText = {
  _ContactType.GENERAL_SERVICE: 'サービス全般に関するお問い合わせ',
  _ContactType.COMMODITY_TRADING: '商品取引に関するお問い合わせ',
  _ContactType.REQUEST_REFUNDS: '返金処理に関するお問い合わせ',
  _ContactType.LIVER_REGISTRATION: 'ライバー登録に関するお問い合わせ',
  _ContactType.APP_FAILURE: 'アプリの不具合に関するご報告',
  _ContactType.COIN_CHARGE: 'コインチャージに関するお問い合わせ',
  _ContactType.TROUBLE: 'トラブルなどに関する報告・通報',
  _ContactType.OTHER: 'その他に関するお問い合わせ',
};

class ContactPage extends StatefulWidget {
  @override
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _mainTextController = TextEditingController();
  TextEditingController _osVersionController = TextEditingController();
  TextEditingController _appVersionController = TextEditingController();
  TextEditingController _symbolController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _tradingIdController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  _ContactType _contactType;
  String _deviceType = Platform.isIOS ? _deviceTypes[0] : _deviceTypes[1];
  bool _autoValidate = false;
  bool _isLoading = false;
  bool _isSendSuccess = false;
  List<Widget> _widgetTree;

  //File _image;
  SwiperController _swipeController = SwiperController();
  List<File> _images = List();

  String requestRefundsText = '''■取引ID

■銀行名

■支店名

■口座種類

■口座番号

■口座名義
''';
  String appFailureText = '''
■不具合の内容をできるだけ詳しくご記入ください

■発生日時

■発生頻度(毎回、時々、一度だけなど)

■ライバー名（配信を見ていた場合）

■端末機種名

※不具合が発生している画面のスクリーンショットを、下の「画像を添付」から添付してください''';

  @override
  void dispose() {
    _mainTextController.dispose();
    _osVersionController.dispose();
    _appVersionController.dispose();
    _symbolController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _tradingIdController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _getOsVersion().then((version) => setState(() {
          _osVersionController.text = version;
        }));
  }

  // お知らせの種類
  Widget _buildContactTypeDropdown() {
    return _putHorizontalMargin(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 30),
          _requiredText('お問い合わせ種類'),
          SizedBox(height: 10),
          _dropdownInput(
            items: _contactTypes,
            initialValue: _contactType,
            getText: (value) => value == null ? '' : _contactTypeText[value],
            validator: (value) => value != null ? null : Lang.REQUIRED,
            onChanged: (newValue) {
              _images.clear();
              setState(() {
                _contactType = newValue;
                _mainTextController?.text =
                    _contactType == _ContactType.REQUEST_REFUNDS
                        ? requestRefundsText
                        : (_contactType == _ContactType.APP_FAILURE ? appFailureText : _mainTextController?.text = "");
              });
            },
          ),
        ],
      ),
    );
  }

  // 端末の種類
  Widget _buildTerminalType() {
    return _putHorizontalMargin(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          _requiredText('端末の種類'),
          SizedBox(height: 10),
          _dropdownInput(
            items: _deviceTypes,
            initialValue: _deviceType,
            getText: (value) => value ?? '',
            validator: CustomValidator.validateRequired,
            onChanged: (String newValue) => setState(() {
              _deviceType = newValue;
            }),
          ),
        ],
      ),
    );
  }

  // OSのバージョン
  Widget _buildOsVersion() {
    return _putHorizontalMargin(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          _requiredText('OSバージョン'),
          SizedBox(height: 10),
          _inputTextField(
              controller: _osVersionController,
              validator: CustomValidator.validateRequired),
        ],
      ),
    );
  }

  // アプリのバージョン
  Widget _appVersion() {
    _addAppVersion();
    return _putHorizontalMargin(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          _requiredText('アプリバージョン'),
          SizedBox(height: 10),
          _inputTextField(
              controller: _appVersionController,
              validator: CustomValidator.validateRequired),
        ],
      ),
    );
  }

  // シンボル（ユーザーID）
  Widget _buildSymbol() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    _symbolController.text = userModel.symbol;
    return _putHorizontalMargin(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          _requiredText('ユーザーID'),
          SizedBox(height: 10),
          _inputTextField(
              controller: _symbolController,
              validator: CustomValidator.validateRequired),
        ],
      ),
    );
  }

  // 取引ID
  Widget _tradingId() {
    return _putHorizontalMargin(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          _requiredText('取引ID'),
          SizedBox(height: 10),
          _inputTextField(
              controller: _tradingIdController,
              validator: CustomValidator.validateRequired),
        ],
      ),
    );
  }

  // ニックネーム
  Widget _buildNickName() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    _nicknameController.text = userModel.nickname;
    return _putHorizontalMargin(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          _requiredText('ニックネーム'),
          SizedBox(height: 10),
          _inputTextField(
              controller: _nicknameController,
              validator: CustomValidator.validateRequired),
        ],
      ),
    );
  }

  // メールアドレス
  Widget _buildEmailAddress() {
    final userModel = Provider.of<UserModel>(context, listen: false);
    _emailController.text = userModel.emailAddress;
    return _putHorizontalMargin(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          _requiredText('メールアドレス'),
          SizedBox(height: 10),
          _inputTextField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: CustomValidator.validateRequired),
        ],
      ),
    );
  }

  // お問い合わせ内容
  Widget _buildContactOfInquiry() {
    return _putHorizontalMargin(
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          _multilineInputTextField(), // お問い合わせ内容
          SizedBox(height: 5),
        ],
      ),
    );
  }

  // 注意事項
  Widget _buildNotice() {
    String message;
    switch (_contactType) {
      case _ContactType.GENERAL_SERVICE:
        message = '''いただいたお問い合わせに関する回答は、３営業日程度お時間がかかる場合がございます。
また、内容によっては個別のお返事は差し上げておりません。
なお、お問い合わせは日本語のみとさせていただきます。

【お問い合わせ対応時間】
土日祝祭日を除く、10:00～18:00''';
        break;
      case _ContactType.COMMODITY_TRADING:
        message = '''いただいたお問い合わせに関する回答は、３営業日程度お時間がかかる場合がございます。
なお、お問い合わせは日本語のみとさせていただきます。

【お問い合わせ対応時間】
土日祝祭日を除く、10:00～18:00''';
        break;
      case _ContactType.COIN_CHARGE:
        message = '''いただいたお問い合わせに関する回答は、３営業日程度お時間がかかる場合がございます。
なお、お問い合わせは日本語のみとさせていただきます。

【お問い合わせ対応時間】
土日祝祭日を除く、10:00～18:00''';
        break;
      case _ContactType.LIVER_REGISTRATION:
        message = '''いただいたお問い合わせに関する回答は、３営業日程度お時間がかかる場合がございます。
また、内容によっては個別のお返事は差し上げておりません。
なお、お問い合わせは日本語のみとさせていただきます。

【お問い合わせ対応時間】
土日祝祭日を除く、10:00～18:00''';
        break;
      case _ContactType.APP_FAILURE:
        message = '''いただいたお問い合わせに関する回答は、３営業日程度お時間がかかる場合がございます。
また、内容によっては個別のお返事は差し上げておりません。
なお、お問い合わせは日本語のみとさせていただきます。

【お問い合わせ対応時間】
土日祝祭日を除く、10:00～18:00''';
        break;
      case _ContactType.TROUBLE:
        message = '''いただいたお問い合わせに関する回答は、３営業日程度お時間がかかる場合がございます。
また、内容によっては個別のお返事は差し上げておりません。
なお、お問い合わせは日本語のみとさせていただきます。

【お問い合わせ対応時間】
土日祝祭日を除く、10:00～18:00''';
        break;
      case _ContactType.OTHER:
      default:
        message = '''いただいたお問い合わせに関する回答は、３営業日程度お時間がかかる場合がございます。
また、内容によっては個別のお返事は差し上げておりません。
なお、お問い合わせは日本語のみとさせていただきます。

【お問い合わせ対応時間】
土日祝祭日を除く、10:00～18:00''';
        break;
    }

    final superText = SuperTextUtil.parse(message);

    return _putHorizontalMargin(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 15),
            child: Text(
              '－ ご注意事項 －',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: double.infinity,
            child: SuperTextWidget(superText),
          ),
        ],
      ),
    );
  }

  // 確認ボタン
  Widget _buildConfirmButtonArea() {
    return Column(
      children: <Widget>[
        SizedBox(height: 25),
        _confirmButton(),
        SizedBox(height: 90),
      ],
    );
  }

  // 送信後
  Widget _buildContactDone() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: <Widget>[
          SizedBox(height: 32),
          Center(
            child: Text(
              'お問い合わせが送信されました。\n\nご入力いただいたメールアドレス宛に確認用メールをお送りしましたのでご確認ください。',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 48),
          Center(
            child: Container(
              height: 40,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  //end: Alignment.centerRight,s
                  colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
                  //colors: [Color(0xFF2C7BE5), const Color(0xFF2C7BE5)],
                ),
              ),
              child: FlatButton(
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "設定へ戻る",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSendSuccess) {
      _widgetTree = <Widget>[
        _buildContactTypeDropdown(), // お問い合わせ種別
      ];

      if (_contactType == null) {
        // 初期状態
        _widgetTree += <Widget>[
          _buildConfirmButtonArea(), // 確認ボタン
        ];
      } else {
        int imageLimit = 0;
        switch (_contactType) {
          case _ContactType.GENERAL_SERVICE: // サービス全般
            _widgetTree += <Widget>[
              _buildTerminalType(), // 端末の種類
              _appVersion(), // アプリバージョン
              _buildNickName(), // ニックネーム
              _buildSymbol(), // シンボル
            ];
            break;
          case _ContactType.COMMODITY_TRADING: // 商品取引
            _widgetTree += <Widget>[
              _tradingId(), // 取引ID
              _buildNickName(), // ニックネーム
              _buildSymbol(), // シンボル
            ];
            break;
          case _ContactType.LIVER_REGISTRATION: // ライバー登録
            _widgetTree += <Widget>[
              _buildSymbol(), // シンボル
              _buildNickName(), // ニックネーム
            ];
            break;
          case _ContactType.APP_FAILURE: // アプリの不具合
            _widgetTree += <Widget>[
              _buildTerminalType(), // 端末の種類
              _buildOsVersion(), // OSバージョン
              _appVersion(), // アプリバージョン
              _buildNickName(), // ニックネーム
              _buildSymbol(), // シンボル
            ];
            imageLimit = 3;
            break;
          case _ContactType.COIN_CHARGE: // コインチャージ
            _widgetTree.insert(0, _coinChargeAlertText());
            _widgetTree += <Widget>[
              _buildTerminalType(), // 端末の種類
              _buildOsVersion(), // OSバージョン
              _appVersion(), // アプリバージョン
              _buildNickName(), // ニックネーム
              _buildSymbol(), // シンボル
            ];
            imageLimit = 5;
            break;
          case _ContactType.TROUBLE: // トラブル
            _widgetTree += <Widget>[
              _buildNickName(), // ニックネーム
              _buildSymbol(), // シンボル
            ];
            imageLimit = 3;
            break;
          case _ContactType.OTHER: // その他
          case _ContactType.REQUEST_REFUNDS: // 返金
            _widgetTree += <Widget>[
              _buildNickName(), // ニックネーム
              _buildSymbol(), // シンボル
            ];
            break;
        }

        _widgetTree += <Widget>[
          _buildEmailAddress(), // メールアドレス
        ];
        if (_contactType == _ContactType.COIN_CHARGE) {
          _widgetTree += <Widget>[
            _buildCoinChargeDescription(),
          ];
        }
        _widgetTree += <Widget>[
          _buildContactOfInquiry(), // お問い合わせ内容
        ];
        if (imageLimit > 0) {
          _widgetTree += <Widget>[
            _buildChooseImage(imageLimit), // 画像選択
          ];
        }
        _widgetTree += <Widget>[
          _buildNotice(), // 注意事項
          _buildConfirmButtonArea(), // 確認ボタン
        ];
      }
    } else {
      _widgetTree = <Widget>[
        _buildContactDone(),
      ];
    }

    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.CONTACT,
      titleColor: Colors.white,
      isLoading: _isLoading,
      body: Container(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _widgetTree,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoinChargeDescription() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: MARGIN_HORZ, right: MARGIN_HORZ),
      child: ExpandablePanel(
        theme: ExpandableThemeData(
          iconColor: const Color(0xffc0c0c0),
        ),
        header: Text('▶コインチャージが反映されなかった方へ',
            style: TextStyle(color: const Color(0xffc0c0c0))),
        expanded: DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text:
                        '''課金によるコインチャージが反映されなかった場合は、ご購入日時、課金金額を明記の上、下記サンプル画像のようにApp StoreまたはGoogle Playの購入履歴のスクリーンショットを添付（必須）してください。（複数回にわたり反映されなかった場合は、全てご記入および画像の添付をお願いいたします。）

・購入履歴のスクショのサンプル画像

iPhoneの場合
'''),
                WidgetSpan(
                  child: Container(
                    height: 400.0,
                    child: Image.asset('assets/contact/coin_charge_ios.png'),
                  ),
                ),
                TextSpan(text: '''


Androidの場合
'''),
                WidgetSpan(
                  child: Container(
                    height: 400.0,
                    child:
                        Image.asset('assets/contact/coin_charge_android.png'),
                  ),
                ),
                TextSpan(text: '''


【チャージ数量】
180コイン（￥120）
755コイン（￥500）
1672コイン（￥1,100）
4,681コイン（￥3,060）
7,730コイン（￥5,020）
15,500コイン（￥10,000）

※購入履歴の確認方法は以下をご覧ください。

▶️ iPhoneの場合
App Store アプリ → 右上のアカウントアイコン → 自身のアカウント名 → 購入履歴
または、
設定アプリ → iTunes と App Store → Apple ID → Apple ID を表示 → 購入履歴

詳しくは'''),
                UrlTextSpan(context, 'こちら',
                    url: 'https://support.apple.com/ja-jp/HT204088'),
                TextSpan(text: '''をご覧ください。

▶️ Androidの場合
Google Play ストア アプリ → メニューアイコン → アカウント情報 → 購入履歴

詳しくは'''),
                UrlTextSpan(context, 'こちら',
                    url:
                        'https://support.google.com/googleplay/answer/2850369?hl=ja'),
                TextSpan(text: '''をご覧ください。                
'''),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChooseImage(int imageLimit) {
    if (_images.isEmpty) {
      return _putHorizontalMargin(
        child: Row(
          children: <Widget>[
            Expanded(child: Container()),
            InkWell(
              onTap: _getGalleryImage,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    SvgPicture.asset("assets/svg/ic_gallery.svg"),
                    SizedBox(width: 10),
                    Text(
                      "画像を添付",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 200,
        margin: EdgeInsets.only(top: 10),
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            return index == _images.length ? _chooseImage() : _imageView(index);
          },
          loop: false,
          // loop: true だと逆回りに動かして要素を足すとエラーが発生する
          control: SwiperControl(color: Colors.white, size: 12),
          controller: _swipeController,
          viewportFraction: 0.6,
          scale: 1,
          itemCount: min(_images.length + 1, imageLimit),
        ),
      );
    }
  }

  Widget _chooseImage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white), color: ColorLive.C26),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*
            FlatButton(
              onPressed: _getCaptureImage,
              child: Column(
                children: <Widget>[
                  SvgPicture.asset("assets/svg/icon_camera.svg"),
                  SizedBox(height: 6),
                  Text(
                    "商品画像を撮影",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "もしくは",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            SizedBox(height: 10),
             */
            FlatButton(
              onPressed: _getGalleryImage,
              child: Column(
                children: <Widget>[
                  SvgPicture.asset("assets/svg/icon_gallery.svg"),
                  SizedBox(height: 6),
                  Text(
                    "ライブラリから画像を選択",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageView(int index) {
    final ss = _images[index];
    ImageProvider imageProvider = FileImage(
      ss,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(3)),
        border: Border.all(color: Colors.white),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: RawMaterialButton(
          padding: EdgeInsets.all(10),
          shape: CircleBorder(),
          fillColor: Colors.black.withAlpha(80),
          onPressed: () {
            setState(() {
              _deleteImage(index);
              if (index >= _images.length)
                _swipeController.move(max(index - 1, 0));
            });
          },
          child: SvgPicture.asset("assets/svg/remove.svg"),
        ),
      ),
    );
  }

  void _getGalleryImage() async {
    var image = await ImageUtil.pickImage(context, ImageSource.gallery);
    if (image != null) {
      final croppedFile = await ImageUtil.cropImage(image.path);
      if (croppedFile != null) {
        setState(() {
          _images.add(croppedFile);
        });
      }
    }
  }

  void _deleteImage(int index) {
    _images.removeAt(index);
  }

  Widget _dropdownInput<T>({
    @required List<T> items,
    T initialValue,
    @required String Function(T) getText,
    String Function(T) validator,
    Function onChanged,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: ColorLive.BLUE_GR,
      ),
      child: DropdownButtonFormField<T>(
        value: initialValue,
        validator: validator,
        icon: SvgPicture.asset("assets/svg/ic_down_arrow.svg"),
        itemHeight: 54,
        isExpanded: true,
        hint: Text(
          '選択してださい',
          style: TextStyle(color: ColorLive.BORDER2),
        ),
        iconSize: 16,
        style: TextStyle(color: Colors.white, fontSize: 16),
        onChanged: onChanged,
        items: items
            .map((T value) => DropdownMenuItem<T>(
                  value: value,
                  child: Text(getText(value)),
                ))
            .toList(),
        decoration: InputDecoration(
            fillColor: Colors.white.withAlpha(20),
            filled: true,
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: -2)),
      ),
    );
  }

  // 入力テキストフィールド
  Widget _inputTextField(
      {TextEditingController controller,
      Function validator,
      TextInputType keyboardType}) {
    return TextFormField(
      keyboardType: keyboardType,
      controller: controller,
      validator: validator,
      style: TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        fillColor: Colors.white.withAlpha(20),
        filled: true,
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        errorBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        hintText: Lang.HINT_INPUT,
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }

  // お問い合わせ内容テキストフィールド
  Widget _multilineInputTextField() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: Border.all(color: ColorLive.background, width: 1)),
      child: TextField(
        style: TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: Lang.HINT_CONTACT,
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: ColorLive.BORDER2, fontSize: 13),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            counterStyle: TextStyle(color: ColorLive.C97)),
        minLines: 5,
        maxLines: 5,
        controller: _mainTextController,
        maxLength: 1000,
      ),
    );
  }

  // 必須ラベル
  Widget _requiredText(String text) {
    return RichText(
      text: TextSpan(text: text, children: [
        TextSpan(text: "（必須）", style: TextStyle(color: ColorLive.YELLOW)),
      ]),
    );
  }

  // 確認ボタンウィジェット
  Widget _confirmButton() {
    return Center(
      child: Container(
        height: 40.0,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
          ),
        ),
        child: FlatButton(
          textColor: Colors.white,
          onPressed: _contactType == null
              ? null
              : () {
                  if (_formKey.currentState.validate()) {
                    _sendData();
                  } else {
                    setState(() {
                      _autoValidate = true;
                    });
                  }
                },
          child: Text(
            Lang.DO_SEND,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  Future<void> _sendData() async {
    setState(() {
      _isLoading = true;
    });
    var service = BackendService(context);
    final userModel = Provider.of<UserModel>(context, listen: false);

    List<String> base64Images;
    if (_images.isNotEmpty) {
      base64Images = await Future.wait(_images.map((image) async {
        final resizedImage =
            await ImageUtil.shrinkIfNeeded(image, Consts.CONTACT_IMAGE_WIDTH);
        return ImageUtil.toBase64DataImage(resizedImage);
      }));
    }

    final terminal = _deviceType;
    String os = _osVersionController.text;

    String typeStr = _contactTypeText[_contactType];
    Inquiry inquiry;
    switch (_contactType) {
      case _ContactType.GENERAL_SERVICE:
        inquiry = Inquiry(
          userModel.token,
          type: typeStr,
          terminal: terminal,
          os: os,
          symbol: _symbolController.text,
          nickname: _nicknameController.text,
          mail: _emailController.text,
          message: _mainTextController.text,
        );
        break;
      case _ContactType.COMMODITY_TRADING:
        inquiry = Inquiry(
          userModel.token,
          type: typeStr,
          terminal: terminal,
          os: os,
          orderId: _tradingIdController.text,
          nickname: _nicknameController.text,
          mail: _emailController.text,
          message: _mainTextController.text,
        );
        break;
      case _ContactType.LIVER_REGISTRATION:
        inquiry = Inquiry(
          userModel.token,
          type: typeStr,
          terminal: terminal,
          os: os,
          symbol: _symbolController.text,
          nickname: _nicknameController.text,
          mail: _emailController.text,
          message: _mainTextController.text,
        );
        break;
      case _ContactType.APP_FAILURE:
        inquiry = Inquiry(
          userModel.token,
          type: typeStr,
          terminal: terminal,
          os: os,
          appVer: _appVersionController.text,
          symbol: _symbolController.text,
          nickname: _nicknameController.text,
          mail: _emailController.text,
          message: _mainTextController.text,
          base64Images: base64Images,
        );
        break;
      case _ContactType.COIN_CHARGE:
        inquiry = Inquiry(
          userModel.token,
          type: typeStr,
          terminal: terminal,
          os: os,
          appVer: _appVersionController.text,
          symbol: _symbolController.text,
          nickname: _nicknameController.text,
          mail: _emailController.text,
          message: _mainTextController.text,
          base64Images: base64Images,
        );
        break;
      case _ContactType.TROUBLE:
        inquiry = Inquiry(
          userModel.token,
          type: typeStr,
          terminal: terminal,
          os: os,
          symbol: _symbolController.text,
          nickname: _nicknameController.text,
          mail: _emailController.text,
          message: _mainTextController.text,
          base64Images: base64Images,
        );
        break;
      case _ContactType.OTHER:
      case _ContactType.REQUEST_REFUNDS:
        inquiry = Inquiry(
          userModel.token,
          type: typeStr,
          terminal: terminal,
          os: os,
          symbol: _symbolController.text,
          nickname: _nicknameController.text,
          mail: _emailController.text,
          message: _mainTextController.text,
        );
        break;
      default:
        // no-op
        break;
    }

    final response = await service.postInquiry(inquiry);
    setState(() {
      _isLoading = false;
    });
    if (response != null && response.result) {
      setState(() {
        _isSendSuccess = true;
      });
    } else {
      showNetworkErrorDialog(context, msg: response?.getByKey('msg'));
    }
  }

  // iOS OS version
  Future<String> _getOsVersion() async {
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      return '$systemName $version';
    } else if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;
      return 'Android $release (SDK $sdkInt)';
    } else {
      return 'Unknown';
    }
  }

  // アプリバージョン
  void _addAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersionController.text = packageInfo.version;
  }

  Widget _putHorizontalMargin({@required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: MARGIN_HORZ),
      width: double.infinity,
      child: child,
    );
  }

  Widget _coinChargeAlertText() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10),
          RichText(
            text: TextSpan(text: 'お問い合わせ前、事前確認', children: [
              TextSpan(text: "（必読）", style: TextStyle(color: ColorLive.YELLOW)),
            ]),
          ),
          SizedBox(height: 10),
          Text(
            "コインチャージが反映されなかった場合、アプリを一度バックグラウンドまで終了させて、再度チャージ画面に入り直すことで、事象が改善される事があります。改善されない場合は、お手数ですが以下よりお問い合わせをお願いします。",
            style: TextStyle(
              color: ColorLive.YELLOW,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}
