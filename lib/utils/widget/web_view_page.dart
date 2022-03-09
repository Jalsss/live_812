import 'dart:io';

import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;
  final Color appBarColor;
  final Color titleColor;
  final bool toGivePermissionJs;

  WebViewPage({
    this.title,
    this.url,
    this.appBarColor,
    this.titleColor = Colors.white,
    this.toGivePermissionJs,
  });

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController _controller;
  String _title;
  bool _updateTitle = false;

  final _externalLinkHost = [
    'www2.jasrac.or.jp',
  ];

  @override
  void initState() {
    super.initState();
    _updateTitle = widget.title == null;
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      backgroundColor: widget.appBarColor,
      title: _title ?? widget.title ?? widget.url,
      titleColor: widget.titleColor,
      onClickBack: () async {
        if (!await _goBack())
          Navigator.of(context).pop();
      },
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            color: ColorLive.BLUE,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
      body: WillPopScope(
        onWillPop: () async => !await _goBack(),
        child: WebView(
          initialUrl: widget.url,
          javascriptMode: widget.toGivePermissionJs ? JavascriptMode.unrestricted : JavascriptMode.disabled,
          onWebViewCreated: (controller) => _controller = controller,
          onPageFinished: !_updateTitle ? null : (url) async {
            String title = await _controller?.getTitle();
            if (title != null && title.isEmpty)
              title = null;
            if (title != _title)
              setState(() => _title = title);
          },
          navigationDelegate: (request) async {
            if ((!request.isForMainFrame) || (widget.url == request.url)) {
              return NavigationDecision.navigate;
            }
            final uri = Uri.parse(request.url);
            if (_externalLinkHost.indexOf(uri.host) >= 0) {
              if (await canLaunch(request.url)) {
                await launch(
                  request.url,
                  forceSafariVC: false,
                  forceWebView: false,
                );
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }

  Future<bool> _goBack() async {
    if (_controller == null || await _controller.canGoBack() != true)
      return false;
    _controller.goBack();
    return true;
  }
}
