
import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';

class WithdrawDialog extends StatefulWidget {
  final DateTime estimateDate;

  WithdrawDialog(this.estimateDate);

  @override
  WithdrawDialogState createState() => WithdrawDialogState();
}

class WithdrawDialogState extends State<WithdrawDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      child: IntrinsicHeight(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 60,
                      color: Color(0xffd0d0d0),
                      child: Center(
                        child: Text(
                          '振込申請',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Text(
                            "振込申請を受け付けました\n\n振込予定日：${widget.estimateDate ?? ''}",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Container(
                height: 50.0,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(2),
                      bottomRight: Radius.circular(2)),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
                  ),
                ),
                child: FlatButton(
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    Lang.CLOSE,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
