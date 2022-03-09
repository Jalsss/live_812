import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/model/user/user_info.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';

class SettingEmailChangePage extends StatefulWidget {
  @override
  SettingEmailChangePageState createState() => SettingEmailChangePageState();
}

class SettingEmailChangePageState extends State<SettingEmailChangePage> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final _newEmailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
        isLoading: _isLoading,
        backgroundColor: ColorLive.MAIN_BG,
        title: "メールアドレス変更",
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
                      "現在のメールアドレス",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        child:
                        //Icon(Icons.people),
                        SvgPicture.asset(
                          "assets/svg/user_icon.svg",
                        ),
                      ),
                      Expanded(
                        child: Consumer<UserModel>(
                          builder: (context, userModel, _) {
                            final emailAddress = userModel.emailAddress ?? '(email=null)';
                            return Text(
                              emailAddress,
                              style: TextStyle(
                                  color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: ColorLive.BLUE_BG,
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: Text(
                      "新しいメールアドレス",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 6),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _newEmailController,
                    style: TextStyle(color: Colors.white),
                    validator: CustomValidator.validateEmail,
                    decoration: InputDecoration(
                        prefixIcon: Container(
                          padding: EdgeInsets.all(15),
                          child: SvgPicture.asset(
                            "assets/svg/user_icon.svg",
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
                        //labelText: Lang.SEARCH_HINT,
                        hintText: Lang.HINT_NEW_EMAIL,
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle:
                        TextStyle(color: Colors.grey[600], fontSize: 12),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
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

  Future<void> _validateInputs() async {
    if (!_formKey.currentState.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    _formKey.currentState.save();

    final newEmail = _newEmailController.text;

    final userModel = Provider.of<UserModel>(context, listen: false);
    if (newEmail == userModel.emailAddress) {
      Flushbar(
        icon: Icon(
          Icons.warning,
          size: 28.0,
          color: Colors.orange[300],
        ),
        message:  '現在のメールアドレスと同じです',
        duration:  Duration(milliseconds: 2000),
        margin: EdgeInsets.all(8),
        borderRadius: 8,
      )..show(context);
      return;
    }

    setState(() { _isLoading = true;});
    final service = BackendService(context);
    final response = await service.putUser(UserInfoModel(updateMail: newEmail));
    setState(() { _isLoading = false;});
    if (response?.result != true) {
      showNetworkErrorDialog(context, msg: response?.getByKey('msg'));
      return;
    }

    await showInformationDialog(
        context,
        title: 'メールアドレス変更',
        msg: '入力いただいたメールアドレス宛にメールをお送りしました。\n\nメールに記載されているURLをタップして、メールアドレスの変更を完了させてください。',
    );
    Navigator.of(context).pop();
  }
}
