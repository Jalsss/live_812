import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';

enum ImageType {
  UNKNOWN,
  JPEG,
  PNG,
}

const int CROP_MAX_LENGTH = 2048;  // クロップに渡す画像サイズの上限

class ImageUtil {
  static bool _isPickingImage = false;
  static bool get isPickingImage => _isPickingImage;

  // 必要なパーミッションが許可されているかどうか調べる
  static Future<PickedFile> pickImage(BuildContext context, ImageSource source) async {
    if (!await _requestPermission(context))
      return null;

    final picker = ImagePicker();
    return await picker.getImage(source: source);
  }

  // 必要なパーミッションが許可されているかどうか調べ、なかったらダイアログを表示
  static Future<bool> _requestPermission(BuildContext context) async {
    final permissionHandler = PermissionHandler();
    final status = await permissionHandler.requestPermissions([PermissionGroup.storage, PermissionGroup.photos]);
    if (status != null &&
        status.keys.every((key) => status[key] == PermissionStatus.granted)) {
      return true;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("パーミッションエラー"),
          content: Text('写真をアップロードできるようにするためにアクセス権限を与えてください。\n権限の変更は本体の設定から行ってください。'),
          actions: <Widget>[
            FlatButton(
              child: Text("設定を開く"),
              onPressed: () => permissionHandler.openAppSettings(),
            ),
            FlatButton(
              child: Text("閉じる"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
    return false;
  }


  static Future startPickingImage(Future Function() proc) async {
    _isPickingImage = true;
    final result = await proc();
    _isPickingImage = false;
    return result;
  }

  static Future<File> cropImage(String filePath, {bool square=false}) async {
    // Androidで元画像のサイズがあまりでかいとクロップで例外が出るため、
    // 必要であれば事前に縮小する。
    File originalFile = File(filePath);
    File shrinked = await shrinkIfNeeded(originalFile, CROP_MAX_LENGTH);
    filePath = shrinked.path;

    final title = 'サイズ調整';
    File croppedFile;
    if (square) {
      croppedFile = await ImageCropper.cropImage(
        sourcePath: filePath,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
      );
    } else {
      croppedFile = await ImageCropper.cropImage(
        sourcePath: filePath,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: Colors.white,
            toolbarWidgetColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      );
    }
    return croppedFile;
  }

  static String toBase64DataImage(File file) {
    final encoded = base64Encode(file.readAsBytesSync());
    switch (ImageUtil.detectImageType((file))) {
      case ImageType.JPEG:
        return 'data:image/jpeg;base64,$encoded';
      case ImageType.PNG:
        return 'data:image/png;base64,$encoded';
        break;
      default:
        return null;
    }
  }

  static ImageType detectImageType(File file) {
    final ext = extension(file.path).toLowerCase();
    if (ext == '.jpeg' || ext == '.jpg')
      return ImageType.JPEG;
    if (ext == '.png')
      return ImageType.PNG;
    return ImageType.UNKNOWN;
  }

  // 画像の縦横長い辺がmaxLengthより長かったらリサイズする
  static Future<File> shrinkIfNeeded(File file, int maxLength) async {
    final props = await FlutterNativeImage.getImageProperties(file.path);
    int width = props.width, height = props.height;
    if (width <= maxLength && height <= maxLength)
      return Future.value(file);

    int w = width, h = height;
    if (width > height) {
      h = height * maxLength ~/ width;
      w = maxLength;
    } else {
      w = width * maxLength ~/ height;
      h = maxLength;
    }
    return FlutterNativeImage.compressImage(file.path, targetWidth: w, targetHeight: h);
  }

  // 指定URLのキャッシュをクリア https://stackoverflow.com/a/55125547
  static Future<bool> evictImage(String url) async {
    if (url == null)
      return null;
    final provider = NetworkImage(url);
    return provider.evict();
  }
}
