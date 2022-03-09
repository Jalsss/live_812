import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/ec/credit_payment_result.dart';
import 'package:live812/domain/model/ec/delivery_address.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/json_data.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/repository/persistent_repository.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/product_usecase.dart';
import 'package:live812/ui/dialog/ec/choose_delivery_address_widget.dart';
import 'package:live812/ui/dialog/ec/choose_payment_widget.dart';
import 'package:live812/ui/dialog/ec/credit_card_form.dart';
import 'package:live812/ui/dialog/ec/edit_delivery_address_widget.dart';
import 'package:live812/utils/comma_format.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/result.dart';
import 'package:live812/utils/widget/dialog_with_padding.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:provider/provider.dart';

enum BuyProductDialogResult {
  PURCHASED,
  PURCHASED_AND_GOTO_HISTORY_PAGE,
}

const int _ANIMATION_DURATION = 300;

enum _PageType {
  TOP,
  CHOOSE_DELIVERY_ADDRESS,
  EDIT_DELIVERY_ADDRESS,
  CHOOSE_PAYMENT_METHOD,
  EDIT_CREDIT_CARD_INFO,
  PURCHASE_BY_CREDIT_CARD_SUCCESS,
  PURCHASE_BY_BANK_TRANSFTER_SUCCESS,
}

// 商品購入ダイアログ
// 購入した場合には
//   BuyProductDialogResult.PURCHASE, または
//   BuyProductDialogResult.PURCHASE_AND_GOTO_HISTORY_PAGE
// を返す
class BuyProductDialog extends StatefulWidget {
  final Product product;
  final String provideUserId;
  final bool isInLiveRoom; // ライブルームからか？（falseなら他（マイページ）から）

  BuyProductDialog(
      {@required this.product,
      @required this.provideUserId,
      @required this.isInLiveRoom});

  @override
  _BuyProductDialogState createState() => _BuyProductDialogState();
}

class _BuyProductDialogState extends State<BuyProductDialog> {
  PageController _pageController;
  bool _isLoading = false;
  dynamic _bankPurchaseInfo;
  CreditPaymentSuccess _creditPaymentInfo;
  bool _disableBackKey = false; // Androidで課金処理時にバックキーを無効にする
  bool _purchaseSucceded = false;
  List<_PageType> _pages;
  int _currentPage = 0;

  PaymentMethod _paymentMethod;
  PaymentMethod _tmpPaymentMethod; // 決定前・選択途中のお支払い方法
  CreditCardInfo _creditCardInfo;
  List<DeliveryAddress> _deliveryAddressList;
  DeliveryAddress _deliveryAddress;
  DeliveryAddress _tmpDeliveryAddress;
  DeliveryAddress _editingAddress;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, keepPage: true);
    _pages = List.generate(3, (i) => i == 0 ? _PageType.TOP : null);

    _getDeliveryAddressList();
  }

  Future<void> _getDeliveryAddressList() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    // ローカルからデータを取得.
    final repo = Injector.getInjector().get<PersistentRepository>();
    final list = await repo.getDeliveryAddressList();

    // ローカルのデータをサーバーに登録.
    var service = BackendService(context);
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        print(list[i].toString());
        final postResponse = await service.postUserDeliveryAddress(
          name: list[i].name,
          postalCode: list[i].post1 + "-" + list[i].post2,
          address: list[i].address,
          building: list[i].building,
          phoneNumber: list[i].phone,
        );
        if (postResponse?.result ?? false) {
          // 削除.
          repo.deleteDeliveryAddress(list[i].id);
        }
      }
    }

    // サーバーから一覧を取得.
    final response = await service.getUserDeliveryAddress();
    if (response.result ?? false) {
      List<dynamic> dataList = response.getData();
      _deliveryAddressList =
          dataList.map((x) => DeliveryAddress.fromJson(x)).toList();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final portrait = mq.size.height > mq.size.width;
    EdgeInsets padding;
    if (portrait) {
      if (widget.isInLiveRoom) {
        padding = EdgeInsets.fromLTRB(8, 180, 8, 16);
      } else {
        padding = EdgeInsets.symmetric(horizontal: 8, vertical: 16);
      }
    } else {
      padding = const EdgeInsets.symmetric(horizontal: 32);
    }

    return WillPopScope(
      onWillPop: () async {
        if (_disableBackKey || _isLoading) return false;
        if (_purchaseSucceded || _currentPage <= 0) return true;
        _popPage();
        return false;
      },
      child: DialogWithPadding(
        elevation: 0.0,
        padding: mq.viewInsets + padding,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: PageView.builder(
            // builderじゃないと、_pagesの中身の変更が反映されない
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              switch (_pages[index]) {
                case _PageType.CHOOSE_DELIVERY_ADDRESS:
                  return _dialogContentChooseDeliveryAddress(context);
                case _PageType.EDIT_DELIVERY_ADDRESS:
                  return _dialogContentEditDeliveryAddress(context);
                case _PageType.CHOOSE_PAYMENT_METHOD:
                  return _dialogContentChoosePayment(context);
                case _PageType.EDIT_CREDIT_CARD_INFO:
                  return _dialogContentCreditCardForm(context);
                case _PageType.PURCHASE_BY_CREDIT_CARD_SUCCESS:
                  return _dialogCardSuccess(context);
                case _PageType.PURCHASE_BY_BANK_TRANSFTER_SUCCESS:
                  return _dialogBankSuccess(context);
                case _PageType.TOP:
                default:
                  return _dialogMain(context);
              }
            },
          ),
        ),
      ),
    );
  }

  void _pushPage(_PageType type) {
    setState(() {
      ++_currentPage;
      _pages[_currentPage] = type;
    });
    _pageController.animateToPage(_currentPage,
        duration: Duration(milliseconds: _ANIMATION_DURATION),
        curve: Curves.easeInOut);
  }

  void _popPage() {
    KeyboardUtil.close(context);
    setState(() {
      --_currentPage;
    });
    _pageController.animateToPage(_currentPage,
        duration: Duration(milliseconds: _ANIMATION_DURATION),
        curve: Curves.easeInOut);
  }

  Widget _dialogPage({
    @required String title,
    @required Widget child,
    @required void Function() onBackIconPressed,
    Widget action,
  }) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: ColorLive.BG2,
                ),
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 50,
                        child: MaterialButton(
                          minWidth: 50,
                          padding: EdgeInsets.all(0),
                          child: SvgPicture.asset("assets/svg/backButton.svg"),
                          onPressed: onBackIconPressed,
                        ),
                      ),
                    ),
                    action == null
                        ? null
                        : Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              height: 50,
                              child: action,
                            ),
                          ),
                  ].where((w) => w != null).toList(),
                ),
              ),
              Divider(
                color: ColorLive.BORDER4,
                thickness: 1,
                height: 1,
              ),
              Expanded(
                child: child,
              ),
            ],
          ),
          !_isLoading ? null : SpinningIndicator(),
        ].where((w) => w != null).toList(),
      ),
    );
  }

  Widget _dialogMain(BuildContext context) {
    return _dialogPage(
      title: Lang.PURCHASE,
      onBackIconPressed: () {
        Navigator.of(context).pop();
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    _rowContainer(
                      child: _buildProductRow(context),
                    ),
                    _selectorRowContainer(
                      title: '配送先',
                      content: _buildDeliveryAddress(context),
                      onTap: () {
                        setState(() => _tmpDeliveryAddress = _deliveryAddress);
                        _pushPage(_PageType.CHOOSE_DELIVERY_ADDRESS);
                      },
                    ),
                    _selectorRowContainer(
                      title: 'お支払い方法',
                      content: _buildPaymentMethod(context),
                      onTap: () {
                        _tmpPaymentMethod = _paymentMethod;
                        _pushPage(_PageType.CHOOSE_PAYMENT_METHOD);
                      },
                    ),
                    _rowContainer(
                      child: Row(
                        children: [
                          Text('お支払い金額',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '送料込み',
                                textAlign: TextAlign.end,
                                style: TextStyle(color: ColorLive.BLUE),
                              ),
                            ),
                          ),
                          Text(
                            '¥ ${commaFormat(widget.product.price)}',
                            textAlign: TextAlign.end,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 15.0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          Lang.HINT_PRODUCT_PURCHASE,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          maxLines: 2,
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PrimaryButton(
            text: Lang.PURCHASE,
            onPressed: _deliveryAddress == null || _paymentMethod == null
                ? null
                : _confirmPurchase,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(BuildContext context) {
    if (_deliveryAddress == null) {
      return Text(
        '配送先を追加',
        style: TextStyle(color: Colors.red),
        textAlign: TextAlign.end,
        maxLines: 1,
      );
    } else {
      return Text(
        '${_deliveryAddress.address}',
        textAlign: TextAlign.end,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget _buildPaymentMethod(BuildContext context) {
    switch (_paymentMethod?.type) {
      case PaymentMethodType.CreditCard:
        return Text(
          'クレジットカード',
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        );
      case PaymentMethodType.BankTransfer:
        return Text(
          _paymentMethod.bankBilling.bankName,
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        );
      default:
        return Text(
          'お支払い方法を追加',
          style: TextStyle(color: Colors.red),
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
        );
    }
  }

  Widget _rowContainer({@required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: child,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ColorLive.DIVIDER, width: 1)),
      ),
    );
  }

  Widget _selectorRowContainer({
    @required String title,
    @required Widget content,
    void Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: _rowContainer(
        child: Row(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: content,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: ColorLive.ORANGE,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 100, width: 100, child: _imageWidget()),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children : [
              widget.product.customerUserId != null
                  ? Text(
                      "${widget.product.customerUserName}様専用商品です",
                      overflow: TextOverflow.ellipsis,
                    )
                  : Container(),
              Text(
                widget.product.name,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 配送先選択
  Widget _dialogContentChooseDeliveryAddress(BuildContext context) {
    return _dialogPage(
      title: '配送先',
      onBackIconPressed: () => _popPage(),
      child: ChooseDeliveryAddressWidget(
        _deliveryAddressList,
        deliveryAddress: _tmpDeliveryAddress,
        onSelect: (index) {
          setState(() => _tmpDeliveryAddress = _deliveryAddressList[index]);
        },
        editDeliveryAddress: (DeliveryAddress address) {
          _editingAddress = address;
          _pushPage(_PageType.EDIT_DELIVERY_ADDRESS);
        },
        onDecide: (adr) {
          setState(() => _deliveryAddress = adr);
          _popPage();
        },
      ),
    );
  }

  // 配送先編集（または追加）
  Widget _dialogContentEditDeliveryAddress(BuildContext context) {
    return _dialogPage(
      title: _editingAddress == null ? '配送先を追加' : '配送先を編集',
      onBackIconPressed: () => _popPage(),
      action: _editingAddress == null
          ? null
          : IconButton(
              icon: Icon(Icons.delete),
              color: Colors.blue,
              onPressed: () async {
                // 削除.
                setState(() {
                  _isLoading = true;
                });
                final service = BackendService(context);
                final response = await service.deleteUserDeliveryAddress(
                  id: _editingAddress.id,
                );
                setState(() {
                  _isLoading = false;
                });
                if (response?.result ?? false) {
                  await _getDeliveryAddressList();
                  setState(() {
                    // 削除されたものが選択されていたら解除する
                    if (_tmpDeliveryAddress?.id == _editingAddress?.id) {
                      _tmpDeliveryAddress = null;
                    }
                    if (_deliveryAddress?.id == _editingAddress?.id) {
                      _deliveryAddress = null;
                    }
                    _editingAddress = null;
                  });
                  _popPage();
                }
              },
            ),
      child: EditDeliveryAddressWidget(
        _editingAddress,
        key: ValueKey(_editingAddress),
        onDecide: (id) async {
          await _getDeliveryAddressList();
          setState(() {
            if (id != null) {
              // 編集.
              _tmpDeliveryAddress = _deliveryAddressList
                  ?.firstWhere((a) => a.id == id, orElse: () => null);
            } else {
              // 新規追加.
              _tmpDeliveryAddress = _deliveryAddressList?.last ?? null;
            }
          });
          _popPage();
        },
        onLoading: (isLoading) {
          setState(() {
            _isLoading = isLoading;
          });
        },
      ),
    );
  }

  // お支払い方法選択
  Widget _dialogContentChoosePayment(BuildContext context) {
    return _dialogPage(
      title: 'お支払い方法',
      onBackIconPressed: () => _popPage(),
      child: ChoosePaymentWidget(
        paymentMethod: _tmpPaymentMethod,
        creditCardInfo: _creditCardInfo,
        onSelected: (PaymentMethod method, bool decide) {
          if (decide) {
            setState(() => _paymentMethod = method);
            _popPage();
          } else {
            setState(() => _tmpPaymentMethod = method);
          }
        },
        onChooseCreditCard: () {
          _pushPage(_PageType.EDIT_CREDIT_CARD_INFO);
        },
      ),
    );
  }

  Widget _dialogContentCreditCardForm(BuildContext context) {
    return _dialogPage(
      title: 'クレジットカード情報入力',
      onBackIconPressed: () {
        _popPage();
        // キャンセル：カード情報が入力されている場合にはクレジットカードを選択する
        if (_creditCardInfo != null) {
          setState(() => _tmpPaymentMethod = PaymentMethod.creditCard);
        }
      },
      child: CreditCardForm(
        cardInfo: _creditCardInfo,
        onDecide: (CreditCardInfo cardInfo) {
          setState(() {
            _creditCardInfo = cardInfo;
            _tmpPaymentMethod = PaymentMethod.creditCard;
          });
          _popPage();
        },
      ),
    );
  }

  Widget _imageWidget() {
    if (widget.product.imgUrlList == null ||
        widget.product.imgUrlList.length == 0) {
      return Container(
        child: Center(
          child: Text(Lang.NO_IMAGE),
        ),
      );
    }

    return FadeInImage.assetNetwork(
        placeholder: "assets/images/placeholder.png",
        image: widget.product.imgUrlList[0]);
  }

  // 銀行振込で購入
  Future<void> _validatePurchaseBank() async {
    final response = await _requestBankPurchase();
    if (response.result == true) {
      setState(() {
        _purchaseSucceded = true;
        _bankPurchaseInfo = response.getData();
      });

      // TODO: 失敗した場合の処理
      // await _postDeliveryAddress(_bankPurchaseInfo['order_id']);

      _pushPage(_PageType.PURCHASE_BY_BANK_TRANSFTER_SUCCESS);
    } else {
      await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('取引に失敗しました'),
              content:
                  Text('${response.getByKey('reason') ?? '不明なエラーが発生しました'}'),
              actions: <Widget>[
                FlatButton(
                  child: Text('閉じる'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
  }

  Future<void> _confirmPurchase() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('購入'),
          content: Text('購入します。宜しいですか？'),
          actions: [
            FlatButton(
              child: Text('いいえ'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text('はい'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _startPurchase();
    }
  }

  Future<void> _startPurchase() async {
    switch (_paymentMethod.type) {
      case PaymentMethodType.CreditCard:
        {
          final result = await _startCreditPayment(_creditCardInfo.number,
              _creditCardInfo.expireDate, _creditCardInfo.securityCode);
          if (result) {
            setState(() => _purchaseSucceded = true);

            // TODO: 失敗したときの処理
            // _postDeliveryAddress(_creditPaymentInfo.apiResponse.getByKey('order_id'));

            _pushPage(_PageType.PURCHASE_BY_CREDIT_CARD_SUCCESS);
          }
        }
        break;
      case PaymentMethodType.BankTransfer:
        await _validatePurchaseBank();
        break;
    }
  }

  Future<dynamic> _requestBankPurchase() async {
    setState(() => _isLoading = _disableBackKey = true);
    // API呼び出し
    final service = BackendService(context);
    final response = await service.postBankBilling(
        itemId: widget.product.itemId,
        bankId: _paymentMethod.bankBilling.id,
        deliveryAddress: _deliveryAddress);
    setState(() {
      _isLoading = _disableBackKey = false;
    });

    if (response?.result != true) {
      String reason = response?.getByKey('msg') ?? '情報の取得に失敗しました';
      return JsonData.fromMap({
        'result': false,
        'reason': reason,
      });
    }
    return response;
  }

  // クレジットカード決済フロー
  Future<bool> _startCreditPayment(
      String cardNumber, String expireDate, String securityCode) async {
    final result =
        await _requestCreditBilling(cardNumber, expireDate, securityCode);
    return result.match(
      ok: (CreditPaymentSuccess success) async {
        _creditPaymentInfo = success;
        return true;
      },
      err: (CreditPaymentFailed failed) async {
        // TODO: クレジット決済には成功していて、結果をAPIサーバに送信時に失敗した場合の処理
        await _showCreditPaymentFailed(failed);
        return false;
      },
    );
  }

  // クレジットカード決済成功失敗
  Future<void> _showCreditPaymentFailed(CreditPaymentFailed result) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(Lang.PAYMENT_FAILED),
          content: Text(
            'クレジット決済に失敗しました\n' +
                (result?.errorCode != null
                    ? 'エラーコード：${result?.errorCode}\n'
                    : '') +
                'エラー内容：${result?.errorMessage}',
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(Lang.CLOSE),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  // クレジットカード決済
  Future<Result<CreditPaymentSuccess, CreditPaymentFailed>>
      _requestCreditBilling(
          String cardNumber, String expireDate, String securityCode) async {
    setState(() {
      _isLoading = _disableBackKey = true;
    });
    // API呼び出し
    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);

    final result = await ProductUsecase.requestCreditBilling(
      cardNumber: cardNumber,
      expireDate: expireDate,
      securityCode: securityCode,
      productId: widget.product.itemId,
      deliveryAddress: _deliveryAddress,
      userModel: userModel,
      backendService: service,
    ).timeout(Duration(seconds: 20)).catchError((e) {
      return Future.value(Err(CreditPaymentFailed(
        type: CreditPaymentFailedType.UNKNOWN_FAILED,
        errorCode: null,
        errorMessage: 'エラーが発生しました',
      )));
    });

    setState(() {
      _isLoading = _disableBackKey = false;
    });
    return result;
  }

  Widget _dialogCardSuccess(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: ListView(
                    children: <Widget>[
                      SizedBox(height: 30),
                      Text(
                        Lang.THANK_YOU,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 22),
                      Text(
                        "「${widget.product.name}」の購入が完了しました",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "取引ID：${_creditPaymentInfo.apiResponse.getByKey('order_id') ?? ''}",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 60),
                      SvgPicture.asset(
                        "assets/svg/delivery.svg",
                        height: 30,
                      ),
                      SizedBox(height: 22),
                      Text(
                        "マイページの購入履歴から\n配送先情報などを入力しましょう",
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 22),
                      FlatButton(
                        child: Text(
                          _getPurchasedCloseText(),
                          style:
                              TextStyle(decoration: TextDecoration.underline),
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .pop(BuyProductDialogResult.PURCHASED);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                text: Lang.TO_PURCHASE_HISTORY,
                onPressed: () {
                  Navigator.of(context).pop(
                      BuyProductDialogResult.PURCHASED_AND_GOTO_HISTORY_PAGE);
                },
                height: 50,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dialogBankSuccess(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, userModel, _) {
        return Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: ListView(
                        children: <Widget>[
                          SizedBox(height: 20),
                          Text(
                            Lang.THANK_YOU,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "「${widget.product.name}」の購入が完了しました",
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "取引ID : ${_bankPurchaseInfo['order_id']}",
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                          Container(
                            color: ColorLive.PINK,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "【お振込み先情報】",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '${_bankPurchaseInfo['bank_name']}\n${_bankPurchaseInfo['branch_name']}\n${_bankPurchaseInfo['type']} ${_bankPurchaseInfo['num']}\n${_bankPurchaseInfo['name']}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "【振込人名義】",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "${_bankPurchaseInfo['order_id']} ${_deliveryAddress.name}",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 18),
                                Text(
                                  "振込期限：${_formatExpireDate(_bankPurchaseInfo['expire_date']) ?? '??'}",
                                  style: TextStyle(color: Colors.yellow),
                                ),
                                SizedBox(height: 16),
                                Divider(
                                  color: Colors.white,
                                  height: 2,
                                  thickness: 1,
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                          text:
                                              'お振込みの際には、振込依頼人名の前に8桁の取引IDを必ず記載してください。取引IDの記載を忘れますとご入金の確認が取れません。'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 22),
                          FlatButton(
                            child: Text(
                              _getPurchasedCloseText(),
                              style: TextStyle(
                                  decoration: TextDecoration.underline),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(BuyProductDialogResult.PURCHASED);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  PrimaryButton(
                    text: Lang.TO_PURCHASE_HISTORY,
                    onPressed: () {
                      Navigator.of(context).pop(BuyProductDialogResult
                          .PURCHASED_AND_GOTO_HISTORY_PAGE);
                    },
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatExpireDate(String date) {
    if (date == null) return null;
    return dateFormatJp(DateTime.parse(date));
  }

  // 購入に成功し、閉じる文言
  String _getPurchasedCloseText() {
    return widget.isInLiveRoom ? 'いまは視聴を続ける' : '閉じる';
  }

  // 配送先住所を送る
  Future<bool> _postDeliveryAddress(String _orderId) async {
    final postalCode = '${_deliveryAddress.post1}-${_deliveryAddress.post2}';

    final service = BackendService(context);
    setState(() => _isLoading = true);
    final response = await service.postPurchaseDelivery(
        itemId: widget.product.itemId,
        updateInfo: true,
        deliveryName: _deliveryAddress.name,
        deliveryPostalCode: postalCode,
        deliveryAddr: _deliveryAddress.address,
        deliveryBuild: _deliveryAddress.building,
        deliveryPhone: _deliveryAddress.phone);
    setState(() => _isLoading = false);

    return response?.result == true;
  }
}
