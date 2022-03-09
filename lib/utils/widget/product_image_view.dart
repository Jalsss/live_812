import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductImageView extends StatelessWidget {
  final image;
  final Function onRemove;

  ProductImageView({this.image, this.onRemove});

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    if (image is File) {
      imageProvider = FileImage(image);
    } else if (image is String) {
      imageProvider = NetworkImage(image);
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(3),
        ),
        border: Border.all(
          color: Colors.white,
        ),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: RawMaterialButton(
          padding: EdgeInsets.all(10),
          shape: CircleBorder(),
          fillColor: Colors.black.withAlpha(80),
          onPressed: onRemove,
          child: SvgPicture.asset("assets/svg/remove.svg"),
        ),
      ),
    );
  }
}
