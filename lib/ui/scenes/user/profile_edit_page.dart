import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user_info.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';

class ProfileEditPage extends StatefulWidget {
  final String message;
  final void Function(String) onUpdated;

  ProfileEditPage({this.message, this.onUpdated});

  @override
  ProfileEditPageState createState() => ProfileEditPageState();
}

class ProfileEditPageState extends State<ProfileEditPage> {
  TextEditingController _controller;

  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message);
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
        isLoading: _isLoading,
        backgroundColor: ColorLive.MAIN_BG,
        title: Lang.PROFILE,
        titleColor: Colors.white,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  maxLength: Consts.MAX_PROFILE_LENGTH,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    fillColor: ColorLive.BLUE_BG,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorLive.BLUE_BG)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ColorLive.BLUE_BG)),
                    hintText: Lang.HINT_INPUT,
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    counterStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  minLines: 12,
                  maxLines: 13,
                  controller: _controller,
                ),
              ),
            ),
            Container(
              height: 60.0,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  //end: Alignment.centerRight,s
                  colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
                  //colors: [Color(0xFF2C7BE5), const Color(0xFF2C7BE5)],
                ),
              ),
              child: FlatButton(
                textColor: Colors.white,
                onPressed: () {
                  _validateInputs();
                },
                child: Text(
                  Lang.CHANGE,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ));
  }

  void _validateInputs() async {
    if (_controller.text.length <= 0)
      return;

    final profile = _controller.text;

    setState(() => _isLoading = true);
    final service = BackendService(context);
    final response = await service.putUser(UserInfoModel(profile: profile));
    setState(() => _isLoading = false);
    if (response?.result == true) {
      widget.onUpdated(_controller.text);
      Navigator.of(context).pop();
    } else {
      showNetworkErrorDialog(context, msg: response?.getByKey('msg'));
    }
  }
}
