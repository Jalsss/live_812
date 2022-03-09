import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/widget/main_bar.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';

class LiveScaffold extends StatefulWidget {
  final String title;
  final Color titleColor;
  final List<Widget> actions;
  final double height;
  final Widget body;
  final Color backgroundColor;
  final Function onClickBack;
  final Widget bottom;
  final bool isLoading;
  final bool isBackButton;
  LiveScaffold(
      {this.title: "",
      this.titleColor,
      this.height,
      this.actions,
      this.body,
      this.bottom,
      this.backgroundColor: ColorLive.background,
      this.onClickBack,
      this.isLoading: false,
      this.isBackButton: true});
  @override
  _LiveScaffoldState createState() => _LiveScaffoldState();
}

class _LiveScaffoldState extends State<LiveScaffold> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: [
                MainBar(
                  title: widget.title,
                  color: widget.titleColor,
                  //height: widget.height,
                  isBackButton: widget.isBackButton,
                  onClickBack: widget.onClickBack ?? () {
                    Navigator.of(context).pop();
                  },
                  actions: widget.actions,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: widget.height ?? 0),
                    child: widget.body,
                  ),
                ),
              ],
            ),
            !widget.isLoading ? null : SpinningIndicator(),
          ].where((w) => w != null).toList(),
        ),
      ),
      bottomNavigationBar: widget.bottom,
    );
  }
}
