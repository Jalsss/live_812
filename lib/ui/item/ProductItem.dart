import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/utils/widget/ec_product_price_text.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:provider/provider.dart';

// ライバーの「マイページ＞出品中の商品」や、
// 他のユーザの「プロフィール＞出品中の商品」のリストビューの行要素。
class ProductItem extends StatelessWidget {
  final int index;
  final Product product;
  final Function onTap;

  ProductItem({this.index, this.onTap, this.product});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    product.thumbnailUrlList != null &&
                        product.thumbnailUrlList.length > 0
                        ? Container(
                      width: 100,
                      height: 100,
                      child: FadeInImage.assetNetwork(
                        placeholder: Consts.LOADING_PLACE_HOLDER_IMAGE,
                        image: product.thumbnailUrlList[0],
                        fit: BoxFit.cover,
                      ),
                    )
                        : Container(
                        width: 100,
                        height: 100,
                        child: Center(
                            child: Text(Lang.NO_IMAGE,
                                style: TextStyle(color: Colors.grey)))),
                    !product.isPublished
                        ? Container(
                            height: 20,
                            width: 100,
                            decoration: BoxDecoration(
                              color: ColorLive.RED,
                            ),
                            child: Center(
                              child: Text(
                                "SOLD OUT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      (product.isBuyable || (product.salesUserId == userModel.id)) && (product.customerUserId != null)
                          ? Text(
                              "${product.customerUserName}様専用の出品です",
                              style: const TextStyle(color: Colors.white),
                            )
                          : const SizedBox(height: 0),
                      Text(
                        (product.publicFlag ? "" : "[下書き]" ?? "") + product.name ?? '',
                        softWrap: true,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          EcProductPriceText(
                            product.price,
                            priceTextStyle: const TextStyle(
                                color: ColorLive.BLUE_GR, fontFamily: "Roboto"),
                            includePostageTextStyle: const TextStyle(
                                color: Colors.white,
                                fontFamily: "Roboto",
                                fontSize: 12),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          product.enabled
                              ? Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: ColorLive.RED),
                                  child: FlatButton(
                                    textColor: Colors.white,
                                    onPressed: () {},
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 1),
                                    child: Text(
                                      "SOLD OUT",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 110),
              child: Divider(
                height: 10,
                thickness: 1,
                color: ColorLive.BLUE_BG,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
