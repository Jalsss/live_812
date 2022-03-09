import 'package:flutter/material.dart';
import 'package:live812/utils/consts/language.dart';

Future showInformationDialog(BuildContext context, {@required String title, @required String msg}) {
  return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text('はい'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}

Future showNetworkErrorDialog(BuildContext context, {String msg}) {
  return showInformationDialog(
    context,
    title: Lang.ERROR,
    msg: msg ?? 'ネットワークエラーが発生しました',
  );
}
