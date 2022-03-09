import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/model/ec/delivery_address.dart';
import 'package:live812/domain/repository/persistent_repository.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/postal_code_util.dart';
import 'package:live812/utils/widget/primary_button.dart';

// 配送先住所編集（または追加）
class EditDeliveryAddressWidget extends StatefulWidget {
  final DeliveryAddress address;
  final void Function(int) onDecide;
  final void Function(bool) onLoading;

  EditDeliveryAddressWidget(
    this.address, {
    key: Key,
    @required this.onDecide,
    @required this.onLoading,
  }) : super(key: key);

  @override
  _EditDeliveryAddressWidgetState createState() =>
      _EditDeliveryAddressWidgetState();
}

class _EditDeliveryAddressWidgetState extends State<EditDeliveryAddressWidget> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController;
  TextEditingController _post1Controller;
  TextEditingController _post2Controller;
  TextEditingController _addressController;
  TextEditingController _buildingController;
  TextEditingController _phoneController;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name);
    _post1Controller = TextEditingController(text: widget.address?.post1);
    _post2Controller = TextEditingController(text: widget.address?.post2);
    _addressController = TextEditingController(text: widget.address?.address);
    _buildingController = TextEditingController(text: widget.address?.building);
    _phoneController = TextEditingController(text: widget.address?.phone);
  }

  @override
  Widget build(BuildContext context) {
    final addButton = PrimaryButton(
      text: widget.address == null ? Lang.ADD : Lang.DECIDE,
      onPressed: _validateInputs,
    );

    // 横画面ライブ中の場合にソフトキーボードが表示されると表示領域の高さが狭すぎるので、
    // 追加ボタンをダイアログ下部固定じゃなくスクロール領域に表示する。
    // 縦画面の場合にはダイアログ下部に固定。

    return OrientationBuilder(builder: (context, orientation) {
      return Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: DefaultTextStyle(
                style: TextStyle(color: Colors.black),
                child: Column(
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: Container(
                        margin: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('氏名'),
                            SizedBox(height: 6),
                            _buildTextFormField(
                              controller: _nameController,
                              validator: CustomValidator.validateRealName,
                              hintText: '例）山田太郎',
                            ),
                            SizedBox(height: 11),
                            Text('住所'),
                            SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: _buildTextFormField(
                                    controller: _post1Controller,
                                    validator: (value) =>
                                        CustomValidator.validateNumber(value,
                                            order: 3),
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
                                        CustomValidator.validateNumber(value,
                                            order: 4),
                                    maxLength: 4,
                                    hintText: '0000',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: _getAddress,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            _buildTextFormField(
                              controller: _addressController,
                              validator: CustomValidator.validateAddress,
                              hintText: '東京都中央区銀座1-1-1',
                            ),
                            SizedBox(height: 8),
                            _buildTextFormField(
                              controller: _buildingController,
                              hintText: '〇〇マンション 101号室',
                            ),
                            SizedBox(height: 16),
                            Text('電話番号'),
                            SizedBox(height: 6),
                            _buildTextFormField(
                              controller: _phoneController,
                              validator: CustomValidator.validatePhoneNumber,
                              maxLength: 11,
                              hintText: '09012345678',
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    orientation == Orientation.portrait
                        ? null
                        : Container(
                            margin: EdgeInsets.only(top: 32),
                            child: addButton,
                          ),
                  ].where((w) => w != null).toList(),
                ),
              ),
            ),
          ),
          orientation == Orientation.landscape ? null : addButton,
        ].where((w) => w != null).toList(),
      );
    });
  }

  Widget _buildTextFormField({
    TextEditingController controller,
    String hintText,
    String Function(String) validator,
    int maxLength,
    TextInputType keyboardType,
  }) {
    bool editable = true; //_isWaitingForDeliveryDestination;
    return TextFormField(
      enableInteractiveSelection: editable,
      controller: controller,
      validator: validator,
      maxLength: maxLength,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        filled: true,
        fillColor: Colors.white.withAlpha(20),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
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

  /// 住所を取得.
  Future _getAddress() async {
    if (_addressController.text.length > 0) {
      // 既に住所が入力されているので何もしない.
      return;
    }
    String zipCode = _post1Controller.text + _post2Controller.text;
    final result = await PostalCodeUtil.getAddress(zipCode);
    if (result != null) {
      _addressController.text =
          "${result.address1}${result.address2}${result.address3}";
    }
  }

  Future<void> _validateInputs() async {
    if (!_formKey.currentState.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    // If all data are correct then save data to out variables
    _formKey.currentState.save();

    final service = BackendService(context);
    widget.onLoading(true);
    final response = await service.postUserDeliveryAddress(
      id: widget.address?.id ?? null,
      name: _nameController.text,
      postalCode: "${_post1Controller.text}-${_post2Controller.text}",
      address: _addressController.text,
      building: _buildingController.text,
      phoneNumber: _phoneController.text,
    );

    widget.onLoading(false);
    if (response?.result ?? false) {
      widget.onDecide(widget.address?.id);
    }
  }
}
