import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/model/live/live_coach_mark.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:provider/provider.dart';

// 退会確認
class QuitServicePage extends StatefulWidget {
  @override
  QuitServicePageState createState() => QuitServicePageState();
}

class QuitServicePageState extends State<QuitServicePage> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    return LiveScaffold(
      isLoading: _isLoading,
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.QUIT_SERVICE,
      titleColor: Colors.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      Lang.MESSAGE_QUIT_SERVICE,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    userModel.isLiver ? SizedBox(
                      height: 25,
                    ) : Container(),
                    userModel.isLiver ? Text(
                      Lang.MESSAGE_QUIT_SERVICE_LIVER,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ) : Container(),
                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      height: 40.0,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        color: ColorLive.C505,
                      ),
                      child: FlatButton(
                        textColor: Colors.black,
                        onPressed: _showUnregistConfirmDialog,
                        child: Text(
                          Lang.DO_QUIT_SERVICE,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 40.0,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
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
                          Navigator.pop(context);
                        },
                        child: Text(
                          Lang.CANCEL,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showUnregistConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(Lang.QUIT_SERVICE),
          content: Text(Lang.MESSAGE_CONFIRM_QUIT_SERVICE),
          actions: <Widget>[
            // ボタン領域
            FlatButton(
              child: Text(Lang.CANCEL),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text(Lang.DECIDE),
              onPressed: () {
                Navigator.pop(context);
                _requestUnregist();
              }
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestUnregist() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    final service = BackendService(context);
    var response = await service.postUnregist();
    setState(() {
      _isLoading = false;
    });

    if (response == null) {
      // レスポンスが存在しない
      showNetworkErrorDialog(context);
      return;
    }
    if( response.result  == false && response.containsKey("msg") &&  response.getByKey("msg") !=  null )
    {
      // 退会不可
      showInformationDialog(context, title: "", msg: response.getByKey("msg"));
      return;
    }
    if (response.result == false)
    {
      // レスポンスがおかしい
      showNetworkErrorDialog(context);
      return;
    }
    // ローカルの退会処理
    userModel.deleteFromStorage();
    BackendService.setApiToken(null);
    LiveCoachMark.initShowCoachMark();
    Navigator.popAndPushNamed(context, '/');
  }

}
