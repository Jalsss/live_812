import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/model/user/user_info.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';

class SettingNicknameChangePage extends StatefulWidget {
  @override
  SettingNicknameChangePageState createState() =>
      SettingNicknameChangePageState();
}

class SettingNicknameChangePageState extends State<SettingNicknameChangePage> {
  final _formKey = GlobalKey<FormState>();
  final _newNicknameController = TextEditingController();
  bool _autoValidate = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _newNicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      isLoading: _isLoading,
      backgroundColor: ColorLive.MAIN_BG,
      title: "ニックネーム変更",
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
                    "現在のニックネーム",
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
                          final nickname =
                              userModel.nickname ?? '';
                          return Text(
                            nickname,
                            style: TextStyle(color: Colors.white),
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
                    "新しいニックネーム",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(height: 6),
                TextFormField(
                  controller: _newNicknameController,
                  style: TextStyle(color: Colors.white),
                  validator: CustomValidator.validateNickName,
                  maxLength: Consts.MAX_NICKNAME_LENGTH,
                  decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: EdgeInsets.all(15),
                        child:
                        //Icon(Icons.people),
                        SvgPicture.asset(
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
                      hintText: Lang.HINT_NEW_NICKNAME,
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      counterStyle:  TextStyle(color: Colors.grey[600]),
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
      ])
    );
  }

  Future<void> _validateInputs() async {
    _newNicknameController.text = _newNicknameController.text.trimLeft();
    if (!_formKey.currentState.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    _formKey.currentState.save();

    final newNickname = _newNicknameController.text;

    final userModel = Provider.of<UserModel>(context, listen: false);

    setState(() {
      _isLoading = true;
    });
    final service = BackendService(context);
    final response = await service.putUser(UserInfoModel(nickname: newNickname));
    setState(() {
      _isLoading = false;
    });
    if (response?.result == true) {
      userModel.setNickname(newNickname);
      await userModel.saveToStorage();
      Navigator.of(context).pop();
    } else {
      showNetworkErrorDialog(context, msg: response?.getByKey('msg'));
    }
  }
}
