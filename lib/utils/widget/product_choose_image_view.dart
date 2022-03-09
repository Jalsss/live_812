import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class ProductChooseImageView extends StatelessWidget {
  final String cameraLabel;
  final Function onCamera;
  final Function onGallery;

  ProductChooseImageView({
    this.cameraLabel = "",
    this.onCamera,
    this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: ColorLive.C26,
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              onPressed: onCamera,
              child: Column(
                children: <Widget>[
                  SvgPicture.asset("assets/svg/icon_camera.svg"),
                  SizedBox(height: 6),
                  Text(
                    cameraLabel,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "もしくは",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            SizedBox(height: 10),
            FlatButton(
              onPressed: onGallery,
              child: Column(
                children: <Widget>[
                  SvgPicture.asset("assets/svg/icon_gallery.svg"),
                  SizedBox(height: 6),
                  Text(
                    "ライブラリから画像を選択",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
