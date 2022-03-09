import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/ui/scenes/shop/product_form_liver_page.dart';
import 'package:live812/utils/widget/spinning_indicator.dart';

// ライブ中の新規商品追加、または編集
class BottomSheetProductAddEdit extends StatefulWidget {
  final Product product;  // null=>新規登録、non null=>編集
  final void Function() onBack;
  final void Function(String name, String desc, int price) onPublished;

  BottomSheetProductAddEdit({this.product, @required this.onBack, this.onPublished});

  @override
  _BottomSheetProductAddEditState createState() => _BottomSheetProductAddEditState();
}

class _BottomSheetProductAddEditState extends State<BottomSheetProductAddEdit> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return OrientationBuilder(
      builder: (context, orientation) {
        return Container(
          height: orientation == Orientation.portrait ? 525 : 380,
          padding: EdgeInsets.only(bottom: mq.padding.bottom + mq.viewInsets.bottom),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: mq.padding.left,
                      right: mq.padding.right,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Container(
                          height: 48,
                          padding: EdgeInsets.only(left: 15),
                          child: MaterialButton(
                            minWidth: 50,
                            padding: EdgeInsets.symmetric(horizontal: 2),
                            onPressed: () {
                              widget.onBack();
                            },
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "キャンセル（保存されません）",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 20,
                              width: 73,
                              child: SvgPicture.asset(
                                "assets/svg/close.svg",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ProductFormLiverPage(
                        product: widget.product,
                        onPublished: widget.onPublished,
                        onLoadingChanged: (loading) {
                          setState(() => _isLoading = loading);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              !_isLoading ? null : SpinningIndicator(),
            ].where((w) => w != null).toList(),
          ),
        );
      }
    );
  }
}
