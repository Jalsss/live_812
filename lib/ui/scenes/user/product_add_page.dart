import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/product_usecase.dart';
import 'package:live812/ui/scenes/shop/product_form_page.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';

enum ProductAddPageResult {
  Cancel,     // キャンセル（未使用）
  Published,  // 商品が出品（または編集）された
  DeleteItem,  // 商品が削除された
}

// 商品の追加、または編集
class ProductAddPage extends StatefulWidget {
  final Product product;  // productが与えられていたら追加じゃなく編集
  final String provideUserId;

  ProductAddPage({this.product, this.provideUserId});

  @override
  ProductAddPageState createState() => ProductAddPageState();
}

class ProductAddPageState extends State<ProductAddPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: widget.product == null ? Lang.ADD_NEW_PRODUCT : Lang.EDIT_PRODUCT,
      titleColor: Colors.white,
      actions: widget.product == null ? null : [
        IconButton(
          icon: Icon(Icons.delete),
          color: Colors.white,
          onPressed: _confirmDelete,
        ),
      ],
      body: ProductFormPage(
        product: widget.product,
        onPublished: () {
          Navigator.of(context).pop(ProductAddPageResult.Published);
        },
      ),
    );
  }

  Future<void> _confirmDelete() async {
    if (!await ProductUsecase.confirmDelete(context))
      return;

    final service = BackendService(context);

    final response = await service.deleteEcItem(widget.provideUserId, widget.product.itemId);
    if (response?.result == true) {
      Navigator.of(context).pop(ProductAddPageResult.DeleteItem);
    } else {
      String reason = response?.getByKey('msg') ?? '商品の削除に失敗しました';

      await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(Lang.ERROR),
              content: Text(reason),
              actions: <Widget>[
                FlatButton(
                  child: Text('閉じる'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }
}
