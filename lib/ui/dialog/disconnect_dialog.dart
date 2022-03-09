import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';

Future<void> showDisconnectDialog(BuildContext context, String msg) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Center(
              child: Column(
                children: <Widget>[
                  Text(
                    msg ?? '配信が終了しました',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      gradient: new LinearGradient(
                        begin: Alignment.centerLeft,
                        colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
                      ),
                    ),
                    child: FlatButton(
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.settings.name == '/bottom_nav');
                      },
                      child: Text(
                        Lang.CLOSE_CC,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
