import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/web_view_page.dart';

class JasracUseCase {
  JasracUseCase._();

  static Future<String> requestWebToken(BuildContext context) async {
    final service = BackendService(context);
    final request = await service.getWebToken();
    if (!request.result) {
      return null;
    }
    return request.getData()['token'] as String;
  }

  static transitionJasrac(BuildContext context, String token) async {
    final url =
        '${Injector.getInjector().get<String>(key: Consts.KEY_JASRAC_URL)}?token=$token';

    await Navigator.push(
      context,
      FadeRoute(
        builder: (context) => WebViewPage(
          url: url,
          titleColor: Colors.white,
          title: 'JASRAC楽曲使用申請',
          appBarColor: ColorLive.MAIN_BG,
          toGivePermissionJs: true,
        ),
      ),
    ); // ヘルプ・使い方
  }

  static Future<void> showMessage(
      BuildContext context, String title, String message) async {
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
