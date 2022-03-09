import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainBar extends StatelessWidget {
  final double height;
  final Color color;
  final String title;
  final Function onClickBack;
  final List<Widget> actions;
  final bool isBackButton;

  const MainBar(
      {Key key,
      this.height,
      this.title: '',
      this.onClickBack,
      this.color: Colors.black,
      this.actions,
      this.isBackButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Align(  // isBackButton=falseでもこのウィジェットを追加しないとレイアウトエラーが出る
            alignment: Alignment.centerLeft,
            child: MaterialButton(
              minWidth: 50,
              height: 50,
              padding: EdgeInsets.all(0),
              child: !isBackButton ? null : SvgPicture.asset(
                "assets/svg/backButton.svg",
              ),
              onPressed: !isBackButton ? null : () {
                onClickBack();
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 17, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          actions == null ? null : Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ),
        ].where((w) => w != null).toList(),
      ),
    );
  }
}
