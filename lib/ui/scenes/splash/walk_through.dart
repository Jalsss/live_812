import 'dart:math';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:live812/ui/scenes/login/login.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalkThrough extends StatefulWidget {
  @override
  _WalkThroughState createState() => _WalkThroughState();
}

class _WalkThroughState extends State<WalkThrough> {
  static const List<String> imagePaths = [
    "assets/images/wt1.jpg",
    "assets/images/wt2.jpg",
    "assets/images/wt3.jpg",
  ];

  int _currentIndexPage = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  void onDone() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences.setBool("walk", true);
      Navigator.of(context).pushReplacementNamed("/login");
    });
  }

  @override
  Widget build(BuildContext context) {
    int pageCount = imagePaths.length + 1;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xff2C3844),
        child: Stack(
          children: <Widget>[
            Swiper(
              itemBuilder: (BuildContext context, int index) {
                if (index < imagePaths.length) {
                  return SafeArea(
                    child: Image.asset(
                      imagePaths[index],
                      fit: BoxFit.contain,
                    ),
                  );
                } else {
                  return LoginPage();
                }
              },
              loop: false,
              itemCount: pageCount,
              onIndexChanged: (index) {
                setState(() {
                  _currentIndexPage = index;
                });
              },
            ),
            Positioned(
              bottom: max(10, MediaQuery.of(context).padding.bottom),
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: DotsIndicator(
                  dotsCount: pageCount,
                  position: _currentIndexPage.toDouble(),
                  decorator: DotsDecorator(
                    color: ColorLive.TRANS_WHITE_90,
                    activeColor: Colors.white,
                    size: const Size(50.0, 5.0),
                    activeSize: const Size(50.0, 5.0),
                    activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
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
