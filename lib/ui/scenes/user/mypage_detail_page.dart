import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';

class MyPageDetailPage extends StatefulWidget {
  @override
  _MyPageDetailPageState createState() => _MyPageDetailPageState();
}

class _MyPageDetailPageState extends State<MyPageDetailPage> {
  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      backgroundColor: ColorLive.BLUE_BG,
    );
  }
}
