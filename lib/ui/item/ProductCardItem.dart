import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/ui/dialog/ec/product_image_dialog.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/ec_product_price_text.dart';
import 'package:provider/provider.dart';

enum CardItemButtonType {
  PURCHASE, // 視聴者：購入ボタン
  EDIT, // ライバー：編集ボタン
  REMOVE, // ライバー：公開停止
  HIDE,
}

// ライブ中の商品カード
class ProductCardItem extends StatelessWidget {
  final Product product;
  final String providerUserId;
  final bool isLiver;
  final void Function(CardItemButtonType) onTap;

  ProductCardItem({
    @required this.product,
    @required this.providerUserId,
    @required this.isLiver,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    return OrientationBuilder(builder: (context, orientation) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      height: orientation == Orientation.landscape ? 90 : 120,
                      margin: product?.customerUserId != userModel.symbol
                          ? const EdgeInsets.only(top: 4)
                          : null,
                      child: product.thumbnailUrlList == null ||
                              product.thumbnailUrlList.length == 0
                          ? Container(
                              child: const Center(
                                child: Text(
                                  Lang.NO_IMAGE,
                                  style: TextStyle(color: ColorLive.C26),
                                ),
                              ),
                            )
                          : LayoutBuilder(builder: (context, size) {
                              return Swiper(
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(3),
                                        ),
                                        border: Border.all(
                                          color: const Color(0x40000000),
                                        ),
                                      ),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                            Consts.LOADING_PLACE_HOLDER_IMAGE,
                                        image: product.thumbnailUrlList[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          opaque: false,
                                          pageBuilder: (BuildContext context,
                                              Animation<double> animation,
                                              Animation<double>
                                                  secondaryAnimation) {
                                            return ProductImageDialog(
                                              url: product.imgUrlList[index],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                loop: false,
                                control: product.thumbnailUrlList.length < 2
                                    ? null
                                    : const SwiperControl(
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                viewportFraction:
                                    size.maxHeight / size.maxWidth,
                                scale: 1,
                                itemCount: product.thumbnailUrlList.length,
                              );
                            }),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              (product.isBuyable || (product.salesUserId == userModel.id)) && (product.customerUserId != null)
                                  ? Text("${product.customerUserName}様専用の出品です")
                                  : const SizedBox(height: 0),
                              Text((product.publicFlag ? "" : "[下書き]" ?? "") +
                                      product.name ??
                                  ''),
                              EcProductPriceText(
                                product.price,
                                priceTextStyle: const TextStyle(
                                  color: ColorLive.BLUE,
                                  fontSize: 12,
                                ),
                                includePostageTextStyle: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                product.shippingPeriod != null
                                    ? "発送予定 ${product.shippingPeriod}日"
                                    : "",
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                product.memo,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: product?.customerUserId != userModel.symbol
                      ? null
                      : Border.all(
                          color: ColorLive.ORANGE,
                          width: 5,
                        ),
                ),
              ),
            ),
            isLiver ? _liverWidget() : _audienceWidget(context),
          ].where((w) => w != null).toList(),
        ),
      );
    });
  }

  Widget _liverWidget() {
    if (product.isPublished) {
      return Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 40.0,
              decoration: const BoxDecoration(color: ColorLive.C555),
              child: FlatButton(
                textColor: Colors.white,
                onPressed: () {
                  onTap(CardItemButtonType.EDIT);
                },
                child: const Text(
                  Lang.EDIT,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40.0,
              //width: double.infinity,
              decoration: const BoxDecoration(color: ColorLive.C99),
              child: FlatButton(
                textColor: Colors.white,
                onPressed: () {
                  onTap(CardItemButtonType.REMOVE);
                },
                child: const Text(
                  Lang.SUSPEND,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        height: 40.0,
        width: double.infinity,
        color: ColorLive.RED,
        child: FlatButton(
          child: const Text(
            "非表示にする",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            onTap(CardItemButtonType.HIDE);
          },
        ),
      );
    }
  }

  Widget _audienceWidget(BuildContext context) {
    if (product.isPublished) {
      if (product.isBuyable) {
        return Container(
          height: 40.0,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
            ),
          ),
          child: FlatButton(
            textColor: Colors.white,
            onPressed: () {
              onTap(CardItemButtonType.PURCHASE);
            },
            child: const Text(
              Lang.PURCHASE,
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      } else {
        return const SizedBox(height: 0);
      }
    } else {
      return Container(
        height: 40.0,
        width: double.infinity,
        color: ColorLive.RED,
        child: const Center(
          child: Text(
            "SOLD OUT",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }
}
