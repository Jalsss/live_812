import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/model/live/live_coach_mark.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:provider/provider.dart';

class LogoutPage extends StatefulWidget {
  @override
  LogoutPageState createState() => LogoutPageState();
}

class LogoutPageState extends State<LogoutPage> {
  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.LOGOUT,
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
                      Lang.MESSAGE_LOGOUT,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(
                      height: 45,
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
                        onPressed: () {
                          _logout();
                        },
                        child: Text(
                          Lang.LOGOUT,
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

  void _logout() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    await userModel.deleteFromStorage();
    BackendService.setApiToken(null);
    LiveCoachMark.initShowCoachMark();

    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
