import 'package:flutter/material.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailAddressController = TextEditingController();
  bool _autoValidate = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      title: "パスワードを忘れた方へ",
      isLoading: _isLoading,
      body: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(8.0, 16, 8, 8),
            child: Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailAddressController,
                validator: CustomValidator.validateEmail,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'メールアドレス *',
                  icon: Icon(Icons.email),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 48.0,
              width: double.infinity,
              color: Colors.black,
              child: FlatButton(
                textColor: Colors.white,
                onPressed: _requestPasswordReset,
                child: Text(
                  "メール送信",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPasswordReset() async {
    print('requestPasswordReset: ${_emailAddressController.text}');

    // With validation
    if (!_formKey.currentState.validate()) {
      setState(() => _autoValidate = true);
      return;
    }

    KeyboardUtil.close(context);

    setState(() {
      _autoValidate = false;
      _isLoading = true;
    });
    final service = BackendService(context);
    final emailAddress = _emailAddressController.text;
    final response = await service.postPasswordReset(emailAddress);
    setState(() => _isLoading = false);
    if (response?.result == true) {
      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('パスワードをリセットしました'),
            content: Text(response.getByKey('msg') ?? 'パスワードをリセットし、メールを送信しました。\nメール内容をご確認いただき、ログインを試してください'),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
      Navigator.of(context).pop();
    } else {
      showNetworkErrorDialog(context, msg: response.getByKey('msg'));
    }
  }
}
