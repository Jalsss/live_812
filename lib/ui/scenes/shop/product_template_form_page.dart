import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live812/domain/model/ec/product_template.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/image_util.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:live812/utils/widget/product_choose_image_view.dart';
import 'package:live812/utils/widget/product_image_view.dart';
import 'package:live812/utils/widget/product_terms.dart';
import 'package:provider/provider.dart';

/// テンプレート作成画面.
class ProductTemplateFormPage extends StatelessWidget {
  final ProductTemplate template;

  ProductTemplateFormPage({this.template});

  @override
  Widget build(BuildContext context) {
    return Provider<_ProductTemplateFormBloc>(
      create: (context) => _ProductTemplateFormBloc(template),
      dispose: (context, bloc) => bloc.dispose(),
      child: _ProductTemplateFormPage(),
    );
  }
}

class _ProductTemplateFormPage extends StatefulWidget {
  @override
  _ProductTemplateFormPageState createState() =>
      _ProductTemplateFormPageState();
}

class _ProductTemplateFormPageState extends State<_ProductTemplateFormPage> {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<_ProductTemplateFormBloc>(context, listen: false);
    final mq = MediaQuery.of(context);
    final imageHeight = mq.size.height > mq.size.width
        ? mq.size.width * 0.65
        : mq.size.height / 2.0;
    final imageViewportFraction =
        imageHeight / (mq.size.width - mq.padding.left - mq.padding.right);

    return StreamBuilder(
      initialData: false,
      stream: bloc.isLoading,
      builder: (context, snapshot) {
        return LiveScaffold(
          isLoading: snapshot.data,
          title: bloc.isEdit ? Lang.EDIT : Lang.NEW_REGISTRATION,
          titleColor: Colors.white,
          backgroundColor: ColorLive.MAIN_BG,
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                bottom: 60,
                child: SingleChildScrollView(
                  child: Form(
                    key: bloc.formKey,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: imageHeight,
                          margin: EdgeInsets.only(top: 10),
                          child: StreamBuilder<int>(
                              initialData: 0,
                              stream: bloc.imageCount,
                              builder: (context, snapshot) {
                                return Swiper(
                                  itemBuilder: (context, index) {
                                    var image = bloc.getImage(index);
                                    return image != null
                                        ? ProductImageView(
                                            image: image,
                                            onRemove: () async {
                                              bloc.onRemove(context, index);
                                            },
                                          )
                                        : ProductChooseImageView(
                                            cameraLabel: "商品画像を撮影",
                                            onCamera: () async {
                                              await bloc.onCamera(
                                                  context, index);
                                            },
                                            onGallery: () async {
                                              await bloc.onGallery(
                                                  context, index);
                                            },
                                          );
                                  },
                                  itemCount: Consts.PRODUCT_MAX_PHOTOS,
                                  loop: false,
                                  viewportFraction: imageViewportFraction,
                                  control: SwiperControl(
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                );
                              }),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.all(
                              Radius.circular(6),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller:
                                    bloc.templateNameTextEditingController,
                                focusNode: bloc.templateNameFocusNode,
                                validator: CustomValidator.validateRequired,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  hintText: Lang.HINT_PRODUCT_TEMPLATE_NAME,
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  counterStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                minLines: 1,
                                maxLines: 1,
                                maxLength: Consts.PRODUCT_MAX_NAME_LENGTH,
                                onFieldSubmitted: (_) {
                                  bloc.changeFocusNode(
                                      context, bloc.itemNameFocusNode);
                                },
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                indent: 10,
                                endIndent: 10,
                                color: Colors.white,
                              ),
                              TextFormField(
                                controller: bloc.itemNameTextEditingController,
                                focusNode: bloc.itemNameFocusNode,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  hintText: Lang.HINT_PRODUCT_NAME,
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  counterStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                minLines: 1,
                                maxLines: 1,
                                maxLength: Consts.PRODUCT_MAX_NAME_LENGTH,
                                onFieldSubmitted: (_) {
                                  bloc.changeFocusNode(
                                      context, bloc.memoFocusNode);
                                },
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                indent: 10,
                                endIndent: 10,
                                color: Colors.white,
                              ),
                              TextFormField(
                                controller: bloc.memoTextEditingController,
                                focusNode: bloc.memoFocusNode,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                  ),
                                  hintText: Lang.HINT_PRODUCT_DESCR,
                                  hintStyle: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  counterStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                minLines: 6,
                                maxLines: 6,
                                maxLength:
                                    Consts.PRODUCT_MAX_DESCRIPTION_LENGTH,
                                onFieldSubmitted: (_) {
                                  bloc.changeFocusNode(
                                      context, bloc.shippingPeriodFocusNode);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 30,
                            right: 30,
                            bottom: 10,
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "発送予定(${Consts.MIN_SHIPPING_DAY}〜${Consts.MAX_SHIPPING_DAY}日)",
                                style: const TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 35),
                              Flexible(
                                child: TextFormField(
                                  validator: CustomValidator.validateShipping,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white.withAlpha(20),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                    hintStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 20,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller:
                                      bloc.shippingPeriodTextEditingController,
                                  focusNode: bloc.shippingPeriodFocusNode,
                                  onFieldSubmitted: (_) {
                                    bloc.changeFocusNode(
                                        context, bloc.priceFocusNode);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "販売価格",
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 35),
                              Flexible(
                                child: TextFormField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white.withAlpha(20),
                                    filled: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    ),
                                    hintText: "¥ 0",
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                    hintStyle: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 20,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                  ),
                                  controller: bloc.priceTextEditingController,
                                  focusNode: bloc.priceFocusNode,
                                  validator: CustomValidator.validatePrice,
                                  keyboardType: TextInputType.number,
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          alignment: Alignment.centerRight,
                          child: Text(
                            Lang.INCLUDING_POSTAGE,
                            textAlign: TextAlign.start,
                            style:
                                TextStyle(color: Colors.white, fontSize: 10.0),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.0,
                          ),
                          child: ProductTerms(),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: PrimaryButton(
                  text: bloc.isEdit ? Lang.DO_EDIT : Lang.ADD,
                  onPressed: () async {
                    await bloc.onSave(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductTemplateFormBloc {
  final formKey = GlobalKey<FormState>();

  /// ローディング.
  StreamController<bool> _loadingStreamController = StreamController();

  Stream get isLoading => _loadingStreamController.stream;

  /// ID.
  int _id = null;

  /// 画像の数.
  StreamController _imageCountStreamController = StreamController<int>();

  Stream<int> get imageCount => _imageCountStreamController.stream;
  int _imageCount;

  /// 画像(URL).
  List<String> _imageUrls = List(Consts.PRODUCT_MAX_PHOTOS);

  /// 画像(バイナリ).
  List<dynamic> _imageBinaries = List(Consts.PRODUCT_MAX_PHOTOS);

  /// テンプレート名.
  TextEditingController templateNameTextEditingController;
  FocusNode templateNameFocusNode = FocusNode();

  /// 名前.
  TextEditingController itemNameTextEditingController;
  FocusNode itemNameFocusNode = FocusNode();

  /// 説明.
  TextEditingController memoTextEditingController;
  FocusNode memoFocusNode = FocusNode();

  /// 発送予定.
  TextEditingController shippingPeriodTextEditingController;
  FocusNode shippingPeriodFocusNode = FocusNode();

  /// 販売価格.
  TextEditingController priceTextEditingController;
  FocusNode priceFocusNode = FocusNode();

  /// 編集中かどうか.
  bool isEdit;

  _ProductTemplateFormBloc(ProductTemplate template) {
    isEdit = template != null;
    templateNameTextEditingController =
        TextEditingController(text: isEdit ? template.name : "");
    itemNameTextEditingController =
        TextEditingController(text: isEdit ? template.itemName : "");
    memoTextEditingController =
        TextEditingController(text: isEdit ? template.memo : "");
    shippingPeriodTextEditingController = TextEditingController(
        text: isEdit ? template.shippingPeriod.toString() : "");
    priceTextEditingController =
        TextEditingController(text: isEdit ? template.price.toString() : "");

    if (isEdit) {
      _id = template.id;
      _imageUrls = template.imgUrls;
      _imageCount = template.imgUrls.where((x) => x != null).length;
    }
  }

  /// ローディングを設定.
  void _setLoading(bool value) {
    _loadingStreamController.sink.add(value);
  }

  /// フォーカスの変更.
  void changeFocusNode(BuildContext context, FocusNode nextFocusNode) {
    FocusScope.of(context).requestFocus(nextFocusNode);
  }

  /// URLもしくは画像を取得.
  dynamic getImage(int index) {
    return _imageUrls[index] != null
        ? _imageUrls[index]
        : _imageBinaries[index];
  }

  /// 撮影.
  Future onCamera(BuildContext context, int index) async {
    var image = await ImageUtil.pickImage(context, ImageSource.camera);
    if (image == null) {
      return;
    }

    var cropped = await ImageUtil.cropImage(image.path, square: true);
    if (cropped == null) {
      return;
    }
    _imageBinaries[index] = cropped;
    _setImageCount();
  }

  /// カメラロールから写真を選択.
  Future onGallery(BuildContext context, int index) async {
    var image = await ImageUtil.pickImage(context, ImageSource.gallery);
    if (image == null) {
      return;
    }
    var cropped = await ImageUtil.cropImage(image.path, square: true);
    if (cropped == null) {
      return;
    }
    _imageBinaries[index] = cropped;
    _setImageCount();
  }

  /// 画像の削除.
  Future onRemove(BuildContext context, int index) async {
    _imageUrls[index] = null;
    _imageBinaries[index] = null;
    _setImageCount();
  }

  /// 画像の個数を設定.
  void _setImageCount() {
    _imageCount = _imageUrls.where((x) => x != null).length +
        _imageBinaries.where((x) => x != null).length;
    _imageCountStreamController.sink.add(_imageCount);
  }

  /// 保存.
  Future onSave(BuildContext context) async {
    if (!formKey.currentState.validate()) {
      return;
    }

    int shippingPeriod = int.tryParse(shippingPeriodTextEditingController.text);
    int price = int.tryParse(priceTextEditingController.text);

    _setLoading(true);

    final service = BackendService(context);

    List base64Images = List(Consts.PRODUCT_MAX_PHOTOS);
    for (int i = 0; i < _imageBinaries.length; i++) {
      if (_imageBinaries[i] != null) {
        base64Images[i] = await _imageConvert(_imageBinaries[i]);
      }
    }

    final response = await service.postEcTemplate(
      id: _id,
      name: templateNameTextEditingController.text,
      itemName: itemNameTextEditingController.text,
      memo: memoTextEditingController.text,
      shippingPeriod: shippingPeriod,
      price: price,
      base64Images: base64Images,
      imageUrls: _imageUrls,
    );
    _setLoading(false);
    if (!(response?.result ?? false)) {
      String error = response?.getByKey("msg");
      // エラー.
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Lang.ERROR),
            content: Text(error != null
                ? error
                : Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    }
    // 前の画面へ.
    Navigator.pop(context, response.getData());
  }

  /// リサイズ及びBase64に変換.
  Future<String> _imageConvert(dynamic image) async {
    final resizedImage =
        await ImageUtil.shrinkIfNeeded(image, Consts.PRODUCT_IMAGE_WIDTH);
    return ImageUtil.toBase64DataImage(resizedImage);
  }

  void dispose() {
    _loadingStreamController?.close();
    _imageCountStreamController?.close();
    templateNameTextEditingController?.dispose();
    itemNameTextEditingController?.dispose();
    memoTextEditingController?.dispose();
    shippingPeriodTextEditingController?.dispose();
    priceTextEditingController?.dispose();
  }
}
