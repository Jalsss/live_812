import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/product_usecase.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:live812/utils/image_util.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:live812/utils/widget/product_primary_button.dart';
import 'package:live812/utils/widget/product_terms.dart';
import 'package:provider/provider.dart';

class ProductFormLiverPage extends StatefulWidget {
  final Product product; // null=>新規登録、non null=>編集
  final void Function(String name, String desc, int price)
      onPublished; // 出品された時のコールバック
  final void Function(bool) onLoadingChanged;

  ProductFormLiverPage({
    this.product,
    this.onPublished,
    @required this.onLoadingChanged,
  });

  @override
  ProductFormLiverPageState createState() => ProductFormLiverPageState();
}

class ProductFormLiverPageState extends State<ProductFormLiverPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controllerName;
  TextEditingController _controllerDescr;
  TextEditingController _controllerShipping;
  TextEditingController _controllerPrice;
  TextEditingController _controllerCustomerId;
  SwiperController _swipeController = SwiperController();
  bool _autoValidate = false;
  bool _isOnlyForCustomer = false;

  List<dynamic> _images = List();
  List<int> _keepImageIndices;
  List<int> _deleteImageIndices;

  @override
  void dispose() {
    _controllerName?.dispose();
    _controllerDescr?.dispose();
    _controllerShipping?.dispose();
    _controllerPrice?.dispose();
    _controllerCustomerId?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controllerName = TextEditingController(text: widget.product?.name);
    _controllerDescr = TextEditingController(text: widget.product?.memo);
    _controllerShipping = TextEditingController(
        text: widget.product?.shippingPeriod?.toString() ?? "");
    _controllerPrice =
        TextEditingController(text: widget.product?.price?.toString());

    _controllerCustomerId =
        TextEditingController(text: widget.product?.customerUserId ?? "");

    _isOnlyForCustomer =
    (widget.product?.customerUserId ?? null) != null ? true : false;

    if (widget.product != null && widget.product.imgUrlList != null) {
      _keepImageIndices = List<int>();
      _deleteImageIndices = List<int>();
      for (int i = 0; i < widget.product.imgUrlList.length; ++i) {
        _images.add(widget.product.imgUrlList[i]);
        _keepImageIndices.add(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final imageHeight = mq.size.height > mq.size.width
        ? mq.size.width * 0.65
        : mq.size.height / 2.0;
    final imageViewportFrac =
        imageHeight / (mq.size.width - mq.padding.left - mq.padding.right);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: mq.padding.left,
            right: mq.padding.right,
          ),
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Column(
              children: <Widget>[
                Container(
                  height: imageHeight,
                  margin: EdgeInsets.only(top: 10),
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return index == _images.length
                          ? _chooseImage()
                          : _imageView(index);
                    },
                    loop: false, // loop: true だと逆回りに動かして要素を足すとエラーが発生する
                    control: SwiperControl(color: Colors.white, size: 12),
                    controller: _swipeController,
                    viewportFraction: imageViewportFrac,
                    scale: 1,
                    itemCount:
                        min(_images.length + 1, Consts.PRODUCT_MAX_PHOTOS),
                  ),
                ),
                !(_autoValidate && _images.isEmpty)
                    ? Container()
                    : Container(
                        child: Text(
                          Lang.ONE_OR_MORE_PICTURE_REQUIRED,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      border: Border.all(color: Colors.white, width: 1)),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        validator: CustomValidator.validateRequired,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: Lang.HINT_PRODUCT_NAME,
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          counterStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        minLines: 1,
                        maxLines: 1,
                        maxLength: Consts.PRODUCT_MAX_NAME_LENGTH,
                        controller: _controllerName,
                      ),
                      Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(
                          color: Colors.white,
                          height: 1,
                          thickness: 1,
                        ),
                      ),
                      TextFormField(
                        validator: CustomValidator.validateRequired,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: Lang.HINT_PRODUCT_DESCR,
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                          hintMaxLines: 10,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          counterStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        minLines: 4,
                        maxLines: 4,
                        maxLength: Consts.PRODUCT_MAX_DESCRIPTION_LENGTH,
                        controller: _controllerDescr,
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 30.0,
                    right: 30.0,
                    bottom: 10.0,
                  ),
                  child: Text(
                    Lang.HINT_PRODUCT_NOTE,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.start,
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
                              color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                              fillColor: Colors.white.withAlpha(20),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                              labelStyle:
                                  TextStyle(color: Colors.white, fontSize: 20),
                              hintStyle: TextStyle(
                                  color: Colors.grey[600], fontSize: 20),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6)),
                          controller: _controllerShipping,
                          keyboardType: TextInputType.number,
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
                          validator: CustomValidator.validatePrice,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          //decoration: InputDecoration(border: InputBorder.none),
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            fillColor: Colors.white.withAlpha(20),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            //labelText: Lang.SEARCH_HINT,
                            hintText: "¥ 0",
                            labelStyle:
                                TextStyle(color: Colors.white, fontSize: 20),
                            hintStyle: TextStyle(
                                color: Colors.grey[600], fontSize: 20),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                          ),
                          controller: _controllerPrice,
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
                    style: TextStyle(color: Colors.white, fontSize: 10.0),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  transform: Matrix4.translationValues(15, 0.0, 0.0),
                  child: Row(
                    children: <Widget>[
                      Theme(
                        child: Checkbox(
                          value: _isOnlyForCustomer,
                          onChanged: (value) {
                            setState(() {
                              _isOnlyForCustomer = value;
                            });
                          },
                        ),
                        data: ThemeData(
                          unselectedWidgetColor: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isOnlyForCustomer = !_isOnlyForCustomer;
                          });
                        },
                        child: Text(
                          "専用出品",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _isOnlyForCustomer
                    ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "ユーザーID",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 35),
                      Flexible(
                        child: TextFormField(
                          style: TextStyle(
                              color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                              fillColor: Colors.white.withAlpha(20),
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.white)),
                              disabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.white10)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.white)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.red)),
                              labelStyle: TextStyle(
                                  color: Colors.white, fontSize: 20),
                              hintStyle: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 20),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6)),
                          controller: _controllerCustomerId,
                          keyboardType: TextInputType.text,
                          //onFieldSubmitted: (_) {},
                        ),
                      )
                    ],
                  ),
                )
                    : Container(),
                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  child: ProductTerms(),
                ),
                SizedBox(height: 20)
              ],
            ),
          ),
        ),
        ProductPrimaryButton(
          text: !(widget.product?.publicFlag ?? false)
              ? Lang.PUBLISH
              : Lang.CHANGE,
          onPressed: _validatePublish,
          draughtText: "下書き保存",
          onDraught: () async {
            await _validatePublish(isRelease: false);
          },
          isRelease: widget.product?.publicFlag ?? false,
        ),
      ],
    );
  }

  Widget _imageView(int index) {
    dynamic ss = _images[index];
    ImageProvider imageProvider;
    if (ss is File) {
      // ローカル画像ファイル
      imageProvider = FileImage(
        ss,
      );
    } else if (ss is String) {
      // URL: 商品編集時、ネットワーク画像
      imageProvider = NetworkImage(
        ss,
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(3)),
        border: Border.all(color: Colors.white),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: RawMaterialButton(
          padding: EdgeInsets.all(10),
          shape: CircleBorder(),
          fillColor: Colors.black.withAlpha(80),
          onPressed: () {
            setState(() {
              if (index >= _images.length)
                _swipeController.move(max(index - 1, 0));

              _deleteImage(index);
            });
          },
          child: SvgPicture.asset("assets/svg/remove.svg"),
        ),
      ),
    );
  }

  void _deleteImage(int index) {
    _images.removeAt(index);
    if (_keepImageIndices != null && index < _keepImageIndices.length) {
      _deleteImageIndices.add(_keepImageIndices[index]);
      _keepImageIndices.removeAt(index);
    }
  }

  Widget _chooseImage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          border: Border.all(color: Colors.white),
          color: ColorLive.C26),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10),
            FlatButton(
              onPressed: _getGalleryImage,
              child: Column(
                children: <Widget>[
                  SvgPicture.asset("assets/svg/icon_gallery.svg"),
                  SizedBox(height: 6),
                  Text(
                    "ライブラリから\n画像を選択",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _getGalleryImage() async {
    if (_images.length >= Consts.PRODUCT_MAX_PHOTOS) return false;

    File croppedImage;
    await ImageUtil.startPickingImage(() async {
      var image = await ImageUtil.pickImage(context, ImageSource.gallery);
      if (image == null) return;
      croppedImage = await ImageUtil.cropImage(image.path, square: true);
    });
    if (croppedImage == null) return false;

    setState(() {
      _images.add(croppedImage);
    });
    //_swipeController.move(_images.length);
    return true;
  }

  Future<void> _validatePublish({bool isRelease = true}) async {
    if (!_formKey.currentState.validate() || _images.isEmpty) {
      setState(() {
        _autoValidate = true;
      });
      return Future.value(false);
    }

    final result = await _requestPost(isRelease : isRelease);
    if (result == null) {
      if (widget.onPublished != null) {
        String name = _controllerName.text;
        String desc = _controllerDescr.text;
        int price = int.tryParse(_controllerPrice.text);
        widget.onPublished(name, desc, price);
      }
      Navigator.of(context).pop();
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(Lang.ERROR),
            content: Text(result != ''
                ? result
                : Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  Future<String> _requestPost({bool isRelease = true}) async {
    String name = _controllerName.text;
    String desc = _controllerDescr.text;
    int shipping = int.tryParse(_controllerShipping.text);
    if (shipping == null ||
        (shipping < Consts.MIN_SHIPPING_DAY) ||
        (shipping > Consts.MAX_SHIPPING_DAY)) {
      return Future.value('発送予定日異常');
    }
    int price = int.tryParse(_controllerPrice.text);
    if (price == null || price <= 0) return Future.value('値段異常');
    String itemId = widget.product?.itemId;
    String customerUserId =
    _isOnlyForCustomer ? _controllerCustomerId.text : null;

    final userModel = Provider.of<UserModel>(context, listen: false);
    final service = BackendService(context);

    widget.onLoadingChanged(true);
    final result = await ProductUsecase.requestPost(name, desc, price, shipping,
        userModel: userModel,
        backendService: service,
        images: _images,
        uploadedImageIndices: widget.product?.imgListIndices,
        keepImageIndices: _keepImageIndices,
        deleteImageIndices: _deleteImageIndices,
        isRelease: isRelease,
        itemId: itemId,
        customerUserId: customerUserId);
    widget.onLoadingChanged(false);

    if (result == null) {
      // 更新に成功した場合、削除した商品画像のキャッシュをクリアする
      if (_deleteImageIndices?.isNotEmpty == true) {
        final imageUrls = _deleteImageIndices.map((index) => [
              widget.product.imgUrlList[index],
              widget.product.thumbnailUrlList[index],
            ]);
        await Future.wait(imageUrls
            .expand((list) => list)
            .map((url) => ImageUtil.evictImage(url)));
      }
    }

    return result;
  }
}
