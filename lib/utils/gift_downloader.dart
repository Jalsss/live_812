import 'dart:io';

import 'package:flutter/material.dart';
import 'package:live812/domain/usecase/gift_usecase.dart';
import 'package:live812/ui/dialog/network_error_dialog.dart';
import 'package:live812/utils/modal_overlay.dart';
import 'package:screen/screen.dart';

class GiftDownloader {
  GiftDownloader._();

  /// ギフトダウンロードが実行中かどうか.
  static bool _isExecute = false;

  static bool get isExecute => _isExecute;

  /// 外部リソースギフトの対象のプラットフォームかどうか.
  static bool get isTargetPlatform => GiftUseCase.isTargetPlatform;

  /// ギフトのダウンロードを実行.
  static Future<void> execute(
    BuildContext context, {
    String message = 'ギフトデータのダウンロード中...\nしばらくお待ち下さい',
    bool force = false,
  }) async {
    if (!GiftUseCase.isTargetPlatform) {
      // 対象のプラットフォームではない.
      return;
    }

    // スリープさせない.
    Screen.keepOn(true);
    // ダイアログの表示.
    _isExecute = true;
    _showDialog(context, message: message);
    try {
      if (force) {
        // 全て削除.
        await GiftUseCase.removeAllGift();
      }
      // マニフェストファイルのダウンロード.
      final serverJson = await GiftUseCase.getManifestJson();
      final localJson = await GiftUseCase.loadManifestJson();
      // バージョンを比較.
      final serverVersion = GiftUseCase.getVersion(serverJson);
      final localVersion =
          localJson.isNotEmpty ? GiftUseCase.getVersion(localJson) : 0;
      if (serverVersion > localVersion) {
        // サーバーのバージョンが新しいので保存.
        await GiftUseCase.saveManifestJson(serverJson);
      }
      // ギフト情報の読み込み.
      final giftList = await GiftUseCase.loadGiftInfoModelList();
      // 不要なファイルを削除.
      await GiftUseCase.validateUnUseGift(giftList);
      // ギフトのダウンロードと展開.
      for (final gift in giftList) {
        if (await GiftUseCase.shouldDownloadGift(gift)) {
          // ダウンロード.
          await GiftUseCase.downloadGift(gift);
          // 展開.
          await GiftUseCase.unZipGift(gift);
        }
      }
    } on HttpException catch (e) {
      print(e.toString());
      await showNetworkErrorDialog(context, msg: 'ダウンロードに失敗しました。');
    } catch (e) {
      print(e.toString());
      await showNetworkErrorDialog(context, msg: 'ダウンロードに失敗しました。');
    }
    // スリープ設定を戻す.
    Screen.keepOn(false);
    _isExecute = false;
    // ダイアログの非表示.
    _hideDialog(context);
  }

  /// ダイアログの表示.
  static void _showDialog(
    BuildContext context, {
    String message,
  }) {
    Navigator.push(
      context,
      ModalOverlay(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
        isAndroidBackEnable: false,
      ),
    );
  }

  // ダイアログを非表示.
  static void _hideDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
