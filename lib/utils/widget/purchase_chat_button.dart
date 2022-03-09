import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/ui/scenes/user/purchase_chat_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/exclamation_badge.dart';

class PurchaseChatButton extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final Purchase purchase;
  final Function onPressed;

  PurchaseChatButton({
    this.padding,
    this.purchase,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: <Widget>[
        Container(
          height: 45,
          padding: padding,
          child: RaisedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.message,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                const Text("チャット"),
              ],
            ),
            color: ColorLive.MAIN_BG,
            textColor: Colors.white,
            shape: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
                width: 2.0,
              ),
            ),
            onPressed: onPressed,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 15),
          child: purchase.badgeChat ? ExclamationBadge() : Container(),
        ),
      ],
    );
  }
}
