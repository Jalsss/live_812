import 'package:flutter/material.dart';
import 'package:live812/utils/comma_format.dart';
import 'package:live812/utils/consts/language.dart';

/// ECの値段表示用Widget.
class EcProductPriceText extends StatelessWidget {
  final int price;
  final bool isIncludePostage;
  final TextStyle priceTextStyle;
  final TextStyle includePostageTextStyle;

  EcProductPriceText(this.price,
      {this.isIncludePostage = true,
      this.priceTextStyle,
      this.includePostageTextStyle});

  @override
  Widget build(BuildContext context) {
    if (price == null) {
      // 値段がない場合は表示しない.
      return const Text("");
    }

    if (isIncludePostage) {
      // 送料込み表示.
      return Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Text(
          "¥${commaFormat(price)}",
          style: priceTextStyle,
        ),
        Text(
          " ${Lang.INCLUDING_POSTAGE}",
          style: includePostageTextStyle,
        ),
      ]);
    } else {
      // 値段のみ.
      return Text(
        "¥${commaFormat(price)}",
        style: priceTextStyle,
      );
    }
  }
}
