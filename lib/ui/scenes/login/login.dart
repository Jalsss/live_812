import 'dart:ui' as ui show PlaceholderAlignment;

import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/news_event_usecase.dart';
import 'package:live812/domain/usecase/user_info_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/ui/scenes/login/forgot_password.dart';
import 'package:live812/ui/scenes/register/email_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';
import 'package:live812/utils/widget/web_view_page.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final Function onLogin;

  LoginPage({this.onLogin});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final _emailAddressController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String _errorMessage;
  var _isProgress = false;

  @override
  void dispose() {
    _emailAddressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // ログイン画面にきた際にはログイン前の状態ということで、
    // 端末にユーザ情報が保存されていない状態にしてやる。
    final userModel = Provider.of<UserModel>(context, listen: false);
    userModel.deleteFromStorage();
    BackendService.setApiToken(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              "assets/images/walk4.png",
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: Container(
              height: double.infinity,
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 26, 16, 64),
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                              color: ColorLive.LOGIN_BG,
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                          child: _loginColumn(context),
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 60.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: ColorLive.LOGIN_BG,
                              borderRadius: BorderRadius.all(Radius.circular(5))),
                          child: FlatButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  FadeRoute(
                                      builder: (context) => EmailPage()));
                            },
                            child: Text(
                              Lang.SIGNUP,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          children: <Widget>[
                            Text(
                              '新規登録することによって、',
                              style: TextStyle(color: Colors.white),
                            ),
                            GestureDetector(
                              child: Text('利用規約',
                                  style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline)),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    FadeRoute(
                                        builder: (context) => WebViewPage(
                                              title: '利用規約',
                                              titleColor: Colors.white,
                                              appBarColor: ColorLive.MAIN_BG,
                                              url:
                                                  'http://agreement.live812.works/use.html',
                                              toGivePermissionJs: false,
                                            )));
                              },
                            ),
                            Text('・', style: TextStyle(color: Colors.white)),
                            GestureDetector(
                              child: Text('ライブコマース利用規約',
                                  style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline)),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    FadeRoute(
                                        builder: (context) => WebViewPage(
                                          title: 'ライブコマース利用規約',
                                          titleColor: Colors.white,
                                          appBarColor: ColorLive.MAIN_BG,
                                          url:
                                          'http://agreement.live812.works/ec.html',
                                          toGivePermissionJs: false,
                                        )));
                              },
                            ),
                            Text('・', style: TextStyle(color: Colors.white)),
                            GestureDetector(
                              child: Text('プライバシーポリシー',
                                  style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline)),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    FadeRoute(
                                        builder: (context) => WebViewPage(
                                              title: 'プライバシーポリシー',
                                              titleColor: Colors.white,
                                              appBarColor: ColorLive.MAIN_BG,
                                              url:
                                                  'http://agreement.live812.works/privacy.html',
                                              toGivePermissionJs: false,
                                            )));
                              },
                            ),
                            Text('に同意したとみなします',
                                style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: _isProgress ? SpinningIndicator() : Container(),
          ),
        ],
      ),
    );
  }

  Widget _loginColumn(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 30),
        Text(Lang.LOGIN, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 16.0),
                Text(
                  "メールアドレス *",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailAddressController,
                  focusNode: _emailFocusNode,
                  validator: CustomValidator.validateEmail,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).nextFocus();
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "yours@live812.com"),
                ),
                SizedBox(height: 32.0),
                Text(
                  "パスワード *",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  validator: CustomValidator.validatePassword,
                  onFieldSubmitted: (_) {
                    _passwordFocusNode.unfocus();
                    _login();
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "半角英数字のみ${Consts.MIN_PASSWORD_LENGTH}〜${Consts.MAX_PASSWORD_LENGTH}桁以内",
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 90),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: _errorMessage == null ? null : RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            child: Icon(Icons.info_outline, color: Colors.pink),
                            baseline: TextBaseline.alphabetic,
                            alignment: ui.PlaceholderAlignment.middle,
                          ),
                          TextSpan(
                            text: _errorMessage,
                            style: TextStyle(color: Colors.pink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        FadeRoute(builder: (context) => ForgotPasswordPage()),
                      );
                    },
                    child: Text(
                      "パスワードを忘れた方へ",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        PrimaryButton(
          text: Lang.LOGIN,
          onPressed: _login,
        ),
      ],
    );
  }

  Future<void> _login() async {
    final emailAddress = _emailAddressController.text;
    final password = _passwordController.text;

    final service = BackendService(context);
    if (!_formKey.currentState.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    KeyboardUtil.close(context);

    // Send a request
    setState(() {
      _autoValidate = false;
      _isProgress = true;
      _errorMessage = null;
    });
    final response = await service.postLogin(emailAddress, password);
    if (response?.result == true) {
      final data = response.getData();
      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.readFromJson(data);
      BackendService.setApiToken(userModel.token);

      // ログインのレスポンスだけでは情報が不足しているので、
      // 自分の情報を取得する
      await _updateMyInfoUntilSuccess();

      // お知らせを取得.
      await NewsEventUseCase.checkNewsEvent(context);

      Navigator.of(context).pushReplacementNamed("/bottom_nav");
    } else {
      _passwordController.clear();
      setState(() {
        String msg;
        if (response != null)
          msg = response.getByKey('msg');
        _errorMessage = msg ?? Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER;
        _isProgress = false;
      });
    }
  }

  Future<void> _updateMyInfoUntilSuccess() async {
    for (;;) {
      setState(() => _isProgress = true);
      final result = await UserInfoUsecase.updateMyInfo(context);
      setState(() => _isProgress = false);
      switch (result.item1) {
        case UpdateMyInfoResult.SUCCESS:
          return;
        case UpdateMyInfoResult.NETWORK_ERROR:
        case UpdateMyInfoResult.UNAUTHENTICATED:
          await showNetworkErrorDialog(context, msg: result.item2.getByKey('msg'));
          break;
      }
    }
  }
}
