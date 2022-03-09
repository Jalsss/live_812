import 'dart:convert';

import 'package:live812/domain/model/live/beautification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeautificationUseCase {
  BeautificationUseCase._();

  static Beautification _beautification;
  static SharedPreferences _preferences;
  static String _enableKey = 'live812_enable_beautification';
  static String _key = 'live812_faceunity';

  /// 美顔のON/OFF設定の取得.
  static Future<bool> getEnable() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    return _preferences.getBool(_enableKey) ?? false;
  }

  /// 美顔のON/OFF設定の変更.
  static Future<bool> setEnable(bool value) async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    return _preferences.setBool(_enableKey, value);
  }

  /// 美顔設定を取得.
  static Future<Beautification> load() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    if (_beautification == null) {
      final value = json.decode(_preferences.getString(_key) ?? '{}');
      _beautification = Beautification.fromJson(value);
    }
    return Future.value(_beautification);
  }

  /// 美顔設定を保存.
  static Future<void> save(Beautification beautification) async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    _beautification = beautification;
    final value = json.encode(beautification.toMap());
    await _preferences.setString(_key, value);
  }

  static Future<void> setFilter(
      BeautificationFilterType type, int value) async {
    _beautification = await load();
    switch (type) {
      case BeautificationFilterType.off:
        break;
      case BeautificationFilterType.bright:
        _beautification.filterBright = value;
        break;
      case BeautificationFilterType.pink:
        _beautification.filterPink = value;
        break;
      case BeautificationFilterType.unique:
        _beautification.filterUnique = value;
        break;
      case BeautificationFilterType.sepia:
        _beautification.filterSepia = value;
        break;
      case BeautificationFilterType.cool:
        _beautification.filterCool = value;
        break;
      case BeautificationFilterType.warm:
        _beautification.filterWarm = value;
        break;
      case BeautificationFilterType.fresh:
        _beautification.filterFresh = value;
        break;
    }
    _beautification.selectedFilter = type.index;
    if (type.index >= BeautificationFilterType.max.index) {
      _beautification.selectedFilter = BeautificationFilterType.off.index;
    }
    await save(_beautification);
  }

  static Future<void> setColorLevel(int colorLevel) async {
    _beautification = await load();
    _beautification?.colorLevel = colorLevel;
    await save(_beautification);
  }

  static Future<void> setRedLevel(int redLevel) async {
    _beautification = await load();
    _beautification.redLevel = redLevel;
    await save(_beautification);
  }

  static Future<void> setBlurLevel(int blurLevel) async {
    _beautification = await load();
    _beautification.blurLevel = blurLevel;
    await save(_beautification);
  }

  static Future<void> setToothWhiten(int toothWhiten) async {
    _beautification = await load();
    _beautification.toothWhiten = toothWhiten;
    await save(_beautification);
  }

  static Future<void> setEyeEnlarging(int eyeEnlarging) async {
    _beautification = await load();
    _beautification.eyeEnlarging = eyeEnlarging;
    await save(_beautification);
  }

  static Future<void> setCheekThinning(int cheekThinning) async {
    _beautification = await load();
    _beautification.cheekThinning = cheekThinning;
    await save(_beautification);
  }

  static Future<void> setIntensityForehead(int intensityForehead) async {
    _beautification = await load();
    _beautification.intensityForehead = intensityForehead;
    await save(_beautification);
  }

  static Future<void> setIntensityChin(int intensityChin) async {
    _beautification = await load();
    _beautification.intensityChin = intensityChin;
    await save(_beautification);
  }

  static Future<void> setIntensityNose(int intensityNose) async {
    _beautification = await load();
    _beautification.intensityNose = intensityNose;
    await save(_beautification);
  }

  static Future<void> setIntensityMouth(int intensityMouth) async {
    _beautification = await load();
    _beautification.intensityMouth = intensityMouth;
    await save(_beautification);
  }

  static Future<Beautification> resetSkin() async {
    _beautification = await load();
    _beautification.colorLevel = BeautificationSkin.defaultColorLevel;
    _beautification.redLevel = BeautificationSkin.defaultRedLevel;
    _beautification.blurLevel = BeautificationSkin.defaultBlurLevel;
    _beautification.toothWhiten = BeautificationSkin.defaultToothWhiten;
    await save(_beautification);
    return _beautification;
  }

  static Future<Beautification> resetShape() async {
    _beautification = await load();
    _beautification.eyeEnlarging = BeautificationShape.defaultEyeEnlarging;
    _beautification.cheekThinning = BeautificationShape.defaultCheekThinning;
    _beautification.intensityForehead =
        BeautificationShape.defaultIntensityForehead;
    _beautification.intensityChin = BeautificationShape.defaultIntensityChin;
    _beautification.intensityNose = BeautificationShape.defaultIntensityNose;
    _beautification.intensityMouth = BeautificationShape.defaultIntensityMouth;
    await save(_beautification);
    return _beautification;
  }
}
