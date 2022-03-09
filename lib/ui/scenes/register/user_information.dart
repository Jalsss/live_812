import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/signup.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/register/profile_choose.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';

class UserInformationPage extends StatefulWidget {
  @override
  _UserInformationPageState createState() => _UserInformationPageState();

  static RegExp _reSymbolChars = RegExp(r'^[0-9a-zA-Z\-_@.]+$');

  static bool checkSymbolError(String text) {
    if (text.length < Consts.MIN_SYMBOL_LENGTH ||
        text.length > Consts.MAX_SYMBOL_LENGTH ||
        !_reSymbolChars.hasMatch(text)) {
      return true;
    } else {
      return false;
    }
  }
}

class _UserInformationPageState extends State<UserInformationPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmedController = TextEditingController();

  var _isLoading = false;
  var _hasNickNameError = false;
  var _hasSymbolError = false;
  var _hasPasswordError1 = false;
  var _hasPasswordError2 = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _symbolController.dispose();
    _passwordController.dispose();
    _passwordConfirmedController.dispose();

    super.dispose();
  }

  // 全角16文字以内
  bool _checkNickNameError() {
    _nicknameController.text = _nicknameController.text.trimLeft();
    if (_nicknameController.text.isEmpty ||
        _nicknameController.text.length > Consts.MAX_NICKNAME_LENGTH) {
      setState(() {
        _hasNickNameError = true;
      });
      return true;
    } else {
      return false;
    }
  }

  static RegExp rePasswordChars = RegExp(r'^[0-9a-zA-Z\-_@.]+$');

  bool _checkPasswordError() {
    final text = _passwordController.text;
    if (text.length < Consts.MIN_PASSWORD_LENGTH ||
        text.length > Consts.MAX_PASSWORD_LENGTH ||
        !rePasswordChars.hasMatch(text)) {
      setState(() {
        _hasPasswordError1 = true;
      });
      return true;
    }
    if (text != _passwordConfirmedController.text) {
      setState(() {
        _hasPasswordError2 = true;
      });
      return true;
    }

    return false;
  }

  void _requestUserInfo() async {
    final symbol = _symbolController.text;
    setState(() {
      _isLoading = true;
      _hasSymbolError = UserInformationPage.checkSymbolError(symbol);
    });
    var hasNicknameError = _checkNickNameError();
    var hasPasswordError = _checkPasswordError();
    if (!hasNicknameError &&
        !_hasSymbolError &&
        !hasPasswordError) {
      final service = BackendService(context);
      final userModel = Provider.of<UserModel>(context, listen: false);
      var signUpModel = SignUpModel(
        userModel.token,
        userModel.id,
        _nicknameController.text,
        symbol,
        _passwordController.text,
      );
      var response = await service.postUser(signUpModel);
      setState(() {
        _isLoading = false;
      });
      if (response != null && response.result) {
        userModel.setSymbol(symbol);
        userModel.setNickname(_nicknameController.text);
        await userModel.saveToStorage();
        Navigator.push(context,
            FadeRoute(builder: (context) => ProfileChoosePage()));
      } else {
        _showErrorDialog(response?.getByKey('msg'));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('エラー'),
            content: Text(msg),
            actions: <Widget>[
              FlatButton(
                child: Text('はい'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      title: '新規登録',
      isLoading: _isLoading,
      isBackButton: false,
      body: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16.0, 16, 16, 8),
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 16.0),
                    _textFieldLabel('ニックネーム', '必須・${Consts.MAX_NICKNAME_LENGTH}文字以内',
                        description: 'ログイン後に変更が可能です。絵文字が使用できます。'),
                    TextField(
                      controller: _nicknameController,
                      maxLength: Consts.MAX_NICKNAME_LENGTH,
                      decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(),
                        errorText: _hasNickNameError ? 'ニックネームは${Consts.MAX_NICKNAME_LENGTH}文字以内で入力してください' : null,
                        border: OutlineInputBorder(),
                        labelText: 'お好きなニックネーム',
                        counterText: '',
                      ),
                      onChanged: (text) {
                        setState(() {
                          _hasNickNameError = false;
                        });
                      },
                    ),
                    SizedBox(height: 32.0),
                    _textFieldLabel('ユーザーID', '必須・${Consts.MIN_SYMBOL_LENGTH}〜${Consts.MAX_SYMBOL_LENGTH}文字以内',
                        description: '他のユーザーに公開され後で変更できません。半角英数小文字、「-（ハイフン）」、「_（アンダーバー）」、「@（アットマーク）」、「.（ドット）」が使用できます。'),
                    TextField(
                      controller: _symbolController,
                      maxLength: Consts.MAX_SYMBOL_LENGTH,
                      decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(),
                        errorText: _hasSymbolError ? 'ユーザーIDは${Consts.MIN_SYMBOL_LENGTH}~${Consts.MAX_SYMBOL_LENGTH}文字以内で入力してください。' : null,
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      onChanged: (text) {
                        setState(() {
                          _hasSymbolError = false;
                        });
                      },
                    ),
                    SizedBox(height: 32.0),
                    _textFieldLabel('パスワード', '必須・${Consts.MIN_PASSWORD_LENGTH}〜${Consts.MAX_PASSWORD_LENGTH}文字以内',
                        description: 'ログイン後に変更が可能です。半角英数小文字、「-（ハイフン）」、「_（アンダーバー）」、「@（アットマーク）」、「.（ドット）」が使用できます。'),
                    TextField(
                      controller: _passwordController,
                      maxLength: Consts.MAX_PASSWORD_LENGTH,
                      decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(),
                        errorText: _hasPasswordError1 ? '${Consts.MIN_PASSWORD_LENGTH}文字〜${Consts.MAX_PASSWORD_LENGTH}文字以内で入力してください' : null,
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      obscureText: true,
                      onChanged: (text) {
                        setState(() {
                          _hasPasswordError1 = false;
                        });
                      },
                    ),
                    SizedBox(height: 32.0),
                    _textFieldLabel('パスワード確認', '必須・${Consts.MIN_PASSWORD_LENGTH}〜${Consts.MAX_PASSWORD_LENGTH}文字以内'),
                    TextField(
                      controller: _passwordConfirmedController,
                      maxLength: Consts.MAX_PASSWORD_LENGTH,
                      decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(),
                        errorText: _hasPasswordError2 ? 'パスワードが一致しません' : null,
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      obscureText: true,
                      onChanged: (text) {
                        setState(() {
                          _hasPasswordError2 = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            PrimaryButton(
              text: '登録する',
              onPressed: () {
                _requestUserInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  // TextFieldの上の項目ラベルと制約条件テキスト
  Widget _textFieldLabel(String title, String constraint, {String description}) {
    final basic = Row(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 16.0,
        ),
        Text(
          constraint,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );

    if (description == null)
      return basic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        basic,
        Text(
          description,
          style: TextStyle(fontSize: 11, color: Color(0xff666666)),
        ),
      ],
    );
  }
}
