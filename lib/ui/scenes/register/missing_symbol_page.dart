import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/model/user/user_info.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/register/user_information.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';

class MissingSymbolPage extends StatefulWidget {
  @override
  _MissingSymbolPageState createState() => _MissingSymbolPageState();
}

class _MissingSymbolPageState extends State<MissingSymbolPage> {
  final TextEditingController _symbolController = TextEditingController();

  var _isLoading = false;
  var _hasSymbolError = false;

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      title: 'ユーザーID設定',
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
        SizedBox(width: 16),
        Text(
          constraint,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  void _requestUserInfo() async {
    final symbol = _symbolController.text;
    setState(() => _hasSymbolError = UserInformationPage.checkSymbolError(symbol));
    if (_hasSymbolError) {
      return;
    }

    final service = BackendService(context);
    final userModel = Provider.of<UserModel>(context, listen: false);
    setState(() => _isLoading = true);
    final response = await service.putUser(UserInfoModel(symbol: symbol));
    setState(() => _isLoading = false);
    if (response?.result != true) {
      _showErrorDialog(response?.getByKey('msg'));
      return;
    }

    userModel.setSymbol(symbol);
    await userModel.saveToStorage();
    Navigator.of(context).pushReplacementNamed("/bottom_nav");
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
            ),
          ],
        );
      });
  }
}
