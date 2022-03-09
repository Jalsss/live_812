import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

const List<String> SOUND_ASSET_PATHS = [
  'sounds/audiostock_84189.mp3',
  'sounds/audiostock_132041.mp3',
  'sounds/audiostock_197309.mp3',
  'sounds/audiostock_235188.mp3',
  'sounds/audiostock_192737.mp3',
  'sounds/audiostock_54815.mp3',
];

class SePlayer {
  //final _cache = AudioCache();
  //AudioPlayer _audioPlayer;
  RtcEngine _engine;

  SePlayer(RtcEngine engine) {
    _engine = engine;
    _saveSoundAssetsToLocalPath();
  }

  void dispose() {
    stop();
  }

  void initialize(int volumePercent) async {
    _engine.adjustAudioMixingPlayoutVolume(volumePercent);
  }

  Future<void> play(int index) async {
    //_audioPlayer = await _cache.play(SOUND_ASSET_PATHS[index]);

    final baseDir = await getApplicationSupportDirectory();
    final dir = Directory('${baseDir.path}/sounds');
    final bn = path.basename(SOUND_ASSET_PATHS[index]);
    await _engine.startAudioMixing(path.join(dir.path, bn), false, false, 1);
  }

  Future<void> stop() async {
    await _engine.stopAudioMixing();
  }
}

// アセットのサウンド音源をローカルに保存する
void _saveSoundAssetsToLocalPath() async {
  try {
    final baseDir = await getApplicationSupportDirectory();
    final dir = Directory('${baseDir.path}/sounds/');
    final exists = await dir.exists();
    if (!exists)
      await dir.create(recursive: true);

    await Future.wait(SOUND_ASSET_PATHS.map((assetPath) async {
      final bn = path.basename(assetPath);
      final dstFile = File(path.join(dir.path, bn));
      if (await dstFile.exists())
        return true;
      var bytes = await rootBundle.load('assets/$assetPath');
      return dstFile.writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    }));
  } catch (ee) {
    debugPrint('Exc: ${ee.toString()}');
  }
}
