import 'package:flutter/material.dart';

class NGFilter {
  static RegExp reNgWords = RegExp(r'死');

  static bool containsNGWord(String text) {
    return reNgWords.hasMatch(text);
  }

  static Future<void> showAlertDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('送信できません'),
          content: Text('禁止ワードが含まれています。'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
