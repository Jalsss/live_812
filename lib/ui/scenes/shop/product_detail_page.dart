import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/ec/purchase.dart';
import 'package:live812/domain/model/user/badge_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/product_usecase.dart';
import 'package:live812/ui/dialog/ec/buy_product_dialog.dart';
import 'package:live812/ui/dialog/ec/product_image_dialog.dart';
import 'package:live812/ui/scenes/user/history_purchase_page.dart';
import 'package:live812/ui/scenes/user/product_add_page.dart';
import 'package:live812/utils/widget/ec_product_price_text.dart';
import 'package:live812/utils/comma_format.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';

enum ProductDetailPageResult {
  PURCHASED,
}

// 商品詳細画面：購入あり（視聴者用）｜編集あり（ライバー用）｜見るだけ（購入履歴）
class ProductDetailPage extends StatefulWidget {
  final Product product;
  final String provideUserId;  // 購入や編集の場合には必要
  final Future<Product> Function() onUpdated;  // 編集の場合には必要
  final bool canPurchase;  // 購入可能？（ボタンを表示）
  final bool canEdit;  // 編集可能？（ボタンを表示）
  final bool showProfit;  // 利益を表示する？
  final Purchase purchase;  // 購入情報（利益表示に使用）

  ProductDetailPage({
    @required this.product,
    this.provideUserId,
    this.onUpdated,
    this.canPurchase = false,
    this.canEdit = false,
    this.showProfit = false,
    this.purchase,
  }) : assert(!showProfit || purchase != null);

  @override
  ProductDetailPageState createState() => ProductDetailPageState(product);
}

class ProductDetailPageState extends State<ProductDetailPage> {
  bool _isLoading = false;
  Product _product;

  ProductDetailPageState(this._product);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    return LiveScaffold(
      isLoading: _isLoading,
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.PRODUCT_DET,
      titleColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _product.imgUrlList.length == 0 ? _noImage() : Container(
            height: 300,
            margin: EdgeInsets.only(top: 10),
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        border: Border.all(color: Colors.white),
                    ),
                    child: FadeInImage.assetNetwork(
                      placeholder: Consts.LOADING_PLACE_HOLDER_IMAGE,
                      image: _product.imgUrlList[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder:
                            (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
                          return ProductImageDialog(url: _product.imgUrlList[index],);
                        },
                      ),
                    );
                  },
                );
              },
              loop: false,  // loop: true だと逆回りに動かして要素を足すとエラーが発生する
              control: SwiperControl(color: Colors.white, size: 12),
              viewportFraction: 0.8,
              scale: 1,
              itemCount: _product.imgUrlList.length,
            ),
          ),
          Positioned(
            top: 320,
            bottom: 60,
            left: 20,
            right: 20,
            child: ListView(
              padding: EdgeInsets.only(bottom: 20),
              children: <Widget>[
                (_product.isBuyable || (_product.salesUserId == userModel.id)) && (_product.customerUserId != null)
                    ? Text(
                        "${_product.customerUserName}様専用の出品です",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    : const SizedBox(height: 0),
                Text(
                  _product.name ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 10),
                _buildPrice(),
                Text(
                  _product.shippingPeriod != null
                      ? "発送予定 ${_product.shippingPeriod}日"
                      : "",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(height: 10),
                Text(
                  "${_product.memo}",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          widget.canPurchase
              ? _buildPurchaseButton()
              : !widget.canEdit
                  ? null
                  : _product.isPublished
                      ? _buildEditButton()
                      : _buildInvisiblePurchasedButton(),
        ].where((w) => w != null).toList(),
      ),
    );
  }

  Widget _buildPrice() {
    final style = const TextStyle(color: ColorLive.BLUE, fontSize: 16);
    if (!widget.showProfit) {
      return EcProductPriceText(
        _product.price,
        priceTextStyle: style,
        includePostageTextStyle:
            const TextStyle(color: Colors.white, fontSize: 12),
      );
    } else {
      return Table(
        columnWidths: {0: IntrinsicColumnWidth(), 1: IntrinsicColumnWidth(), 2: FlexColumnWidth()},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _priceRow('商品代金', _product.price),
          _priceRow('販売手数料', widget.purchase.fee),
          _priceRow('販売利益', widget.purchase.benefit),
        ],
      );
    }
  }

  TableRow _priceRow(String typeStr, int value) {
    final style = const TextStyle(color: ColorLive.BLUE, fontSize: 16);
    return TableRow(
      children: [
        TableCell(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Text(
              typeStr,
              style: style,
            ),
          ),
        ),
        TableCell(
          child: Text(
            value != null ? '¥${commaFormat(value)}' : '-',
            style: style,
            textAlign: TextAlign.right,
          ),
        ),
        TableCell(
          child: Container(),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: PrimaryButton(
        text: Lang.PURCHASE,
        onPressed: _confirmBuyProduct,
        height: 60,
      ),
    );
  }

  Widget _buildEditButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: PrimaryButton(
        text: Lang.DO_EDIT,
        onPressed: () async {
          final result = await Navigator.push(context,
            FadeRoute(builder: (context) {
              return ProductAddPage(product: _product, provideUserId: widget.provideUserId);
            }),
          );

          switch (result) {
            case ProductAddPageResult.DeleteItem:
              Navigator.of(context).pop(ProductAddPageResult.DeleteItem);
              break;
            case ProductAddPageResult.Published:
            // TODO: 変更されたので、更新を読み込む
              {
                if (widget.onUpdated == null) {
                  // 何もしない.
                  break;
                }
                final updated = await widget.onUpdated();
                if (updated != null) {
                  setState(() => _product = updated);
                }
              }
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  Widget _buildInvisiblePurchasedButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: PrimaryButton(
        text: "非表示にする",
        onPressed: () async {
          if (!await ProductUsecase.confirmHide(context)) {
            return;
          }
          final service = BackendService(context);
          setState(() {
            _isLoading = true;
          });
          final success = await ProductUsecase.requestEcItemInvisiblePurchased(service: service, itemIds: [widget.product.itemId]);
          setState(() {
            _isLoading = false;
          });
          if (success) {
            Navigator.of(context).pop(ProductAddPageResult.DeleteItem);
          }
        },
      ),
    );
  }

  Widget _noImage() {
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              Lang.NO_IMAGE,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // 決済の選択をする為のダイアログ「クレジットカード」or「銀行振込」
  Future<void> _confirmBuyProduct() async {
    final product = widget.product;
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => BuyProductDialog(
        product: product,
        provideUserId: widget.provideUserId,
        isInLiveRoom: false,
      ),
    );

    if (result == BuyProductDialogResult.PURCHASED ||
        result == BuyProductDialogResult.PURCHASED_AND_GOTO_HISTORY_PAGE) {
      // なにか購入したので、購入バッジを有効にする
      final badgeInfo = Provider.of<BadgeInfo>(context, listen: false);
      badgeInfo.purchase = true;
    }

    switch (result) {
      case BuyProductDialogResult.PURCHASED:
        // 購入成功：戻る
        Navigator.of(context).pop(ProductDetailPageResult.PURCHASED);
        break;
      case BuyProductDialogResult.PURCHASED_AND_GOTO_HISTORY_PAGE:
        // 購入成功、履歴ページに遷移
        Navigator.of(context).pop(ProductDetailPageResult.PURCHASED);
        Navigator.of(context).push(FadeRoute(
            builder: (context) => HistoryPurchasePage(
                  isTrading: true,
                )));
        break;
      default:
        break;
    }
  }
}
