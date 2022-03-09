import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/ec/product_template.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/product_usecase.dart';
import 'package:live812/ui/item/ProductItem.dart';
import 'package:live812/ui/scenes/shop/product_detail_page.dart';
import 'package:live812/ui/scenes/user/product_add_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/route/fade_route.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/product_sale_primary_button.dart';
import 'package:provider/provider.dart';

class ProductSalePage extends StatefulWidget {
  final bool isDraft;

  ProductSalePage({this.isDraft = false});

  @override
  _ProductSalePageState createState() => _ProductSalePageState();
}

class _ProductSalePageState extends State<ProductSalePage> {
  bool _isLoading = true;
  List<Product> _productList;
  String _provideUserId;
  String _errorMessage;
  List<ProductTemplate> _templateList;

  @override
  void initState() {
    super.initState();
    _requestProductList();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      isLoading: _isLoading,
      backgroundColor: ColorLive.MAIN_BG,
      title: widget.isDraft ? Lang.PRODUCT_DRAFT_LIST : Lang.PRODUCT_SALE_LIST,
      titleColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            bottom: 60,
            child: _errorMessage != null ? Container(
              padding: EdgeInsets.all(12),
              child: Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ) : _productList == null ? Container() : _buildProductList(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ProductSalePrimaryButton(
              onTap: _startAddProduct,
              onTemplateTap: () async {
                await _startAddTemplateProduct(context);
              },
            ),
          )
        ],
      ),
    );
  }

  Future<bool> _requestProductList() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provideUserId = userModel.id;
    final response = await service.getEcItem(provideUserId);
    setState(() {_isLoading = false;});
    if (response.result == true) {
      final data = response.getData() as List;
      List<Product> products = [];
      for (final info in data) {
        final product =  Product.fromJson(info);
        if (product.publicFlag == !widget.isDraft) {
          products.add(product);
        }
      }
      _provideUserId = provideUserId;
      if (products.length > 0) {
        setState(() => _productList = products);
        return true;
      }

      setState(() => _errorMessage =
          !widget.isDraft ? Lang.ERROR_NO_PRODUCTS : Lang.ERROR_NO_DRAFT);
    } else {
      setState(() => _errorMessage = Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER);
    }

    return false;
  }

  Widget _buildProductList() {
    return ListView(
      padding: EdgeInsets.only(top: 0),
      children: List.generate(_productList.length, (index) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: ProductItem(
            index: index,
            product: _productList[index],
            onTap: () {
              _startViewProductDetail(_productList[index]);
            },
          ),
        );
      }),
    );
  }

  // 新規商品登録へ
  void _startAddProduct() async {
    final result = await Navigator.push(context,
        FadeRoute(builder: (context) => ProductAddPage()));

    if (result == ProductAddPageResult.Published) {
      // 新規に商品が出品されたので、リストを更新する
      await _requestProductList();
    }
  }

  /// テンプレートから新規商品登録.
  Future _startAddTemplateProduct(BuildContext context) async {
    if (_templateList == null) {
      setState(() {
        _isLoading = true;
      });
      _templateList = await ProductUsecase.requestTemplate(context);
      setState(() {
        _isLoading = false;
      });
    }
    // テンプレートを選択.
    final selected = await ProductUsecase.showTemplateDialog(context, _templateList);
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
      // エラーなので何もしない.
      return;
    }
    // 編集画面へ遷移.
    await Navigator.push(context,
        FadeRoute(builder: (context) => ProductAddPage(product: product)));
    // 一覧の更新.
    await _requestProductList();
  }

  // 商品詳細画面へ
  void _startViewProductDetail(Product product) async {
    final result = await Navigator.push(
        context,
        FadeRoute(
            builder: (context) => ProductDetailPage(
              product: product,
              provideUserId: _provideUserId,
              canEdit: true,
              onUpdated: () async {
                final productId = product.itemId;
                final result = await _requestProductList();
                if (result && _productList != null) {
                  final newProduct = _productList.firstWhere((p) => p.itemId == productId, orElse: () => null);
                  if (newProduct != null) {
                    return Future.value(newProduct);
                  } else {
                    // もう1つ画面を戻る.
                    Navigator.pop(context);
                    return null;
                  }
                } else {
                  // TODO: 失敗したらどうするか？
                  return null;
                }
              },
            )));

    if (result == ProductAddPageResult.DeleteItem) {
      // アイテムが削除されてたら、リストからも削除してやる
      setState(() {
        _productList.remove(product);
      });
    }
  }
}
