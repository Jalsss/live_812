import 'package:flutter/material.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/highlight_button.dart';
import 'package:store_redirect/store_redirect.dart';

class UpdateRequiredPage extends StatelessWidget {
  final String requiredVersion;
  final String appVersion;

  UpdateRequiredPage(this.requiredVersion, this.appVersion);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            return Future.value(false);  // バックキーを無効に
          },
          child: DefaultTextStyle(
            style: TextStyle(color: Colors.black, fontSize: 16),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    Lang.UPDATE_REQUIRED_MESSAGE,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                  HighlightButton(
                    Lang.UPDATE,
                    onPressed: _jumpToStore,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _jumpToStore() {
    StoreRedirect.redirect(
        androidAppId: Consts.ANDROID_APP_ID,
        iOSAppId: Consts.IOS_APP_ID);
  }
}
