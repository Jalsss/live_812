import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/ec/delivery_provider.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/shop/product_detail_page.dart';
import 'package:live812/ui/scenes/user/purchase_cancel_page.dart';
import 'package:live812/ui/scenes/user/purchase_chat_page.dart';
import 'package:live812/utils/widget/ec_product_price_text.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/on_memory_cache.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/exclamation_badge.dart';
import 'package:live812/utils/widget/purchase_chat_button.dart';
import 'package:live812/utils/widget/web_view_page.dart';
import 'package:provider/provider.dart';

const double _MARGIN_SIDE = 15;

class LiverPurchaseDetailsPage extends StatefulWidget {
  final Purchase purchase;

  LiverPurchaseDetailsPage(this.purchase);

  @override
  LiverPurchaseDetailsPageState createState() =>
      LiverPurchaseDetailsPageState();
}

class LiverPurchaseDetailsPageState extends State<LiverPurchaseDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _trackingNumController = TextEditingController();

  bool _autoValidate = false;
  String _shippingMethod;
  String _selectTrackingNum;
  bool _isLoading = false;
  bool _isFinished;
  bool _canChat = false;
  Future<List<dynamic>> _deliveryProvider;
  bool _isUpdated = false;
  bool _isTrackingNumber = true;

  // 配送業者取得
  Future<List<DeliveryProvider>> _requestDeliveryProvider() async {
    final response = await OnMemoryCache.fetch(
        ApiPath.deliveryProvider, Duration(days: 1), () async {
      setState(() => _isLoading = true);
      final service = BackendService(context);
      final response = await service.getDeliveryProvider();
      setState(() => _isLoading = false);
      return response;
    });
    if (response != null && response.result) {
      final list = List<DeliveryProvider>();
      for (final data in response.getData()) {
        list.add(DeliveryProvider.fromJson(data));
      }
      return list;
    } else {
      showNetworkErrorDialog(context);
      return null;
    }
  }

  // 配送完了リクエスト
  Future<void> _requestPurchaseDelivery() async {
    if (!_formKey.currentState.validate()) {
      setState(() => _autoValidate = true);
      return;
    }
    _formKey.currentState.save();

    final service = BackendService(context);
    setState(() => _isLoading = true);
    final response = await service.postPurchaseDelivery(
      itemId: widget.purchase.itemId,
      updateBegin: true,
      deliveryProviderId: _selectTrackingNum,
      trackingNum: _trackingNumController.text.toString(),
      trackingFlag: _isTrackingNumber,
    );
    setState(() => _isLoading = false);
    if (response != null && response.result) {
      setState(() {
        _isUpdated = _isFinished = true;
        widget.purchase.state = PurchaseState.DeliveryCompleted; // 書き換えてやる
      });
    } else {
      showNetworkErrorDialog(context, msg: response.getByKey('msg'));
    }
  }

  @override
  void initState() {
    super.initState();
    _isFinished = widget.purchase.deliveryEnd != null;
    _deliveryProvider = _requestDeliveryProvider();
    _canChat = widget.purchase.canChat();
  }

  void _back() {
    if (_isUpdated)
      Navigator.of(context).pop(_isUpdated);
    else
      Navigator.of(context).pop();
  }

  // 配送先情報Widget
  Widget _shippingAddressInfo() {
    String postalCode1, postalCode2;
    if (widget.purchase.deliveryPostalCode.isNotEmpty) {
      final postalCodes = widget.purchase.deliveryPostalCode.split('-');
      postalCode1 = postalCodes[0];
      postalCode2 = postalCodes[1];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 30, bottom: 17),
          child: Text(
            "配送先情報",
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
        Consumer<UserModel>(
          builder: (context, userModel, _) {
            return _buildBoxedInfo(widget.purchase.deliveryName ?? '');
          },
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
              child: _buildBoxedInfo(postalCode1 ?? ''),
            ),
            SizedBox(width: 10),
            Container(
              color: ColorLive.BORDER2,
              height: 1,
              width: 9,
            ),
            SizedBox(width: 10),
            Flexible(
              child: _buildBoxedInfo(postalCode2 ?? ''),
            ),
          ],
        ),
        SizedBox(height: 8),
        _buildBoxedInfo(widget.purchase.deliveryAddr),
        SizedBox(height: 8),
        _buildBoxedInfo(widget.purchase.deliveryBuild),
        SizedBox(height: 16),
        Text(
          "電話番号",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        _buildBoxedInfo(widget.purchase.deliveryPhone),
      ],
    );
  }

  Widget _buildBoxedInfo(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: Colors.white.withAlpha(20),
        border: Border.all(color: Colors.white),
      ),
      child: Container(
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
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
          SizedBox(width: 68),
          Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 購入者情報
  Widget _purchaseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 30, bottom: 10),
          child: Text(
            "購入者情報",
            style: TextStyle(color: Colors.white),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                    width: 80,
                    height: 80,
                    child: RawMaterialButton(
                      onPressed: () {},
                      elevation: 2,
                      padding: EdgeInsets.all(2),
                      shape: CircleBorder(),
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: NetworkImage(
                            widget.purchase.purchaseUserThumbnailUrl),
                        backgroundColor: Colors.transparent,
                      ),
                    )),
                SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.purchase.purchaseUserNickname != null
                          ? widget.purchase.purchaseUserNickname
                          : '',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      widget.purchase.purchaseUserId != null
                          ? widget.purchase.purchaseUserId
                          : '',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Roboto",
                          fontSize: 12),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // 配送完了ボタン
  Widget _finishedButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
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
            _requestPurchaseDelivery();
          },
          child: Text(
            "発送完了",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  // 配送方法
  Widget _buildShippingMethod() {
    String message;
    if (widget.purchase.state == PurchaseState.WaitingForDelivery) {
      message = '商品の発送が完了したら、画面下にある「発送完了」ボタンを押してください。';
    } else if (widget.purchase.state == PurchaseState.DeliveryCompleted ||
        _isFinished) {
      message = '購入者の「受取完了」をお待ちください。';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 20),
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: ColorLive.BLUE_GR,
          ),
          child: FutureBuilder(
            future: _deliveryProvider,
            builder: (context, snapShot) {
              List<DeliveryProvider> deliveryProviders;
              if (snapShot.hasData) {
                deliveryProviders = snapShot.data;
              }
              if (deliveryProviders == null) return Container();

              return DropdownButtonFormField<String>(
                value: _shippingMethod,
                validator: (value) =>
                    value?.isNotEmpty != true ? '選択してください' : null,
                icon: SvgPicture.asset("assets/svg/ic_down_arrow.svg"),
                itemHeight: 60,
                isExpanded: true,
                hint: Text(
                  '選択してださい',
                  style: TextStyle(color: ColorLive.BORDER2),
                ),
                iconSize: 16,
                style: TextStyle(color: Colors.white, fontSize: 16),
                onChanged: (String newValue) {
                  setState(() {
                    _shippingMethod = newValue;
                    _selectTrackingNum = deliveryProviders
                        .where((d) => d.name == newValue)
                        .first
                        .id;
                  });
                },
                items: deliveryProviders
                    .map<DropdownMenuItem<String>>((deliveryProvider) {
                  return DropdownMenuItem<String>(
                    value: deliveryProvider.name,
                    child: Row(
                      children: <Widget>[
                        Text(
                          deliveryProvider.name,
                          //style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                    fillColor: Colors.white.withAlpha(20),
                    filled: true,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: -2)),
              );
            },
          ),
        ),
        SizedBox(height: 10),
        _isTrackingNumber
            ? TextFormField(
                controller: _trackingNumController,
                style: TextStyle(color: Colors.white),
                validator: (value) =>
                    _shippingMethod == 'その他' && value?.isNotEmpty != true
                        ? '配送業者・送り状No.を入力してください'
                        : null,
                decoration: InputDecoration(
                    fillColor: Colors.white.withAlpha(20),
                    filled: true,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)),
                    hintText:
                        _shippingMethod != 'その他' ? "送り状No." : "配送業者・送り状No.",
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
              )
            : SizedBox.shrink(),
        Container(
          transform: Matrix4.translationValues(-_MARGIN_SIDE, 0.0, 0.0),
          child: Row(
            children: <Widget>[
              Theme(
                child: Checkbox(
                  value: !_isTrackingNumber,
                  onChanged: _onChangeTrackingNumber,
                ),
                data: ThemeData(
                  unselectedWidgetColor: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _onChangeTrackingNumber(_isTrackingNumber);
                },
                child: Text(
                  "送り状No.なし",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 8, bottom: 0),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  // 「取引に困ったら」「キャンセルしたい」ボタン達
  Widget _cancelButton() {
    final state = widget.purchase.state;
    if (state == PurchaseState.DeliveryCompleted ||
        state == PurchaseState.Completed ||
        state == PurchaseState.Cancel) {
      return Container();
    } else {
      return Row(
        children: <Widget>[
          Flexible(
            child: Container(
              height: 25.0,
              width: double.infinity,
              child: FlatButton(
                textColor: Colors.white,
                onPressed: () {
                  // Q&Aへ遷移.
                  Navigator.push(
                      context,
                      FadeRoute(
                          builder: (context) => WebViewPage(
                                url: 'https://live812.jp/q_a/qa.html?liver',
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
          SizedBox(width: 10),
          Flexible(
            child: Container(
              height: 25.0,
              width: double.infinity,
              child: FlatButton(
                textColor: Colors.white,
                onPressed: _confirmCancel,
                child: Text(
                  "キャンセルしたい",
                  style: TextStyle(fontSize: 12),
                ),
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Colors.white,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _purchaseStateContainer;
    Widget _shippingInformation;
    Widget _purchaseInformation;
    Widget _finishedDeliveryButton;
    Widget _shippingMethodColumn;

    switch (widget.purchase.state) {
      case PurchaseState.WaitingForPayment:
        _purchaseStateContainer = _purchaseStatus('入金待ち', ColorLive.C555);
        break;
      case PurchaseState.WaitingForDeliveryDestination:
        _purchaseStateContainer = _purchaseStatus('配送先指定待ち', ColorLive.C555);
        break;
      case PurchaseState.WaitingForDelivery:
        _purchaseStateContainer = _purchaseStatus('発送待ち', ColorLive.RED);
        break;
      case PurchaseState.DeliveryCompleted:
        _purchaseStateContainer = _purchaseStatus('発送済み', ColorLive.C555);
        break;
      case PurchaseState.Completed:
        _purchaseStateContainer = _purchaseStatus('取引完了', ColorLive.C555);
        break;
      case PurchaseState.Cancel:
        _purchaseStateContainer = _purchaseStatus('キャンセル', ColorLive.C555);
        break;
      case PurchaseState.Suspend:
        _purchaseStateContainer = _purchaseStatus('取引一時中断中', ColorLive.RED);
        break;
      default:
        _purchaseStateContainer = _purchaseStatus('入金待ち', ColorLive.C555);
        break;
    }

    switch (widget.purchase.state) {
      case PurchaseState.WaitingForPayment:
        _shippingInformation = Text(
          '入金が完了されるまでお待ちください。',
          style: TextStyle(color: Colors.white),
        );
        break;
      case PurchaseState.WaitingForDeliveryDestination:
        _shippingInformation = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '購入がされました。',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '配送先がまだ登録されていません。',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '登録されるまでお待ちください。',
              style: TextStyle(color: Colors.white),
            ),
          ],
        );
        break;
      case PurchaseState.WaitingForDelivery:
        _shippingInformation = _shippingAddressInfo();
        break;
      case PurchaseState.DeliveryCompleted:
        _shippingInformation = _shippingAddressInfo();
        break;
      case PurchaseState.Completed:
        _shippingInformation = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            widget.purchase?.deliveryEnd != null
                ? Text(
                    '取引完了日 ${dateFormat(widget.purchase.deliveryEnd)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  )
                : Container(),
            SizedBox(
              height: 10.0,
            ),
            Text(
              '商品が受け取られました。\nこれで取引は完了です。\nお疲れ様でした。',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '受け取り完了から3⽇経過しますとチャット機能は使えなくなります。',
              style: TextStyle(color: Colors.white),
            )
          ],
        );
        break;
      case PurchaseState.Cancel:
        _shippingInformation = Container();
        break;
      default:
        _shippingInformation = Container();
        break;
    }

    if (widget.purchase.state == PurchaseState.Completed) {
      _purchaseInformation = Container();
    } else {
      _purchaseInformation = _purchaseInfo();
    }

    if (widget.purchase.state == PurchaseState.WaitingForDelivery) {
      _finishedDeliveryButton = _finishedButton();
    } else {
      _finishedDeliveryButton = Container();
    }

    if (widget.purchase.state == PurchaseState.WaitingForDelivery) {
      _shippingMethodColumn = _buildShippingMethod();
    } else {
      _shippingMethodColumn = Container();
    }

    return LiveScaffold(
      isLoading: _isLoading,
      backgroundColor: ColorLive.MAIN_BG,
      title: widget.purchase.orderId != null
          ? '取引ID : ${widget.purchase.orderId}'
          : '',
      titleColor: Colors.white,
      onClickBack: _back,
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
      body: WillPopScope(
        onWillPop: () async {
          _back();
          return Future.value(false);
        },
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              top: 0,
              bottom: 60,
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
                                          showProfit: widget.purchase.state ==
                                              PurchaseState.Completed,
                                          purchase: widget.purchase,
                                        )));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            color: ColorLive.C26,
                            child: Column(
                              children: <Widget>[
                                SizedBox(height: 10),
                                Row(
                                  children: <Widget>[
                                    widget.purchase.imgThumbUrl?.isNotEmpty ==
                                            true
                                        ? Container(
                                            width: 70,
                                            height: 70,
                                            child: FadeInImage.assetNetwork(
                                              placeholder: Consts
                                                  .LOADING_PLACE_HOLDER_IMAGE,
                                              image: widget
                                                  .purchase.imgThumbUrl[0],
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Container(
                                            width: 70,
                                            height: 70,
                                          ),
                                    SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            widget.purchase.purchaseDate != null
                                                ? dateFormat(widget
                                                    .purchase.purchaseDate)
                                                : '',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            widget.purchase.itemName != null
                                                ? widget.purchase.itemName
                                                : '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              EcProductPriceText(
                                                widget.purchase?.price,
                                                priceTextStyle: TextStyle(
                                                    color: ColorLive.BLUE_GR,
                                                    fontFamily: "Roboto"),
                                                includePostageTextStyle:
                                                    TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12.0),
                                              )
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
                        _purchaseStateContainer,
                        _canChat ? SizedBox(height: 10) : Container(),
                        _canChat
                            ? PurchaseChatButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
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
                        Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: _MARGIN_SIDE),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _shippingMethodColumn,
                              _purchaseInformation,
                              _shippingInformation,
                              SizedBox(height: 43),
                              _cancelButton(),
                              SizedBox(height: 43),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            !_isFinished ? _finishedDeliveryButton : Container(),
          ],
        ),
      ),
    );
  }

  void _onChangeTrackingNumber(bool value) {
    setState(() {
      _isTrackingNumber = !value;
    });
  }

  Future<void> _confirmCancel() async {
    final result = await Navigator.push(
        context,
        FadeRoute(
            builder: (context) => PurchaseCancelPage(
                widget.purchase.salesUserId,
                widget.purchase.orderId,
                widget.purchase.itemName,
                widget.purchase.price)));

    if (result == PurchaseCancelResult.Canceled) {
      Navigator.of(context).pop(PurchaseCancelResult.Canceled);
    }
  }
}
