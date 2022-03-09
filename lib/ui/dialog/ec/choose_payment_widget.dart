import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/bank_billing.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/services/api_path.dart';
import 'package:live812/ui/dialog/ec/credit_card_form.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/on_memory_cache.dart';
import 'package:live812/utils/widget/primary_button.dart';

enum PaymentMethodType {
  CreditCard,
  BankTransfer,
}

class PaymentMethod {
  static const PaymentMethod creditCard = const PaymentMethod(PaymentMethodType.CreditCard);

  final PaymentMethodType type;
  final BankBilling bankBilling;

  const PaymentMethod(this.type, [this.bankBilling]);

  @override
  bool operator ==(Object other) {
    if (other is PaymentMethod) {
      return type == other.type &&
          !(type == PaymentMethodType.BankTransfer && bankBilling.id != other.bankBilling.id);
    }
    return false;
  }

  @override
  int get hashCode => type.hashCode ^ (bankBilling?.id ?? 0);

  @override
  String toString() {
    return 'PaymentMethod{type=$type, bankId=$bankBilling?.id}';
  }
}

// お支払い方法選択
class ChoosePaymentWidget extends StatefulWidget {
  final PaymentMethod paymentMethod;
  final CreditCardInfo creditCardInfo;
  final void Function(PaymentMethod, bool) onSelected;
  final void Function() onChooseCreditCard;

  ChoosePaymentWidget({
    @required this.paymentMethod, @required this.creditCardInfo,
    @required this.onSelected,
    @required this.onChooseCreditCard,
  });

  @override
  _ChoosePaymentWidgetState createState() => _ChoosePaymentWidgetState();
}

class _ChoosePaymentWidgetState extends State<ChoosePaymentWidget> {
  List<BankBilling> _bankBillingList;
  bool _bankBillingLoading = true;

  @override
  void initState() {
    super.initState();
    _requestBillingInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('クレジットカード', style: TextStyle(fontWeight: FontWeight.bold)),
                      RadioListTile(
                        activeColor: Colors.blue,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: InkWell(
                          onTap: () {
                            widget.onChooseCreditCard();
                          },
                          child: _buildCreditCardText(context),
                        ),
                        value: PaymentMethod.creditCard,
                        groupValue: widget.paymentMethod,
                        onChanged: _handlePaymentTypeRadio,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('銀行振込', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildBankRadioList(),
                      Container(
                        margin: EdgeInsets.only(top: 5, left: 20, right: 20),
                        child: Text(
                          '銀行振込の場合、ご入金の確認が取れてから反映までに最大３営業日かかる場合がございます。速やかに入金をお願いします（推奨３日）',
                          style: TextStyle(fontSize: 14, color: Color(0xff606060)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        PrimaryButton(
          text: Lang.DECIDE,
          onPressed: widget.paymentMethod == null ? null : () {
            widget.onSelected(widget.paymentMethod, true);
          },
        ),
      ],
    );
  }

  Widget _buildBankRadioList() {
    if (_bankBillingLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Text(
          '読込中',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_bankBillingList == null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Text(
          '読込に失敗しました',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: _bankBillingList.map((bankBilling) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RadioListTile(
              activeColor: Colors.blue,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(bankBilling.bankName ?? '?'),
              value: PaymentMethod(PaymentMethodType.BankTransfer, bankBilling),
              groupValue: widget.paymentMethod,
              onChanged: _handlePaymentTypeRadio,
            ),
            widget.paymentMethod?.bankBilling?.id != bankBilling.id ? Container() : Container(
              margin: EdgeInsets.only(left: 90, right: 15),
              child: Text(
                '${bankBilling.branch}\n${bankBilling.type} ${bankBilling.accountNumber}\n${bankBilling.accountName}',
                style: TextStyle(fontSize: 14, color: Color(0xff666666)),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCreditCardText(BuildContext context) {
    if (widget.creditCardInfo == null) {
      return const Text('クレジットカード情報を入力');
    }
    return Text(
      maskCreditCardNumber(widget.creditCardInfo.number),
      textAlign: TextAlign.start,
      overflow: TextOverflow.ellipsis,
    );
  }

  String maskCreditCardNumber(String cardnumber){
        return '************' + cardnumber.substring(cardnumber.length - 4, cardnumber.length);
  }

  void _handlePaymentTypeRadio(PaymentMethod method) {
    widget.onSelected(method, false);
    if (method.type == PaymentMethodType.CreditCard && widget.creditCardInfo == null) {
      widget.onChooseCreditCard();
    }
  }

  Future<void> _requestBillingInfo() async {
    // API呼び出し
    final response = await OnMemoryCache.fetch(ApiPath.bankBillingInfo, Duration(days: 1), () async {
      final service = BackendService(context);
      final response = await service.getBankBillingInfo();
      return response?.result == true ? response : null;
    });
    setState(() => _bankBillingLoading = false);

    if (response != null) {
      final data = response.getData();
      if (data != null && !data.isEmpty) {
        final list = List<BankBilling>();
        data.forEach((item) => list.add(BankBilling.fromJson(item)));
        setState(() {
          _bankBillingList = list;
        });
      }
    }
  }
}
