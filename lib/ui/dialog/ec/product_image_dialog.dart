import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:photo_view/photo_view.dart';

class ProductImageDialog extends StatelessWidget {
  final String url;

  ProductImageDialog({this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Stack(
        children: <Widget>[
          PhotoView(
            minScale: PhotoViewComputedScale.contained,
            imageProvider: NetworkImage(url),
          ),
          Positioned(
            bottom: 50,
            left: 100,
            right: 100,
            height: 50,
            child: MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              padding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              color: ColorLive.BLUE,
              child: Text(
                Lang.CLOSE_CC,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
