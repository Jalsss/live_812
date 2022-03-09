import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live812/domain/model/ec/store_profile.dart';
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
import 'package:provider/provider.dart';

class StoreProfileEditPage extends StatelessWidget {
  final StoreProfile storeProfile;
  final Function(List<StoreProfile>) onUpdate;

  StoreProfileEditPage({this.storeProfile, this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Provider<_StoreProfileEditPageBloc>(
      create: (context) => _StoreProfileEditPageBloc(
        storeProfile: storeProfile,
        onUpdate: onUpdate,
      ),
      dispose: (context, bloc) => bloc.dispose(),
      child: _StoreProfileEditPage(),
    );
  }
}

class _StoreProfileEditPage extends StatefulWidget {
  @override
  _StoreProfileEditPageState createState() => _StoreProfileEditPageState();
}

class _StoreProfileEditPageState extends State<_StoreProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<_StoreProfileEditPageBloc>(context, listen: false);
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
          title: Lang.STORE_PROFILE,
          titleColor: Colors.white,
          actions: <Widget>[
            bloc.isNew
                ? Container()
                : IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.white,
                    onPressed: () async {
                      await bloc.onDelete(context);
                    },
                  ),
          ],
          backgroundColor: ColorLive.MAIN_BG,
          body: Stack(
            children: <Widget>[
              Positioned.fill(
                bottom: 60,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
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
                                            cameraLabel: "プロフィール画像を撮影",
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
                        StreamBuilder<Object>(
                          initialData: true,
                          stream: bloc.isImageValidate,
                          builder: (context, snapshot) {
                            return snapshot.data
                                ? Container()
                                : Container(
                                    child: Text(
                                      Lang.ONE_OR_MORE_PICTURE_REQUIRED,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                          },
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
                                controller: bloc.nameTextEditingController,
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
                                  hintText: Lang.HINT_STORE_PROFILE_TITLE,
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
                                maxLength:
                                    Consts.STORE_PROFILE_MAX_TITLE_LENGTH,
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
                                  hintText: Lang.HINT_STORE_PROFILE_DESCRIPTION,
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
                                    Consts.STORE_PROFILE_MAX_DESCRIPTION_LENGTH,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                          ),
                          child: StreamBuilder<bool>(
                              initialData: false,
                              stream: bloc.isPublic,
                              builder: (context, snapshot) {
                                return Row(
                                  children: <Widget>[
                                    Theme(
                                      child: Checkbox(
                                        value: snapshot.data,
                                        onChanged: (value) {
                                          bloc.onChangePublic(value);
                                        },
                                      ),
                                      data: ThemeData(
                                        unselectedWidgetColor: Colors.white,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        bloc.onChangePublic(!snapshot.data);
                                      },
                                      child: Text(
                                        "公開する",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: PrimaryButton(
                  text: "保存",
                  onPressed: () async {
                    await bloc.onSave(context, _formKey);
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

class _StoreProfileEditPageBloc {
  /// ローディング.
  StreamController _loadingStreamController = StreamController<bool>();

  /// ローディング.
  Stream<bool> get isLoading => _loadingStreamController.stream;

  bool isNew = false;

  /// インデックス.
  int _index;

  /// 画像の数.
  StreamController _imageCountStreamController = StreamController<int>();

  Stream<int> get imageCount => _imageCountStreamController.stream;
  int _imageCount;

  /// 画像(URL).
  List<String> _imageUrls = List(Consts.PRODUCT_MAX_PHOTOS);

  /// 画像(バイナリ).
  List<dynamic> _imageBinaries = List(Consts.PRODUCT_MAX_PHOTOS);

  /// 概要.
  TextEditingController nameTextEditingController;

  /// 説明.
  TextEditingController memoTextEditingController;

  /// 公開設定.
  StreamController _isPublicStreamController = StreamController<bool>();

  Stream<bool> get isPublic => _isPublicStreamController.stream;
  bool _isPublic;

  /// 画像の検証.
  StreamController _imageValidateStreamController = StreamController<bool>();

  Stream<bool> get isImageValidate => _imageValidateStreamController.stream;

  Function(List<StoreProfile>) _onUpdate;

  _StoreProfileEditPageBloc({
    StoreProfile storeProfile,
    Function(List<StoreProfile>) onUpdate,
  }) {
    final profile = storeProfile != null ? storeProfile : StoreProfile();
    _index = profile.index;
    isNew = (_index == null);
    nameTextEditingController = TextEditingController(
      text: profile.itemName,
    );
    memoTextEditingController = TextEditingController(
      text: profile.memo,
    );

    _imageUrls = profile.imgUrls;
    _imageCount = profile.imgUrls.where((x) => x != null).length;
    _isPublic = profile?.publicFlag ?? false;
    _isPublicStreamController.sink.add(_isPublic);
    _onUpdate = onUpdate;
  }

  void onLoading(bool value) {
    _loadingStreamController.sink.add(value);
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

  /// 公開設定.
  Future onChangePublic(bool value) async {
    _isPublic = value;
    _isPublicStreamController.sink.add(_isPublic);
  }

  /// 保存.
  Future onSave(BuildContext context, GlobalKey<FormState> formKey) async {
    if (_isPublic) {
      // 公開設定.
      var isValidated = formKey.currentState.validate();
      _imageValidateStreamController.sink.add(_imageCount > 0);
      if ((!isValidated) || (_imageCount <= 0)) {
        return;
      }
    }
    final service = BackendService(context);
    _loadingStreamController.add(true);

    List base64Images = List(Consts.PRODUCT_MAX_PHOTOS);
    for (int i = 0; i < _imageBinaries.length; i++) {
      if (_imageBinaries[i] != null) {
        base64Images[i] = await _imageConvert(_imageBinaries[i]);
      }
    }

    final response = await service.postStoreProfile(
      index: _index,
      itemName: nameTextEditingController.text,
      memo: memoTextEditingController.text,
      publicFlag: _isPublic,
      base64Images: base64Images,
      imageUrls: _imageUrls,
    );
    _loadingStreamController.add(false);
    if (response?.result ?? false) {
      // 保存成功.
      if (!isNew) {
        var storeProfileList = [];
        final data = response.getData() as List;
        if (data != null) {
          storeProfileList = data.map((x) => StoreProfile.fromJson(x)).toList();
        }
        if (_onUpdate != null) {
          await Future.value(_onUpdate(storeProfileList));
        }
      }
      Navigator.pop(context);
    } else {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("エラー"),
            content: const Text("ストアプロフィールの保存に失敗しました"),
            actions: <Widget>[
              // ボタン領域
              FlatButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }
  }

  /// リサイズ及びBase64に変換.
  Future<String> _imageConvert(dynamic image) async {
    final resizedImage =
        await ImageUtil.shrinkIfNeeded(image, Consts.PRODUCT_IMAGE_WIDTH);
    return ImageUtil.toBase64DataImage(resizedImage);
  }

  /// 削除.
  Future onDelete(BuildContext context) async {
    final exeDelete = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              title: const Text('削除'),
              content: const Text('本当にストアプロフィールを削除しますか？'),
              actions: [
                FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                FlatButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ==
        true;

    if (!exeDelete) {
      return;
    }
    final service = BackendService(context);
    onLoading(true);
    final response1 = await service.deleteStoreProfile(index: _index);
    onLoading(false);
    final result1 = response1?.result ?? false;
    if (!result1) {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("エラー"),
            content: const Text("ストアプロフィールの削除に失敗しました"),
            actions: <Widget>[
              // ボタン領域
              FlatButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
      return;
    }

    onLoading(true);
    final response2 = await service.getStoreProfile();
    onLoading(false);
    final result2 = response2?.result ?? false;
    if (!result2) {
      await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("エラー"),
            content: const Text("ストアプロフィールの取得に失敗しました"),
            actions: <Widget>[
              // ボタン領域
              FlatButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
      // 2画面戻る.
      int count = 0;
      Navigator.popUntil(context, (_) => count++ >= 3);
      return;
    }
    List<StoreProfile> storeProfileList = [];
    final data = response2.getData() as List;
    if (data != null) {
      storeProfileList = data.map((x) => StoreProfile.fromJson(x)).toList();
    }
    if (_onUpdate != null) {
      await Future.value(_onUpdate(storeProfileList));
    }
    // 2画面戻る.
    int count = 0;
    Navigator.popUntil(context, (_) => count++ >= 2);
  }

  void dispose() {
    _loadingStreamController?.close();
    _imageCountStreamController?.close();
    nameTextEditingController?.dispose();
    memoTextEditingController?.dispose();
    _isPublicStreamController?.close();
    _imageValidateStreamController?.close();
  }
}
