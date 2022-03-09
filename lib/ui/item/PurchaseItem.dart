import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/utils/widget/ec_product_price_text.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/date_format.dart';

class PurchaseItem extends StatelessWidget {
  final Purchase purchase;
  final Function onTap;
  final bool isPurchase; // 購入履歴かどうか

  PurchaseItem({this.purchase, this.onTap, this.isPurchase});

  @override
  Widget build(BuildContext context) {
    Widget _purchaseStateContainer;

    switch (purchase.state) {
      case PurchaseState.WaitingForPayment:
        _purchaseStateContainer = _statusContainer(
            '入金待ち', isPurchase ? ColorLive.RED : ColorLive.C555);
        break;
      case PurchaseState.WaitingForDeliveryDestination:
        _purchaseStateContainer = _statusContainer(
            '配送先指定待ち', isPurchase ? ColorLive.RED : ColorLive.C555);
        break;
      case PurchaseState.WaitingForDelivery:
        _purchaseStateContainer = _statusContainer(
            '発送待ち', isPurchase ? ColorLive.C555 : ColorLive.RED);
        break;
      case PurchaseState.DeliveryCompleted:
        _purchaseStateContainer = _statusContainer(
            '発送済み', isPurchase ? ColorLive.RED : ColorLive.C555);
        break;
      case PurchaseState.Completed:
        _purchaseStateContainer = _statusContainer('取引完了', ColorLive.C555);
        break;
      case PurchaseState.Cancel:
        _purchaseStateContainer = _statusContainer('キャンセル', ColorLive.C26);
        break;
      case PurchaseState.Suspend:
        _purchaseStateContainer = _statusContainer('取引一時中断中', ColorLive.RED);
        break;
      default:
        _purchaseStateContainer = _statusContainer('入金待ち', ColorLive.C555);
        break;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            Divider(
              height: 1,
              thickness: 1,
              color: ColorLive.BLUE_BG,
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    purchase.imgThumbUrl?.isNotEmpty ==
                            true /*|| purchase.imgUrlImg1 != null*/ ? Container(
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
                            child: Center(
                              child: Text(Lang.NO_IMAGE,
                                  style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                    purchase.state != PurchaseState.Cancel
                        ? Container(
                            height: 15,
                            width: 70,
                            decoration: BoxDecoration(
                              color: ColorLive.RED,
                            ),
                            child: Center(
                              child: Text(
                                "SOLD OUT",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _getPurchaseDate() ?? '',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          SizedBox(width: 40),
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white),
                                    image: DecorationImage(
                                      image: NetworkImage(isPurchase
                                          ? purchase.salesUserThumbnailUrl
                                          : purchase.purchaseUserThumbnailUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4.0,
                                ),
                                Expanded(
                                  child: Text(
                                    isPurchase
                                        ? purchase.salesUserNickname ?? ''
                                        : purchase.purchaseUserNickname ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isPurchase ? purchase.name : purchase.itemName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          EcProductPriceText(
                            purchase?.price,
                            priceTextStyle: const TextStyle(
                                color: ColorLive.BLUE_GR, fontFamily: "Roboto"),
                            includePostageTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 12.0),
                          ),
                          _purchaseStateContainer,
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10)
          ],
        ),
      ),
    );
  }

  String _getPurchaseDate() {
    DateTime date = purchase.purchaseDate ?? purchase.salesDate;
    if (date == null) return null;
    return dateFormat(date);
  }

  Widget _statusContainer(String label, Color color) {
    return Container(
      height: 20,
      width: 120,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)), color: color),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      ),
    );
  }
}
