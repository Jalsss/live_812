import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/user_info_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/image_util.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';

class ProfileChoosePage extends StatefulWidget {
  @override
  _ProfileChoosePageState createState() => _ProfileChoosePageState();
}

class _ProfileChoosePageState extends State<ProfileChoosePage> {
  File _image;
  var _isLoading = false;

  Future<void> _getImageFromCamera() async {
    var image = await ImageUtil.pickImage(context, ImageSource.camera);
    if (image == null)
      return;
    var file = await ImageUtil.cropImage(image.path, square: true);
    if (file == null)
      return;
    _setImage(file);
  }

  Future<void> _getImageFromGallery() async {
    var image = await ImageUtil.pickImage(context, ImageSource.gallery);
    if (image == null)
      return;
    var file = await ImageUtil.cropImage(image.path, square: true);
    if (file == null)
      return;
    _setImage(file);
  }

  void _setImage(File image) {
    setState(() {
      _image = image;
    });
  }

  Future<void> showSelectDialog() async {
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _getImageFromCamera();
                },
                child: Text('カメラ'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  _getImageFromGallery();
                },
                child: Text('ギャラリー'),
              )
            ],
          );
        });
  }

  Future<void> _requestUserImage() async {
    setState(() {
      _isLoading = true;
    });
    final base64 = _image == null ? null : ImageUtil.toBase64DataImage(_image);
    final service = BackendService(context);
    var response = await service.putUserThumb(base64);
    setState(() {
      _isLoading = false;
    });
    if (response?.result == true) {
      await _requestUpdateMyInfo();
    } else {
      await showNetworkErrorDialog(context, msg: response.getByKey('msg'));
    }
  }

  Future<void> _requestUpdateMyInfo() async {
    await _updateMyInfoUntilSuccess();

    Navigator.of(context).pushNamedAndRemoveUntil('/bottom_nav', (_) => false);
  }

  Future<void> _updateMyInfoUntilSuccess() async {
    for (;;) {
      setState(() => _isLoading = true);
      final result = await UserInfoUsecase.updateMyInfo(context);
      setState(() => _isLoading = false);
      switch (result.item1) {
        case UpdateMyInfoResult.SUCCESS:
          return;
        case UpdateMyInfoResult.NETWORK_ERROR:
        case UpdateMyInfoResult.UNAUTHENTICATED:
          await showNetworkErrorDialog(context, msg: result.item2.getByKey('msg'));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      title: 'プロフィール画像登録',
      isLoading: _isLoading,
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                SizedBox(height: 100),
                FlatButton(
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black),
                    child:  Center(
                      child: _image == null ? Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 36,
                      ) : CircleAvatar(
                        radius: 150 / 2,
                        backgroundImage: FileImage(_image),
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                  onPressed: showSelectDialog,
                ),
                SizedBox(height: 10),
                Consumer<UserModel>(
                  builder: (context, model, _) {
                    return Text(
                      model.symbol ?? 'user-id',
                      style: TextStyle(fontSize: 18.0),
                    );
                  },
                ), // ニックネーム
                Consumer<UserModel>(
                  builder: (context, model, _) {
                    return Text(model.nickname ?? 'ユーザーID');
                  },
                ),
                SizedBox(height: 100),
                MaterialButton(
                  onPressed: () {
                    _requestUpdateMyInfo();
                  },
                  child: Text(
                    Lang.SKIP,
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                )
              ],
            ),
          ),
          PrimaryButton(
            text: '登録する',
            onPressed: () {
              _requestUserImage();
            },
          ),
        ],
      ),
    );
  }
}
