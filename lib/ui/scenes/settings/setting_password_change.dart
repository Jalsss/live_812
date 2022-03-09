import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/user/user_info.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';

class SettingPasswordChangePage extends StatefulWidget {
  @override
  SettingPasswordChangePageState createState() =>
      SettingPasswordChangePageState();
}

class SettingPasswordChangePageState extends State<SettingPasswordChangePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController1 = TextEditingController();
  final TextEditingController _newPassController2 = TextEditingController();
  bool _autoValidate = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController1.dispose();
    _newPassController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
        isLoading: _isLoading,
        backgroundColor: ColorLive.MAIN_BG,
        title: "パスワード変更",
        titleColor: Colors.white,
        body: Stack(children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      "現在のパスワード",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 6),
                  _buildPasswordInput(
                    controller: _currentPassController,
                    hintText: Lang.HINT_CURRENT_PASSWORD,
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: Text(
                      "新しいパスワード",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 6),
                  _buildPasswordInput(
                    controller: _newPassController1,
                    hintText: Lang.HINT_NEW_PASSWORD,
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: Text(
                      "新しいパスワード確認",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 6),
                  _buildPasswordInput(
                    controller: _newPassController2,
                    hintText: Lang.HINT_NEW_PASSWORD2,
                    validator: (value) {
                      return CustomValidator.validatePassword(value) == null
                          ? (value != _newPassController1.text)
                          ? Lang.PASSWORD_NOT_MATCHING
                          : null
                          : CustomValidator.validatePassword(value);
                    },
                  ),
                  SizedBox(height: 12),
                  FittedBox(
                    child: Text(
                      "パスワードは「8〜12文字以内」でお願いします。\n半角英数小文字、「 ｰ（ハイフン）」、「 _（アンダーバー）」、\n「＠（アットマーク）」、「 .（ドット）」が使用できます。",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PrimaryButton(
              text: Lang.CHANGE,
              onPressed: _validateInputs,
            ),
          )
        ]));
  }

  Widget _buildPasswordInput({
    TextEditingController controller,
    String hintText,
    String Function(String) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      obscureText: true,
      validator: validator ?? CustomValidator.validatePassword,
      maxLength: Consts.MAX_PASSWORD_LENGTH,
      decoration: InputDecoration(
        prefixIcon: Container(
          padding: EdgeInsets.all(15),
          child: SvgPicture.asset(
            "assets/svg/password_icon.svg",
          ),
        ),
        fillColor: Colors.white.withAlpha(20),
        filled: true,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red)),
        hintText: hintText,
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        counterText: '',
      ),
    );
  }

  Future<void> _validateInputs() async {
    if (!_formKey.currentState.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    _formKey.currentState.save();

    final currentPassword = _currentPassController.text;
    final newPassword = _newPassController1.text;

    setState(() { _isLoading = true;});
    final service = BackendService(context);
    final response = await service.putUser(
        UserInfoModel(pass: currentPassword, updatePass: newPassword));
    setState(() { _isLoading = false;});
    if (response?.result == true) {
      Navigator.of(context).pop();
    } else {
      showNetworkErrorDialog(context, msg: response.getByKey('msg'));
    }
  }
}
