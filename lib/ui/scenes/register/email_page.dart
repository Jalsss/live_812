import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/register/pin_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';

class EmailPage extends StatefulWidget {
  @override
  State createState() {
    return EmailState();
  }
}

class EmailState extends State<EmailPage> {
  static const String DESCRIPTION = '''【お願い】
ご入力いただいたメールアドレス宛に認証コードをお送りしますので、メールアドレスの入力間違いにはご注意ください。

docomo、au、SoftBankなど、携帯電話会社のメールをお使いの場合は、「certification@live812.jp」からのメールを受信できるように設定してください。''';

  final _controller = TextEditingController();
  var _isLoading = false;
  var _isError = false;
  var _isNotEmpty = false;
  var _errorMessage = '';

  void _requestMail() async {
    final emailAddress = _controller.text;
    setState(() {
      _isLoading = true;
      _isError = false;
    });
    final service = BackendService(context);
    var response = await service.postSignUp(emailAddress);
    setState(() {
      _isLoading = false;
    });
    if (response?.result == true) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.setId(response.getByKey('id'));
      userModel.setEmailAddress(emailAddress);
      Navigator.push(context, FadeRoute(builder: (context) => PinPage()));
    } else {
      setState(() {
        _errorMessage = response?.getByKey('msg') ?? 'メールアドレスに誤りがあります。';
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.fromLTRB(8.0, 16, 8, 8),
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _controller,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'メールアドレス *',
                          icon: Icon(Icons.email),
                        ),
                        onChanged: (text) {
                          setState(() {
                            _isNotEmpty = text.isNotEmpty;
                          });
                        },
                      ),
                    ),
                    !_isError ? null : Text(
                      _errorMessage ?? '',
                      style: TextStyle(color: ColorLive.RED),
                    ),
                    Text(
                      DESCRIPTION,
                      style: TextStyle(color: const Color(0xff222222), fontSize: 14),
                    ),
                  ].where((w) => w != null).toList(),
                ),
              ),
            ),
          ),
          PrimaryButton(
            text: '次へ',
            onPressed: !_isNotEmpty ? null :  () {
              _requestMail();
            },
          ),
        ],
      ));
  }
}
