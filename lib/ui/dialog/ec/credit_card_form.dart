import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/utils/credit_card_util.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/primary_button.dart';

// クレジットカード情報
class CreditCardInfo {
  final String number;
  final String expireDate;
  final String securityCode;

  CreditCardInfo({this.number, this.expireDate, this.securityCode});

  String toString() {
    return 'CreditCardInfo{number=$number, expireDate=$expireDate, securityCode=$securityCode}';
  }
}

class CreditCardForm extends StatefulWidget {
  final CreditCardInfo cardInfo;
  final void Function(CreditCardInfo) onDecide;

  CreditCardForm({@required this.cardInfo, @required this.onDecide});

  @override
  CreditCardFormState createState() => CreditCardFormState();
}

class CreditCardFormState extends State<CreditCardForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _cardNumberController;
  // TextEditingController _expireDateController;
  TextEditingController _expireMonthController;
  TextEditingController _expireYearController;
  TextEditingController _securityCodeController;
  bool _autoValidate = false;
  String _oldExpireDate = '';
  bool _enableDecideButton = false;

  // 有効期限の値を変更する際に、onChangedが何度も呼び出されておかしくなるのを防止
  bool _suppressExpireDateAdjustment = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    // _expireDateController.dispose();
    _expireMonthController.dispose();
    _expireYearController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final tuple =
    CreditCardUtil.extractExpireYearMonth(widget.cardInfo?.expireDate);

    // var mmyy;
    var month;
    var year;
    if (tuple != null) {
      // mmyy = tuple.item2.toString() + "/" + tuple.item1.toString();
      month = tuple.item2.toString();
      year = tuple.item1.toString();
    }
    super.initState();
    _cardNumberController =
        TextEditingController(text: widget.cardInfo?.number);
    // _expireDateController = TextEditingController(text: mmyy);
    _expireMonthController = TextEditingController(text: month);
    _expireYearController = TextEditingController(text: year);
    _securityCodeController =
        TextEditingController(text: widget.cardInfo?.securityCode);
    _enableDecideButton = widget.cardInfo != null;
  }

  @override
  Widget build(BuildContext context) {
    final decideButton = PrimaryButton(
      text: Lang.DECIDE,
      onPressed: !_enableDecideButton ? null : _validatePurchase,
      height: 50,
    );

    // 横画面ライブ中の場合にソフトキーボードが表示されると表示領域の高さが狭すぎるので、
    // 決定ボタンをダイアログ下部固定じゃなくスクロール領域に表示する。
    // 縦画面の場合にはダイアログ下部に固定。

    return OrientationBuilder(builder: (context, orientation) {
      return Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Form(
                    key: _formKey,
                    autovalidate: _autoValidate,
                    child: Container(
                      margin: EdgeInsets.all(15),
                      child: Column(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "クレジットカード番号 *",
                            ),
                          ),
                          SizedBox(height: 6),
                          TextFormField(
                            controller: _cardNumberController,
                            validator: CustomValidator.validateNumber,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "0000 0000 0000 0000",
                              counterText: '',
                            ),
                            maxLength: 19, // 16だけど、一応余裕を持たせてみる
                            onChanged: (_) => _onChanged(),
                          ),
                          SizedBox(height: 8),
                          SvgPicture.asset('assets/svg/credit.svg'),
                          SizedBox(height: 20),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "有効期限 *",
                            ),
                          ),
                          SizedBox(height: 6),
                          // TextFormField(
                          //   controller: _expireDateController,
                          //   validator: _validateExpireDate,
                          //   keyboardType: TextInputType.number,
                          //   textInputAction: TextInputAction.done,
                          //   decoration: InputDecoration(
                          //     border: OutlineInputBorder(),
                          //     hintText: "MM/YY",
                          //     counterText: '',
                          //   ),
                          //   onChanged: _updateExpireDate,
                          //   maxLength: 5,
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Flexible(
                                child: TextFormField(
                                  controller: _expireMonthController,
                                  validator: _validateExpireMonth,
                                  autovalidate: true,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "MM",
                                    counterText: '',
                                  ),
                                  onChanged: _updateExpireMonth,
                                  maxLength: 2,
                                ),
                              ),
                              Text(' / '),
                              Flexible(
                                child: TextFormField(
                                  controller: _expireYearController,
                                  validator: _validateExpireYear,
                                  autovalidate: true,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "YY",
                                    counterText: '',
                                  ),
                                  onChanged: _updateExpireYear,
                                  maxLength: 2,
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "セキュリティコード *",
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SvgPicture.asset("assets/svg/answer.svg")
                            ],
                          ),
                          SizedBox(height: 6),
                          TextFormField(
                            controller: _securityCodeController,
                            validator: CustomValidator.validateNumber,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                            maxLength: 5, // 3だけど、一応余裕を持たせてみる
                            onChanged: (_) => _onChanged(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  orientation == Orientation.portrait ? null : decideButton,
                ].where((w) => w != null).toList(),
              ),
            ),
          ),
          orientation == Orientation.landscape ? null : decideButton,
        ].where((w) => w != null).toList(),
      );
    });
  }

  void _onChanged() {
    setState(() {
      _enableDecideButton = _cardNumberController.text.isNotEmpty &&
          // _expireDateController.text.isNotEmpty &&
          _expireMonthController.text.isNotEmpty &&
          _expireYearController.text.isNotEmpty &&
          _securityCodeController.text.isNotEmpty;
    });
  }

  // void _updateExpireDate(String newValue) {
  //   _onChanged();
  //   if (_suppressExpireDateAdjustment)
  //     return;

  //   const SLASH_POS = 2;
  //   String modified = newValue;
  //   int cursorIndex = _expireDateController.selection.baseOffset;
  //   if (newValue.length <= _oldExpireDate.length) {
  //     // 自動挿入のスラッシュが削除された場合、その前の文字も削除してやる
  //     if (newValue.length == _oldExpireDate.length - 1 && _oldExpireDate[cursorIndex] == '/') {
  //       modified = newValue.substring(0, cursorIndex - 1) + newValue.substring(cursorIndex);
  //       --cursorIndex;
  //     }
  //   } else {
  //     if (cursorIndex == SLASH_POS || cursorIndex == SLASH_POS + 1)
  //       ++cursorIndex;
  //   }

  //   // 2桁＋残り、間にスラッシュを自動挿入
  //   final nums = modified.replaceAll(RegExp(r'[^\d]'), '');
  //   modified = nums.length < SLASH_POS ? nums : '${nums.substring(0, SLASH_POS)}/${nums.substring(SLASH_POS)}';
  //   _oldExpireDate = modified;
  //   if (modified != newValue) {
  //     // 入力値の補正で再度onChangedが呼び出されてしまうので、ブロックする
  //     _suppressExpireDateAdjustment = true;
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       _suppressExpireDateAdjustment = false;
  //     });

  //     cursorIndex = min(cursorIndex ?? modified.length, modified.length);
  //     _expireDateController.value = TextEditingValue(
  //       text: modified,
  //       selection: TextSelection.collapsed(offset: cursorIndex),
  //       composing: TextRange.empty,
  //     );
  //   }
  // }

  void _updateExpireMonth(String newValue) {
    _onChanged();
  }

  void _updateExpireYear(String newValue) {
    _onChanged();
  }

  void _validatePurchase() {
    if (_formKey.currentState.validate()) {
      final cardNumber = _cardNumberController.text;
      //final expireDate = _expireDateController.text;
      final securityCode = _securityCodeController.text;
      final month = (_expireMonthController.text.length != 1)
          ? _expireMonthController.text
          : "0" + _expireMonthController.text;
      final expireDate = CreditCardUtil.constructExpireYearMonth(
          month + "/" + _expireYearController.text,
          DateTime.now());
      widget.onDecide(CreditCardInfo(
          number: cardNumber,
          expireDate: expireDate,
          securityCode: securityCode));
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }
}

// String _validateExpireDate(String expireDate) {
//   final tuple = CreditCardUtil.extractExpireMonthYear(expireDate);
//   if (tuple != null) {
//     final m = tuple.item1;
//     if (m >= 1 && m <= 12)
//       return null;
//   }
//   return '月2ケタ、西暦2ケタを入力して下さい';
// }

String _validateExpireMonth(String expireMonth) {
  final m = int.tryParse(expireMonth);
  if (expireMonth.isEmpty) return null;
  if (m != null && m >= 1 && m <= 12) return null;
  return '不正な月です';
}

String _validateExpireYear(String expireYear) {
  final m = int.tryParse(expireYear);
  if (expireYear.isEmpty) return null;
  if (m != null && m >= 21 && m <= 50) return null;
  return '不正な年です';
}
