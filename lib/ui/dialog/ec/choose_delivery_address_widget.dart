import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/delivery_address.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/primary_button.dart';

// 配送先住所選択
class ChooseDeliveryAddressWidget extends StatelessWidget {
  final List<DeliveryAddress> deliveryAddressList;
  final DeliveryAddress deliveryAddress;
  final void Function(int) onSelect;
  final void Function(DeliveryAddress) editDeliveryAddress;
  final void Function(DeliveryAddress) onDecide;

  ChooseDeliveryAddressWidget(
    this.deliveryAddressList,
    {
      @required this.deliveryAddress,
      @required this.onSelect,
      @required this.editDeliveryAddress,
      @required this.onDecide,
    }
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> addressWidgets;
    if ((deliveryAddressList != null) && (deliveryAddressList.length > 0)) {
      addressWidgets = deliveryAddressList.map<Widget>((adr) {
        return _buildAddressRow(context, adr);
      }).toList();
    } else {
      addressWidgets = [
        _rowContainer(
          child: Container(
            height: 80,
            child: Center(
              child: Text(
                '登録されている配送先はありません',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ];
    }
    final List<Widget> addButton = [
      (deliveryAddressList?.length ?? 0) < Consts.MAX_DELIVERY_ADDRESS
          ? _whiteButton(
              onPressed: () {
                editDeliveryAddress(null);
              },
            )
          : Container()
    ];

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: addressWidgets + addButton,
            ),
          ),
        ),
        PrimaryButton(
          text: Lang.DECIDE,
          onPressed: deliveryAddress == null ? null : () {
            onDecide(deliveryAddress);
          },
        ),
      ],
    );
  }

  Widget _buildAddressRow(BuildContext context, DeliveryAddress adr) {
    return  _rowContainer(
      child: RadioListTile(
        value: adr.id,
        groupValue: deliveryAddress?.id,
        title: InkWell(
          onTap: () {
            editDeliveryAddress(adr);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(adr.name, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Text('〒${adr.post1}-${adr.post2}'),
              Text('${adr.address} ${adr.building}'),
              Text('${adr.phone}'),
            ],
          ),
        ),
        onChanged: (int selectedId) {
          onSelect(deliveryAddressList.indexWhere((a) => a.id == selectedId));
        },
      ),
    );
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
}

Widget _whiteButton({void Function() onPressed}) {
  return Container(
    width: double.infinity,
    height: 60,
    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(30)),
      border: Border.all(color: Colors.black),
    ),
    child: FlatButton(
      textColor: Colors.white,
      onPressed: onPressed,
      child: Text(
        '配送先を追加',
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    ),
  );
}
