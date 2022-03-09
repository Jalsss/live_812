import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/in_app_purchase.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class GridCoinItem extends StatelessWidget {
  final String productId;
  final String localizedPrice;
  final String title;
  final IAPItem item;
  final InAppPurchase purchase;

  GridCoinItem({
    @required this.productId, @required this.localizedPrice, @required this.title,
    @required this.item, @required this.purchase,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      child: Column(
        children: <Widget>[
          Container(
            width: 80,
            height: 90,
            child: Center(
                child: Image.asset(
                  'assets/images/$productId.png',
                  fit: BoxFit.fitHeight,
                ),
            ),
          ),
          SizedBox(height: 10),
          Column(
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ColorLive.ORANGE,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
                Text(
                  localizedPrice,
                  style: TextStyle(
                      fontSize: 14, color: Colors.white, fontFamily: "Roboto"),
                ),
              ],
          ),
        ],
      ),
    );
  }
}
