import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/services.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:http/http.dart' as http;
import 'package:live812/domain/model/live/gift_info.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class GiftUseCase {
  GiftUseCase._();

  static const _manifestFileName = 'manifest.json';

  /// アニメーションが同期処理だったため、事前にロードする必要があった.
  static Directory _directory;

  static String get giftPath => (_directory?.path ?? '') + '/gift';

  /// 外部リソースギフトの対象のプラットフォームかどうか.
  static bool get isTargetPlatform => Platform.isAndroid;

  /// ドキュメントフォルダの取得.
  static Future<void> initialize() async {
    _directory = await getApplicationDocumentsDirectory();
    return;
  }

  /// マニフェストファイルサーバーから取得.
  static Future<String> getManifestJson() async {
    final uri = Injector.getInjector().get<String>(
      key: Consts.KEY_GIFT_URL,
    );
    final url = '$uri/$_manifestFileName';
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw HttpException('通信エラーが発生しました\nStatus Code : ${response.statusCode}');
    }
    if (response.bodyBytes.isEmpty) {
      throw HttpException('マニフェストファイルのロードに失敗しました');
    }
    return Utf8Decoder().convert(response.bodyBytes);
  }

  /// マニフェストのバージョンを取得.
  static int getVersion(String json) {
    try {
      final data = JsonDecoder().convert(json) as Map<String, dynamic>;
      if (!data.containsKey('version')) {
        throw Exception('Not Exist Version Key.');
      }
      return data['version'];
    } catch (e) {
      return 0;
    }
  }

  /// マニフェストファイルのローカルパス.
  static Future<String> getLocalManifestJsonPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/gift/$_manifestFileName';
  }

  /// マニフェストファイルをローカルから取得.
  static Future<String> loadManifestJson() async {
    if (!isTargetPlatform) {
      return rootBundle.loadString('assets/anim/manifest.json');
    }
    final path = await getLocalManifestJsonPath();
    final file = File(path);
    print('$path');
    if (!await file.exists()) {
      // ファイルが存在しない.
      return '';
    }
    return await file.readAsString();
  }

  /// マニフェストファイルをローカルに保存.
  static Future<void> saveManifestJson(String json) async {
    final path = await getLocalManifestJsonPath();
    var file = File(path);
    if (!await file.exists()) {
      // ファイルが存在しない場合は作成.
      file = await file.create(
        recursive: true,
      );
    }
    await file.writeAsString(
      json,
      flush: true,
    );
  }

  /// ギフト情報を取得.
  static Future<List<GiftInfoModel>> loadGiftInfoModelList() async {
    final json = await loadManifestJson();
    final data = JsonDecoder().convert(json) as Map<String, dynamic>;
    if (!data.containsKey('gift')) {
      return [];
    }
    final gifts = data['gift'] as List;
    return gifts
        .map(
          (e) => GiftInfoModel.fromJson(e),
        )
        .toList();
  }

  /// ギフトのローカルパス.
  static Future<String> getLocalGiftPath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/gift/$fileName';
  }

  /// ギフトをダウンロードすべきかどうか.
  static Future<bool> shouldDownloadGift(GiftInfoModel gift) async {
    if (gift == null) {
      return false;
    }
    if (gift.fileName.isEmpty || gift.md5.isEmpty || (gift.size == 0)) {
      // アプリに組み込まれているギフト.
      return false;
    }
    final path = await getLocalGiftPath(gift.fileName);
    var file = File(path);
    if (!await file.exists()) {
      // ファイルが存在しない.
      return true;
    }
    final md5 = crypto.md5.convert(file.readAsBytesSync()).toString();
    return gift.md5 != md5;
  }

  /// ギフトをダウンロード.
  static Future<void> downloadGift(GiftInfoModel gift) async {
    if (gift == null) {
      return;
    }
    if (gift.fileName.isEmpty || gift.md5.isEmpty || (gift.size == 0)) {
      return false;
    }

    // Zipファイルのダウンロード.
    final uri = Injector.getInjector().get<String>(
      key: Consts.KEY_GIFT_URL,
    );
    final url = '$uri/${gift.fileName}';
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw HttpException('通信エラーが発生しました\nStatus Code : ${response.statusCode}');
    }
    if (response.bodyBytes.isEmpty) {
      throw HttpException('ギフトのダウンロードに失敗しました');
    }

    // Zipファイルの保存.
    final path = await getLocalGiftPath(gift.fileName);
    var file = File(path);
    if (!await file.exists()) {
      // ファイルが存在しない場合は作成.
      file = await file.create(
        recursive: true,
      );
    }
    await file.writeAsBytes(
      response.bodyBytes,
      flush: true,
    );
  }

  /// ギフトを解凍.
  static Future<void> unZipGift(GiftInfoModel gift) async {
    final path = await getLocalGiftPath(gift.fileName);
    var zipFile = File(path);
    if (!await zipFile.exists()) {
      // ファイルが存在しない場合はなにもしない.
      return;
    }
    try {
      final directory = Directory(dirname(path));
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: directory,
      );
    } catch (e) {
      // エラーの場合は無視する.
      print(e);
      return;
    }
  }

  /// 不要なギフトの検証.
  static Future<void> validateUnUseGift(List<GiftInfoModel> giftList) async {
    final directory = Directory(await getLocalGiftPath(''));

    // 最初はzipファイルを削除.
    var entities = directory.listSync();
    for (final entity in entities) {
      if (extension(entity.path) != '.zip') {
        continue;
      }
      final targetName = basenameWithoutExtension(entity.path);
      final targetGift = giftList.firstWhere(
        (x) => basenameWithoutExtension(x.fileName) == targetName,
        orElse: () => null,
      );
      if (targetGift != null) {
        // ギフトが存在する.
        var file = File(entity.path);
        if (!await file.exists()) {
          // ファイルが存在しない.
          continue;
        }
        final md5 = crypto.md5.convert(file.readAsBytesSync()).toString();
        if (md5 == targetGift.md5) {
          // 全て同じなので何もしない.
          continue;
        }
      }
      await entity.delete(recursive: true);
    }

    // Zipファイルがないディレクトリーは削除する.
    entities = directory.listSync();
    for (final entity in entities) {
      if (extension(entity.path).isNotEmpty) {
        continue;
      }
      var file = File(entity.path + '.zip');
      if (await file.exists()) {
        continue;
      }
      await entity.delete(recursive: true);
    }
  }

  /// 全てのギフトを削除.
  /// マニフェストも削除.
  static Future<void> removeAllGift() async {
    final directory = Directory(await getLocalGiftPath(''));
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
