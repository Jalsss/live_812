import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/ui/scenes/shop/product_detail_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/ec_product_price_text.dart';

class PurchaseHeader extends StatelessWidget {
  final Purchase purchase;
  final Function onTap;

  PurchaseHeader({this.purchase, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        color: ColorLive.C26,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                purchase.imgThumbUrl?.isNotEmpty == true
                    ? Container(
                        width: 70,
                        height: 70,
                        child: FadeInImage.assetNetwork(
                          placeholder: Consts.LOADING_PLACE_HOLDER_IMAGE,
                          image: purchase.imgThumbUrl[0],
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 70,
                      ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        purchase.purchaseDate != null
                            ? dateFormat(purchase.purchaseDate)
                            : '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        purchase.itemName != null ? purchase.itemName : '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          EcProductPriceText(
                            purchase?.price,
                            priceTextStyle: const TextStyle(
                              color: ColorLive.BLUE_GR,
                              fontFamily: "Roboto",
                            ),
                            includePostageTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: ColorLive.ORANGE,
                  size: 10,
                ),
              ],
            ),
            const SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}
