import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:provider/provider.dart';

class AddressForm extends StatefulWidget {

  final TextEditingController _nameController;
  final TextEditingController _post1Controller;
  final TextEditingController _post2Controller;
  final TextEditingController _addressController;
  final TextEditingController _buildingController;
  final TextEditingController _phoneController;


  AddressForm(this._nameController,
      this._post1Controller,
      this._post2Controller,
      this._addressController,
      this._buildingController,
      this._phoneController);

  @override
  AddressFormState createState() => AddressFormState();
}

class AddressFormState extends State<AddressForm> {

  @override
  void initState() {
    super.initState();
    // 既に保存されている配送先があれば表示する
    final userModel = Provider.of<UserModel>(context, listen: false);
    var postalCode = userModel.deliveryPostalCode;
    if (postalCode != null && postalCode.toString().isNotEmpty) {
      var postalCodes = postalCode.split('-');
      widget._post1Controller.text = postalCodes[0];
      widget._post2Controller.text = postalCodes[1];
    }
    widget._nameController.text = userModel.deliveryName;
    widget._addressController.text = userModel.deliveryAddr;
    widget._buildingController.text = userModel.deliveryBuild;
    widget._phoneController.text = userModel.deliveryPhone;
  }

  @override
  Widget build(BuildContext context) {

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Text(
        "氏名（必須）",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      SizedBox(height: 6),
      TextFormField(
        controller: widget._nameController,
        style: TextStyle(color: Colors.white),
        //validator: CustomValidator.validateNickName,
        decoration: InputDecoration(
            fillColor: Colors.white.withAlpha(20),
            filled: true,
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            //labelText: Lang.SEARCH_HINT,
            hintText: "例）山田太郎",
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
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
            child: TextFormField(
              controller: widget._post1Controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              //validator: CustomValidator.validateNickName,
              decoration: InputDecoration(
                  fillColor: Colors.white.withAlpha(20),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                  //labelText: Lang.SEARCH_HINT,
                  hintText: "000",
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            color: ColorLive.BORDER2,
            height: 1,
            width: 9,
          ),
          SizedBox(
            width: 10,
          ),
          Flexible(
            child: TextFormField(
              controller: widget._post2Controller,
               keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              //validator: CustomValidator.validateNickName,
              decoration: InputDecoration(
                  fillColor: Colors.white.withAlpha(20),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                  //labelText: Lang.SEARCH_HINT,
                  hintText: "0000",
                  labelStyle: TextStyle(color: Colors.white),
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
            ),
          ),
        ],
      ),
      SizedBox(height: 8),
      TextFormField(
        controller: widget._addressController,
        style: TextStyle(color: Colors.white),
        //validator: CustomValidator.validateNickName,
        decoration: InputDecoration(
            fillColor: Colors.white.withAlpha(20),
            filled: true,
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            //labelText: Lang.SEARCH_HINT,
            hintText: "東京都中央区銀座1-1-1",
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
      ),
      SizedBox(height: 8),
      TextFormField(
        controller: widget._buildingController,
        style: TextStyle(color: Colors.white),
        //validator: CustomValidator.validateNickName,
        decoration: InputDecoration(
            fillColor: Colors.white.withAlpha(20),
            filled: true,
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            //labelText: Lang.SEARCH_HINT,
            hintText: "〇〇マンション 101号室",
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
      ),
      SizedBox(height: 16),
      Text(
        "電話番号",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      SizedBox(height: 6),
      TextFormField(
        controller: widget._phoneController,
        style: TextStyle(color: Colors.white),
        //validator: CustomValidator.validateNickName,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            fillColor: Colors.white.withAlpha(20),
            filled: true,
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            //labelText: Lang.SEARCH_HINT,
            hintText: "例）090-0000-0000",
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
      ),
      SizedBox(height: 43),
    ]);
  }
}
