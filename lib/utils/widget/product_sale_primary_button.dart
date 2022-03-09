import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';

class ProductSalePrimaryButton extends StatelessWidget {
  final Function() onTap;
  final void Function() onTemplateTap;
  final double height;

  ProductSalePrimaryButton({
    @required this.onTap,
    @required this.onTemplateTap,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
              ),
            ),
            child: FlatButton(
              textColor: Colors.white,
              onPressed: onTap,
              child: Text(
                Lang.ADD_NEW_PRODUCT,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                colors: [Colors.grey, Colors.grey[600]],
              ),
            ),
            child: FlatButton(
              textColor: Colors.white,
              onPressed: onTemplateTap,
              child: Text(
                "テンプレート",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
