import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/usecase/live_event_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/widget/web_view_page.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveEventManagementPage extends StatefulWidget {
  @override
  _LiveEventManagementPageState createState() =>
      _LiveEventManagementPageState();
}

class _LiveEventManagementPageState extends State<LiveEventManagementPage> {
  @override
  void initState() {
    super.initState();
    Future(() async {
      if (mounted) {
        _openWebView(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  /// WebViewを開く.
  void _openWebView(BuildContext context) async {
    String token = '';
    String errorMessage = '';
    try {
      token = await LiveEventUseCase.requestWebToken(
        context,
      );
    } on HttpException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = e.toString();
    }
    if ((token == null) || (errorMessage.isNotEmpty)) {
      await showNetworkErrorDialog(context, msg: errorMessage);
      return;
    }

    final host = Injector.getInjector().get<String>(
      key: Consts.KEY_LIVE_EVENT_URL,
    );
    final url = '$host?token=$token';
    if (Platform.isAndroid) {
      if (await canLaunch(url)) {
        await launch(url);
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(
            url: url,
            appBarColor: ColorLive.MAIN_BG,
            toGivePermissionJs: true,
          ),
        ),
      );
    }
  }
}
