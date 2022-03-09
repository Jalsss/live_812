import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/register/user_information.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class PinPage extends StatefulWidget {
  final TextEditingController _codeController = TextEditingController();

  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  static const String DESCRIPTION = '''1時間経ってもメールが届かない場合は、迷惑メールフォルダやメールの受信設定（フィルタ設定）などをご確認ください。
メールの受信設定が原因で受信できなかった場合は、受信設定完了後に最初からやりなおしてください。''';

  var _isLoading = false;
  var _error = false;
  var _isNotEmpty = false;

  void _requestPinCode() async {
    setState(() {
      _isLoading = true;
      _error = false;
    });
    final service = BackendService(context);
    final userModel = Provider.of<UserModel>(context, listen: false);
    var response = await service.postCode(
        int.parse(widget._codeController.text.toString()), userModel.id);
    setState(() {
      _isLoading = false;
    });
    if (response != null && response.result) {
      userModel.readFromJson(response.getData());
      final token = response.getByKey('token');
      userModel.setToken(token);
      BackendService.setApiToken(token);

      // バックキーで戻れないようにする
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.pushReplacement(
          context, FadeRoute(builder: (context) => UserInformationPage()));
    } else {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      title: '新規登録',
      isLoading: _isLoading,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 15, top: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Text(
                      Lang.pinSubTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            Lang.pinRequired,
                            textAlign: TextAlign.left,
                          ),
                          PinCodeTextField(
                            length: 4,
                            obsecureText: false,
                            controller: widget._codeController,
                            animationType: AnimationType.fade,
                            backgroundColor: ColorLive.background,
                            shape: PinCodeFieldShape.box,
                            animationDuration: Duration(milliseconds: 200),
                            borderRadius: BorderRadius.circular(5),
                            inactiveColor: Colors.green,
                            activeColor: ColorLive.BORDER3,
                            fieldHeight: 50,
                            fieldWidth: 50,
                            textInputType: TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            onChanged: (text) {
                              setState(() {
                                _isNotEmpty = text.isNotEmpty;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          !_error ? null : Text(
                            '認証コードが違います',
                            style: TextStyle(color: Colors.red),
                          ),
                        ].where((w) => w != null).toList(),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      DESCRIPTION,
                      style: TextStyle(color: const Color(0xff222222), fontSize: 14),
                    ),
                    //SizedBox(height: 40),
                    //GestureDetector(
                    //  child: Text(
                    //    Lang.pinNoReceive,
                    //    textAlign: TextAlign.center,
                    //    style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
                    //  ),
                    //  onTap: () {
                    //    showDialog(
                    //      context: context,
                    //      builder: (BuildContext context) => PinCodeDialog(),
                    //    );
                    //  },
                    //),
                  ],
                ),
              ),
            ),
          ),
          PrimaryButton(
            text: '次へ',
            onPressed: !_isNotEmpty ? null : () {
              _requestPinCode();
            },
          ),
        ],
      ),
    );
  }
}
