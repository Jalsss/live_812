import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';

class PinCodeDialog extends StatefulWidget {

  @override
  _PinCodeDialogState createState() => _PinCodeDialogState();
}

class _PinCodeDialogState extends State<PinCodeDialog> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      child: _dialogContent(context),
    );
  }

  Widget _dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height - 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Text(
              Lang.pinNoReceive,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 1,
              width: 50,
              child: Divider(
                color: ColorLive.BORDER2,
                thickness: 1,
                height: 1,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Text(Lang.pinDialogMessageText1,
                  style: TextStyle(fontSize: 14)),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Text(Lang.pinDialogMessageText2,
                  style: TextStyle(fontSize: 14)),
            ),
            SizedBox(
              height: 30,
            ),
            FlatButton(
              textColor: Colors.blue,
              child: Text(Lang.CLOSE_CC,
                  style: TextStyle(
                      fontSize: 14, decoration: TextDecoration.underline)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ]),
        )
      ],
    );
  }
}