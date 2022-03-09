import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/domain/model/user/badge_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/repository/event_logger_repository.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/shop/product_detail_page.dart';
import 'package:live812/ui/scenes/user/purchase_chat_page.dart';
import 'package:live812/utils/widget/ec_product_price_text.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/purchase_chat_button.dart';
import 'package:live812/utils/widget/safe_network_image.dart';
import 'package:live812/utils/widget/web_view_page.dart';
import 'package:provider/provider.dart';

enum PurchaseDetailsResult {
  Finished, // 完了
}

const double _MARGIN_SIDE = 15;

class PurchaseDetailsPage extends StatefulWidget {
  final Purchase purchase;

  PurchaseDetailsPage(this.purchase);

  @override
  PurchaseDetailsPageState createState() => PurchaseDetailsPageState();
}

class PurchaseDetailsPageState extends State<PurchaseDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;

  TextEditingController _nameController;
  TextEditingController _post1Controller;
  TextEditingController _post2Controller;
  TextEditingController _addressController;
  TextEditingController _buildingController;
  TextEditingController _phoneController;

  var _isLoading = false;

  // ステート系
  PurchaseState _purchaseState;

  bool get _isWaitingForPayment =>
      _purchaseState == PurchaseState.WaitingForPayment;
  bool get _isWaitingForDeliveryDestination =>
      (_purchaseState == PurchaseState.WaitingForPayment ||
          _purchaseState == PurchaseState.WaitingForDeliveryDestination) &&
      !_deliveryDestinationFilled;
  bool get _isDeliveryCompleted =>
      _purchaseState == PurchaseState.DeliveryCompleted;
  bool get _deliveryDestinationFilled {
    return widget.purchase.deliveryName?.isNotEmpty == true &&
        widget.purchase.deliveryPostalCode?.isNotEmpty == true &&
        widget.purchase.deliveryAddr?.isNotEmpty == true &&
        widget.purchase.deliveryPhone?.isNotEmpty == true;
  }

  bool _isFinished = false;
  bool _isSuspend = false;
  bool _canChat = false;

  @override
  void dispose() {
    _nameController.dispose();
    _post1Controller.dispose();
    _post2Controller.dispose();
    _addressController.dispose();
    _buildingController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    var postalCode = widget.purchase.deliveryPostalCode;
    if (postalCode != null && postalCode.toString().isNotEmpty) {
      final postalCodes = postalCode.split('-');
      _post1Controller = TextEditingController(text: postalCodes[0]);
      _post2Controller = TextEditingController(text: postalCodes[1]);
    } else {
      _post1Controller = TextEditingController();
      _post2Controller = TextEditingController();
    }
    _nameController = TextEditingController(text: widget.purchase.deliveryName);
    _addressController =
        TextEditingController(text: widget.purchase.deliveryAddr);
    _buildingController =
        TextEditingController(text: widget.purchase.deliveryBuild);
    _phoneController =
        TextEditingController(text: widget.purchase.deliveryPhone);

    _purchaseState = widget.purchase.state;
    _isFinished = _purchaseState == PurchaseState.Completed;
    _isSuspend = _purchaseState == PurchaseState.Suspend;
    _canChat = widget.purchase.canChat();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      isLoading: _isLoading,
      backgroundColor: ColorLive.MAIN_BG,
      title:
          widget.purchase.id != null ? '取引ID : ${widget.purchase.orderId}' : '',
      titleColor: Colors.white,
      actions: <Widget>[
        InkWell(
          onTap: () async {
            final data = ClipboardData(text: '${widget.purchase.orderId}');
            await Clipboard.setData(data);
            Flushbar(
              icon: Icon(
                Icons.info_outline,
                size: 28.0,
                color: Colors.blue[300],
              ),
              message: Lang.COPIED,
              duration: Duration(milliseconds: 2000),
              margin: EdgeInsets.all(8),
              borderRadius: 8,
            )..show(context);
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: SvgPicture.asset(
              'assets/svg/copy.svg',
              width: 28,
              height: 28,
            ),
          ),
        ),
      ],
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Form(
                key: _formKey,
                autovalidate: _autoValidate,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 0),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              FadeRoute(
                                  builder: (context) => ProductDetailPage(
                                        product:
                                            widget.purchase.getProductInfo(),
                                      )));
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: _MARGIN_SIDE),
                          color: ColorLive.C26,
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  widget.purchase.imgThumbUrl != null
                                      ? Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                            image: NetworkImage(
                                                widget.purchase.imgThumbUrl[0]),
                                            fit: BoxFit.cover,
                                          )),
                                        )
                                      : Container(
                                          width: 70,
                                          height: 70,
                                          child: Center(
                                            child: Text(Lang.NO_IMAGE,
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          ),
                                        ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              widget.purchase.purchaseDate !=
                                                      null
                                                  ? dateFormat(widget
                                                      .purchase.purchaseDate)
                                                  : '',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    width: 20,
                                                    height: 20,
                                                    //margin: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color:
                                                                Colors.white),
                                                        image: DecorationImage(
                                                          image: SafeNetworkImage(
                                                              widget.purchase
                                                                  .salesUserThumbnailUrl),
                                                          fit: BoxFit.cover,
                                                        )),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      widget.purchase
                                                          .salesUserNickname,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          widget.purchase.name != null
                                              ? widget.purchase.name
                                              : '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            EcProductPriceText(
                                              widget.purchase?.price,
                                              priceTextStyle: const TextStyle(
                                                  color: ColorLive.BLUE_GR,
                                                  fontFamily: "Roboto"),
                                              includePostageTextStyle:
                                                  const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: ColorLive.ORANGE,
                                    size: 10,
                                  ),
                                ],
                              ),
                              SizedBox(height: 10)
                            ],
                          ),
                        ),
                      ),
                      _status(),
                      _isFinished
                          ? _completeInformation()
                          : _deliveryInformation(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _isWaitingForDeliveryDestination
              ? Container(
                  height: 60.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
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
                      _validateInputs();
                    },
                    child: Text(
                      "配送先を指定",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : Container(),
          _isDeliveryCompleted && !_isFinished || _isSuspend
              ? Container(
                  height: 60.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
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
                      _postReceiveItem(context);
                    },
                    child: Text(
                      "商品を受け取りました",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : Container(),
          SizedBox(height: 5),
          _isDeliveryCompleted && !_isFinished
              ? Container(
                  height: 60.0,
                  width: double.infinity,
                  color: Colors.grey,
                  child: FlatButton(
                    textColor: Colors.white,
                    onPressed: () {
                      _postSuspendItem(context);
                    },
                    child: Text(
                      "取引一時中断",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : Container(),
          _isSuspend
              ? Container(
                  height: 60.0,
                  width: double.infinity,
                  color: Colors.grey,
                  child: FlatButton(
                    textColor: Colors.white,
                    child: Text(
                      "取引一時中断中",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  // 現在のステータス
  Widget _purchaseStatus(String label, Color color) {
    return Container(
      color: color,
      margin:
          EdgeInsets.only(right: _MARGIN_SIDE, left: _MARGIN_SIDE, top: 18.0),
      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Text(
            "現在のステータス",
            style: TextStyle(color: Colors.white, fontSize: 12.0),
          ),
          SizedBox(
            width: 68.0,
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ステータスWidget
  Widget _status() {
    switch (_purchaseState) {
      case PurchaseState.WaitingForPayment:
        return _purchaseStatus('入金待ち', ColorLive.RED);
      case PurchaseState.WaitingForDeliveryDestination:
        return _purchaseStatus('配送先指定待ち', ColorLive.RED);
      case PurchaseState.WaitingForDelivery:
        return _purchaseStatus('発送待ち', ColorLive.C555);
      case PurchaseState.DeliveryCompleted:
        return _purchaseStatus('発送済み', ColorLive.RED);
      case PurchaseState.Completed:
        return _purchaseStatus('取引完了', ColorLive.C555);
      case PurchaseState.Cancel:
        return _purchaseStatus('キャンセル', ColorLive.C26);
      case PurchaseState.Suspend:
        return _purchaseStatus('取引一時中断中', ColorLive.RED);
      default:
        return _purchaseStatus('入金待ち', ColorLive.RED);
    }
  }

  String _message() {
    switch (_purchaseState) {
      case PurchaseState.WaitingForPayment:
      case PurchaseState.WaitingForDeliveryDestination:
        return _isWaitingForDeliveryDestination ? '配送先情報を指定してください' : '配送先情報：';
      case PurchaseState.WaitingForDelivery:
        return '配送先情報が出品者に送信されました。\n商品の発送をお待ちください。';
      case PurchaseState.DeliveryCompleted:
        return '商品が配送されました。\n商品を受け取ったら、「商品を受け取りました」を押して取引を完了させてください。';
      case PurchaseState.Completed:
        return '取引は完了です。\nありがとうございました。';
      default:
        return '';
    }
  }

  // 配送先情報
  Widget _deliveryInformation() {
    var children = <Widget>[
      Container(
        color: ColorLive.PINK,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: !_isWaitingForPayment
            ? Container()
            : Builder(
                builder: (context) {
                  Purchase purchase = widget.purchase;
                  return Column(
                    children: <Widget>[
                      SizedBox(height: 18),
                      Text(
                        "【お振込み先情報】",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '${purchase.bankName}\n${purchase.bankBranch}\n${purchase.bankAccountType} ${purchase.bankAccountNumber}\n${purchase.bankAccountName}',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "【振込人名義】",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "${purchase.orderId} ${purchase.deliveryName}",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 18),
                      Text(
                        "振込期限：${dateFormatJp(purchase.purchaseDate.add(Duration(days: 3)))}",
                        style: TextStyle(color: Colors.yellow),
                      ),
                      SizedBox(height: 16),
                      Divider(
                        color: Colors.white,
                        height: 2,
                        thickness: 1,
                      ),
                      Text(
                        "お振込みの際には、振込依頼人名の前に8桁の取引IDを必ず記載してください。取引IDの記載を忘れますとご入金の確認が取れません。",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 11,
                      )
                    ],
                  );
                },
              ),
      ),
    ];

    if (_canChat) {
      children += <Widget>[
        const SizedBox(height: 10),
        PurchaseChatButton(
          purchase: widget.purchase,
          onPressed: () async {
            await Navigator.push(context, FadeRoute(builder: (context) {
              return PurchaseChatPage(
                orderId: widget.purchase.orderId,
              );
            }));
            setState(() {
              widget.purchase.badgeChat = false;
            });
          },
        ),
      ];
    }

    if (_purchaseState != PurchaseState.Cancel) {
      children += <Widget>[
        Container(
          margin: EdgeInsets.only(top: 30, bottom: 17),
          child: Text(
            _isFinished ? '取引は完了です。\nありがとうございました。' : _message(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        Text(
          "氏名",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        _buildTextFormField(
          controller: _nameController,
          validator: CustomValidator.validateRealName,
          hintText: "例）山田太郎",
        ),
        SizedBox(height: 11),
        Text(
          "送り先",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: <Widget>[
            Flexible(
              child: _buildTextFormField(
                controller: _post1Controller,
                validator: (value) =>
                    CustomValidator.validateNumber(value, order: 3),
                maxLength: 3,
                hintText: "000",
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10),
            Container(
              color: ColorLive.BORDER2,
              height: 1,
              width: 9,
            ),
            SizedBox(width: 10),
            Flexible(
              child: _buildTextFormField(
                controller: _post2Controller,
                validator: (value) =>
                    CustomValidator.validateNumber(value, order: 4),
                maxLength: 4,
                hintText: "0000",
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        _buildTextFormField(
          controller: _addressController,
          validator: CustomValidator.validateAddress,
          hintText: "東京都中央区銀座1-1-1",
        ),
        SizedBox(height: 8),
        _buildTextFormField(
          controller: _buildingController,
          hintText: "〇〇マンション 101号室",
        ),
        SizedBox(height: 16),
        Text(
          "電話番号",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        _buildTextFormField(
          controller: _phoneController,
          validator: CustomValidator.validatePhoneNumber,
          maxLength: 11,
          hintText: "09012345678",
          keyboardType: TextInputType.phone,
        ),
      ];
    }

    children += <Widget>[
      SizedBox(height: 43),
      Row(
        children: <Widget>[
          Flexible(
            child: Container(
              height: 25.0,
              width: double.infinity,
              child: FlatButton(
                textColor: Colors.white,
                onPressed: () {
                  // Q&Aへ遷移.
                  final userModel = Provider.of<UserModel>(context, listen: false);
                  var url = userModel.isLiver
                      ? 'https://live812.jp/q_a/qa.html?liver'
                      : 'https://live812.jp/q_a/qa.html?listener';
                  Navigator.push(
                      context,
                      FadeRoute(
                          builder: (context) => WebViewPage(
                                url: url,
                                titleColor: Colors.white,
                                title: Lang.QUESTION_AND_ANSWER,
                                appBarColor: ColorLive.MAIN_BG,
                                toGivePermissionJs: true,
                              ))); // ヘルプ・使い方
                },
                child: const Text(
                  "取引に困った時は",
                  style: TextStyle(fontSize: 12),
                ),
                shape: RoundedRectangleBorder(
                    side: const BorderSide(
                        color: Colors.white,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 43),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: _MARGIN_SIDE),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // 取引完了情報.
  Widget _completeInformation() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: _MARGIN_SIDE),
      child: Column(
        children: <Widget>[
          _canChat ? SizedBox(height: 10) : Container(),
          _canChat
              ? PurchaseChatButton(
                  purchase: widget.purchase,
                  onPressed: () async {
                    await Navigator.push(context, FadeRoute(builder: (context) {
                      return PurchaseChatPage(
                        orderId: widget.purchase.orderId,
                      );
                    }));
                    setState(() {
                      widget.purchase.badgeChat = false;
                    });
                  },
                )
              : Container(),
          SizedBox(
            height: 10.0,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                widget.purchase?.deliveryEnd != null
                    ? Text(
                        '取引完了日 ${dateFormat(widget.purchase.deliveryEnd)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      )
                    : Container(),
                Text(
                  '受け取り完了から3⽇経過しますとチャット機能は使えなくなります。',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    TextEditingController controller,
    String hintText,
    String Function(String) validator,
    int maxLength,
    TextInputType keyboardType,
  }) {
    bool editable = _isWaitingForDeliveryDestination;
    return TextFormField(
      enabled: editable,
      controller: controller,
      style: TextStyle(color: Colors.white),
      validator: validator,
      maxLength: maxLength,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        filled: true,
        fillColor: Colors.white.withAlpha(20),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        errorBorder:
            const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder:
            const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        labelStyle: TextStyle(color: Colors.white),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        counterText: maxLength == null ? null : '',
      ),
    );
  }

  Future<void> _validateInputs() async {
    if (!_formKey.currentState.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    // If all data are correct then save data to out variables
    _formKey.currentState.save();

    final postalCode = _post1Controller.text != null &&
            _post2Controller.text.toString() != null
        ? '${_post1Controller.text.toString()}-${_post2Controller.text.toString()}'
        : null;

    setState(() => _isLoading = true);
    final service = BackendService(context);
    final response = await service.postPurchaseDelivery(
        itemId: widget.purchase.itemId,
        updateInfo: true,
        deliveryName: _nameController.text,
        deliveryPostalCode: postalCode,
        deliveryAddr: _addressController.text,
        deliveryBuild: _buildingController.text,
        deliveryPhone: _phoneController.text);
    setState(() => _isLoading = false);
    if (response != null && response.result) {
      // TODO: ユーザ情報も更新する？
      //final model = UserInfoModel(
      //    deliveryName: _nameController.text.toString(),
      //    deliveryPostalCode: postalCode,
      //    deliveryAddress: _addressController.text.toString(),
      //    deliveryBuilding: _buildingController.text.toString(),
      //    deliveryPhone: _phoneController.text.toString(),
      //    itemId: widget.purchase.itemId);
      //final response2 = await service.putUser(userModel.token, model);
      //userModel.setDeliveryInfo(
      //    _nameController.text.toString(),
      //    postalCode,
      //    _addressController.text.toString(),
      //    _buildingController.text.toString(),
      //    _phoneController.text.toString());
      Navigator.of(context).pop(true);
    } else {
      showNetworkErrorDialog(context, msg: response.getByKey('msg'));
    }
  }

  // 商品受け取り完了
  Future<void> _postReceiveItem(BuildContext context) async {
    var result = await showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("取引完了"),
        content: Text("取引を完了します。\nよろしいですか？"),
        actions: <Widget>[
          FlatButton(
            child: Text("いいえ"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FlatButton(
            child: Text("はい"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    }) == true;

    if (!result) {
      // 何もしない.
      return;
    }
    setState(() => _isLoading = true);
    final service = BackendService(context);
    final response = await service.postReceiveItem(widget.purchase.itemId);
    setState(() => _isLoading = false);
    if (response != null && response.result) {

      Injector.getInjector()
          .get<EventLoggerRepository>()
          .sendPurchaseEcItemEvent(widget.purchase.price);

      setState(() {
        _isFinished = true;
        _isSuspend = false;
        _purchaseState = PurchaseState.Completed;
      });
      // バッジ情報が変わる可能性があるので、更新する
      final badgeInfo = Provider.of<BadgeInfo>(context, listen: false);
      badgeInfo.requestMyInfoBadge(context);
    } else {
      showNetworkErrorDialog(context, msg: response.getByKey('msg'));
    }
  }

  // 取引中断.
  Future<void> _postSuspendItem(BuildContext context) async {
    var result = await showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text("取引一時中断"),
        content: Text("取引を一時中断します。\nよろしいですか？"),
        actions: <Widget>[
          FlatButton(
            child: Text("いいえ"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FlatButton(
            child: Text("はい"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    }) == true;

    if (!result) {
      // 何もしない.
      return;
    }
    setState(() => _isLoading = true);
    final service = BackendService(context);
    final response = await service.postPurchaseDelivery(
        itemId : widget.purchase.itemId,
        irregular: true,
    );
    setState(() => _isLoading = false);
    if (response != null && response.result) {
      Navigator.of(context).pop(true);
    } else {
      showNetworkErrorDialog(context, msg: response.getByKey('msg'));
    }
  }
}
