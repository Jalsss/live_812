import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/model/user/user_info.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/settings/address_form.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';

class AddressPage extends StatefulWidget {
  @override
  AddressPageState createState() => AddressPageState();
}

class AddressPageState extends State<AddressPage> {
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _post1Controller = TextEditingController();
  final TextEditingController _post2Controller = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      isLoading: _isLoading,
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.ADDRESS_TITLE,
      titleColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 30,
            bottom: 50,
            left: 30,
            right: 30,
            child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Text(
                      Lang.ADDRESS_BODY,
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    AddressForm(_nameController, _post1Controller, _post2Controller,
                        _addressController, _buildingController, _phoneController),
                  ],
                )),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PrimaryButton(
              text: Lang.ADDRESS_TITLE,
              onPressed: _validateInputs,
            ),
          )
        ],
      ),
    );
  }

  void _validateInputs() async {
    // TODO: Validation.

    final postalCode = _post1Controller.text != null && _post2Controller.text.toString() != null
        ? '${_post1Controller.text.toString()}-${_post2Controller.text.toString()}'
        : null;

    final userModel = Provider.of<UserModel>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    final service = BackendService(context);
    var model = UserInfoModel(
        deliveryName: _nameController.text.toString(),
        deliveryPostalCode: postalCode,
        deliveryAddress: _addressController.text.toString(),
        deliveryBuilding: _buildingController.text.toString(),
        deliveryPhone: _phoneController.text.toString());

    final response = await service.putUser(model);
    setState(() {
      _isLoading = false;
    });
    if (response != null && response.result) {
      userModel.setDeliveryInfo(
          _nameController.text.toString(),
          postalCode,
          _addressController.text.toString(),
          _buildingController.text.toString(),
          _phoneController.text.toString());
      Navigator.of(context).pop();
    } else {
      showNetworkErrorDialog(context);
    }
  }
}
