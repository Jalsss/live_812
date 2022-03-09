import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/ec/product_template.dart';
import 'package:live812/domain/model/ec/store_profile.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/product_usecase.dart';
import 'package:live812/ui/item/ProductCardItem.dart';
import 'package:live812/ui/item/store_profile_card_item.dart';
import 'package:live812/ui/scenes/bottomsheet/bottom_sheet_product_add_edit.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/keyboard_util.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:live812/utils/widget/product_sale_primary_button.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';

class BottomSheetProduct extends StatefulWidget {
  final List<Product> products;
  final List<StoreProfile> storeProfiles;
  final String provideUserId;
  final void Function() onBack;
  final void Function(String name, String desc, int price) onProductAdd;
  final void Function(Product product) onStartPurchase;
  final bool isLiver;

  BottomSheetProduct({
    @required this.products,
    @required this.provideUserId,
    @required this.onBack,
    this.storeProfiles,
    this.onProductAdd,
    this.onStartPurchase,
    @required this.isLiver,
  });

  @override
  _BottomSheetProductState createState() => _BottomSheetProductState();
}

class _BottomSheetProductState extends State<BottomSheetProduct> {
  int _currentIndex = 0;
  bool _isLoading = false;
  List<ProductTemplate> _templates;

  @override
  Widget build(BuildContext context) {
    final int length =
        widget.products.length + (widget.storeProfiles?.length ?? 0);
    return OrientationBuilder(
      builder: (context, orientation) {
        final mq = MediaQuery.of(context);
        double height = orientation == Orientation.portrait ? 500 : 360;
        return Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            Container(
              height: height + mq.padding.bottom,
              color: ColorLive.BLUE_BG,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    top: 2,
                    bottom: widget.isLiver ? 60 : 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        bottom: mq.padding.bottom,
                        left: mq.padding.left,
                        right: mq.padding.right,
                      ),
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                MaterialButton(
                                  minWidth: 50,
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  onPressed: () {
                                    widget.onBack();
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        Lang.BACK_MENU,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: BottomSheetProductSwiper(
                                viewportFraction: 0.8,
                                products: widget.products,
                                storeProfiles: widget.storeProfiles,
                                provideUserId: widget.provideUserId,
                                isLiver: widget.isLiver,
                                onIndexChanged: (index) {
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                                onStartPurchase: (product) {
                                  Navigator.of(context).pop();  // ボトムシートを閉じる
                                  widget.onStartPurchase(product);
                                },
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 9),
                              child: Text(
                                length == 0
                                    ? '商品がありません'
                                    : "${_currentIndex + 1}/$length",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 上部：白線
                  Positioned(
                    top: 0,
                    left: mq.padding.left,
                    right: mq.padding.right + 73,
                    height: 2,
                    child: Container(color: Colors.white),
                  ),
                  // 右上：閉じるボタン
                  Positioned(
                    top: 0,
                    right: mq.padding.right,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 20,
                        width: 73,
                        child: SvgPicture.asset("assets/svg/close.svg"),
                      ),
                    ),
                  ),
                  widget.isLiver ? _addNewItemButton(context) : Container(),
                ],
              ),
            ),
            _isLoading
                ? Container(
                    height: height,
                    child: SpinningIndicator(),
                  )
                : Container(
                    height: height,
                  ),
          ],
        );
      },
    );
  }

  Widget _addNewItemButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ProductSalePrimaryButton(
        onTap: () {
          Navigator.pop(context);
          _bottomSheetProductAdd();
        },
        onTemplateTap: () async {
          _bottomSheetProductTemplate(context);
        },
      ),
    );
  }

  // 新規商品登録
  Future<void> _bottomSheetProductAdd() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: ColorLive.BLUE_BG,
      builder: (context) {
        return BottomSheetProductAddEdit(
          onBack: () {
            KeyboardUtil.close(context);
            Navigator.of(context).pop();
          },
          onPublished: (name, desc, price) {
            if (widget.onProductAdd != null) {
              widget.onProductAdd(name, desc, price);
            }
          },
        );
      },
    );
  }

  /// テンプレートから商品登録.
  Future _bottomSheetProductTemplate(BuildContext context) async {
    if (_templates == null) {
      setState(() {
        _isLoading = true;
      });
      _templates = await ProductUsecase.requestTemplate(context);
      setState(() {
        _isLoading = false;
      });
    }
    // テンプレートを選択.
    final selected = await ProductUsecase.showTemplateDialog(context, _templates);
    if (selected == null) {
      return;
    }
    // テンプレートの作成.
    setState(() {
      _isLoading = true;
    });
    var product = await ProductUsecase.createTemplateProduct(context, selected);
    setState(() {
      _isLoading = false;
    });
    if (product == null) {
      // エラー.
      return;
    }
    // 画面遷移.
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: ColorLive.BLUE_BG,
      builder: (context) {
        return BottomSheetProductAddEdit(
          product: product,
          onBack: () {
            KeyboardUtil.close(context);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

}

class BottomSheetProductSwiper extends StatelessWidget {
  final List<Product> products;
  final List<StoreProfile> storeProfiles;
  final String provideUserId;
  final bool isLiver;
  final void Function(int page) onIndexChanged;
  final void Function(Product product) onStartPurchase;
  final double viewportFraction;

  BottomSheetProductSwiper({
    @required this.viewportFraction,
    @required this.products,
    @required this.provideUserId,
    @required this.isLiver,
    this.storeProfiles,
    this.onIndexChanged,
    this.onStartPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final storeProfileLength = storeProfiles?.length ?? 0;
    final length = products.length + storeProfileLength;
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        if ((storeProfiles != null) &&
            (storeProfileLength != 0) &&
            (storeProfileLength > index)) {
          return StoreProfileCardItem(
            storeProfile: storeProfiles[index],
          );
        }
        final product = products[index - storeProfileLength];
        return ProductCardItem(
          product: product,
          providerUserId: provideUserId,
          isLiver: isLiver,
          onTap: (type) {
            switch (type) {
              case CardItemButtonType.PURCHASE:
                onStartPurchase(product);
                break;
              case CardItemButtonType.EDIT:
                Navigator.pop(context);
                _bottomSheetProductEdit(context, product);
                break;
              case CardItemButtonType.REMOVE:
                _confirmDelete(context, product);
                break;
              case CardItemButtonType.HIDE:
                _confirmHide(context, product);
                break;
            }
          },
        );
      },
      loop: false,
      viewportFraction: viewportFraction,
      itemCount: length,
      onIndexChanged: onIndexChanged,
    );
  }

  // 商品編集
  Future<void> _bottomSheetProductEdit(BuildContext context, Product product) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: ColorLive.BLUE_BG,
      builder: (context) {
        return BottomSheetProductAddEdit(
          product: product,
          onBack: () {
            KeyboardUtil.close(context);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // 公開停止確認
  Future<void> _confirmDelete(BuildContext context, Product product) async {
    if (!await ProductUsecase.confirmDelete(context))
      return;

    final service = BackendService(context);

    final response = await service.deleteEcItem(provideUserId, product.itemId);
    if (response != null) {
      // TODO: 画面に反映
      // 閉じる.
      Navigator.of(context).pop();
    } else {
      // TODO: エラー表示
    }
  }

  // 非表示.
  Future<void> _confirmHide(BuildContext context, Product product) async {
    if (!await ProductUsecase.confirmHide(context)) {
      return;
    }
    final service = BackendService(context);
    final success = await ProductUsecase.requestEcItemInvisiblePurchased(service: service, itemIds: [product.itemId]);
    if (success) {
      // 閉じる.
      Navigator.of(context).pop();
    } else {
      // TODO: エラー表示
    }
  }
}
