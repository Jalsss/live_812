class Beautification {
  Beautification({
    this.selectedFilter,
    this.filterBright,
    this.filterPink,
    this.filterUnique,
    this.filterSepia,
    this.filterCool,
    this.filterWarm,
    this.filterFresh,
    this.colorLevel,
    this.redLevel,
    this.blurLevel,
    this.toothWhiten,
    this.eyeEnlarging,
    this.cheekThinning,
    this.intensityForehead,
    this.intensityChin,
    this.intensityNose,
    this.intensityMouth,
  });

  factory Beautification.fromJson(Map<String, dynamic> json) => Beautification(
        selectedFilter:
            json['selected_filter'] ?? BeautificationFilterType.off.index,
        filterBright:
            json['filter_bright'] ?? BeautificationFilter.defaultBright,
        filterPink: json['filter_pink'] ?? BeautificationFilter.defaultPink,
        filterUnique:
            json['filter_unique'] ?? BeautificationFilter.defaultUnique,
        filterSepia: json['filter_sepia'] ?? BeautificationFilter.defaultSepia,
        filterCool: json['filter_cool'] ?? BeautificationFilter.defaultCool,
        filterWarm: json['filter_warm'] ?? BeautificationFilter.defaultWarm,
        filterFresh: json['filter_fresh'] ?? BeautificationFilter.defaultFresh,
        colorLevel: json['color_level'] ?? BeautificationSkin.defaultColorLevel,
        redLevel: json['red_level'] ?? BeautificationSkin.defaultRedLevel,
        blurLevel: json['blur_level'] ?? BeautificationSkin.defaultBlurLevel,
        toothWhiten:
            json['tooth_whiten'] ?? BeautificationSkin.defaultToothWhiten,
        eyeEnlarging:
            json['eye_enlarging'] ?? BeautificationShape.defaultEyeEnlarging,
        cheekThinning:
            json['cheek_thinning'] ?? BeautificationShape.defaultCheekThinning,
        intensityForehead: json['intensity_forehead'] ??
            BeautificationShape.defaultIntensityForehead,
        intensityChin:
            json['intensity_chin'] ?? BeautificationShape.defaultIntensityChin,
        intensityNose:
            json['intensity_nose'] ?? BeautificationShape.defaultIntensityNose,
        intensityMouth: json['intensity_mouth'] ??
            BeautificationShape.defaultIntensityMouth,
      );

  Map<String, dynamic> toMap() => {
        'selected_filter': selectedFilter,
        'filter_bright': filterBright,
        'filter_pink': filterPink,
        'filter_unique': filterUnique,
        'filter_sepia': filterSepia,
        'filter_cool': filterCool,
        'filter_warm': filterWarm,
        'filter_fresh': filterFresh,
        'color_level': colorLevel,
        'red_level': redLevel,
        'blur_level': blurLevel,
        'tooth_whiten': toothWhiten,
        'eye_enlarging': eyeEnlarging,
        'cheek_thinning': cheekThinning,
        'intensity_forehead': intensityForehead,
        'intensity_chin': intensityChin,
        'intensity_nose': intensityNose,
        'intensity_mouth': intensityMouth,
      };

  /// 選択しているフィルター
  int selectedFilter;

  /// フィルター : Bright.
  int filterBright;

  /// フィルター : Pink.
  int filterPink;

  /// フィルター : Unique.
  int filterUnique;

  /// フィルター : Sepia.
  int filterSepia;

  /// フィルター : Cool.
  int filterCool;

  /// フィルター : Warm.
  int filterWarm;

  /// フィルター : Fresh.
  int filterFresh;

  /// 美白.
  int colorLevel;

  /// 血色.
  int redLevel;

  /// ぼかし(美肌).
  int blurLevel;

  /// ホワイトニング.
  int toothWhiten;

  /// 目の拡大(デカ目).
  int eyeEnlarging;

  /// フェイスリフティング(小顔).
  int cheekThinning;

  /// 額の調整.
  int intensityForehead;

  /// あごの調整.
  int intensityChin;

  /// 鼻の調整.
  int intensityNose;

  /// 口の調整.
  int intensityMouth;

  /// フィルターのタイプ.
  BeautificationFilterType filterType() {
    return BeautificationFilterType.values[selectedFilter];
  }

  /// フィルターレベル.
  int filterLevel() {
    switch (filterType()) {
      case BeautificationFilterType.off:
        return 0;
      case BeautificationFilterType.bright:
        return filterBright;
      case BeautificationFilterType.pink:
        return filterPink;
      case BeautificationFilterType.unique:
        return filterUnique;
      case BeautificationFilterType.sepia:
        return filterSepia;
      case BeautificationFilterType.cool:
        return filterCool;
      case BeautificationFilterType.warm:
        return filterWarm;
      case BeautificationFilterType.fresh:
        return filterFresh;
    }
    return 0;
  }
}

/// 美顔タイプ.
enum BeautificationType {
  filter,
  skin,
  shape,
}

/// 美顔フィルタータイプ.
enum BeautificationFilterType {
  off,
  bright,
  pink,
  unique,
  sepia,
  cool,
  warm,
  fresh,
  max,
}

/// 美肌タイプ.
enum BeautificationSkinType {
  skinWhitening,
  ruddy,
  blur,
  toothWhiten,
}

/// 美顔フィルターのパラメータ.
class BeautificationFilter {
  const BeautificationFilter._();

  static int minValue = 0;
  static int maxValue = 100;

  static List<String> _names = [
    'origin',
    'bailiang1',
    'fennen1',
    'gexing1',
    'heibai3',
    'lengsediao1',
    'nuansediao2',
    'xiaoqingxin1',
  ];

  static String name(BeautificationFilterType type) => _names[type.index];

  /// Bright.
  static int defaultBright = 100;

  /// Pink.
  static int defaultPink = 100;

  /// Unique.
  static int defaultUnique = 100;

  /// Sepia.
  static int defaultSepia = 100;

  /// Cool.
  static int defaultCool = 100;

  /// Warm.
  static int defaultWarm = 100;

  /// Fresh.
  static int defaultFresh = 100;
}

/// 美肌用のパラメータ.
class BeautificationSkin {
  const BeautificationSkin._();

  /// 美白.
  static int defaultColorLevel = 0;
  static int minColorLevel = 0;
  static int maxColorLevel = 100;

  /// 血色.
  static int defaultRedLevel = 0;
  static int minRedLevel = 0;
  static int maxRedLevel = 100;

  /// ぼかし(美肌).
  static int defaultBlurLevel = 0;
  static int minBlurLevel = 0;
  static int maxBlurLevel = 100;

  /// ホワイトニング.
  static int defaultToothWhiten = 0;
  static int minToothWhiten = 0;
  static int maxToothWhiten = 100;
}

/// 美形タイプ.
enum BeautificationShapeType {
  eyeEnlarging,
  cheekThinning,
  intensityForehead,
  intensityChin,
  intensityNose,
  intensityMouth,
}

/// 美形用のパラメータ.
class BeautificationShape {
  const BeautificationShape._();

  /// 目の拡大(デカ目).
  static int defaultEyeEnlarging = 0;
  static int minEyeEnlarging = 0;
  static int maxEyeEnlarging = 100;

  /// フェイスリフティング(小顔).
  static int defaultCheekThinning = 0;
  static int minCheekThinning = 0;
  static int maxCheekThinning = 100;

  /// 額の調整.
  static int defaultIntensityForehead = 0;
  static int minIntensityForehead = -50;
  static int maxIntensityForehead = 50;

  /// あごの調整.
  static int defaultIntensityChin = 0;
  static int minIntensityChin = -50;
  static int maxIntensityChin = 50;

  /// 鼻の調整.
  static int defaultIntensityNose = 0;
  static int minIntensityNose = -50;
  static int maxIntensityNose = 50;

  /// 口の調整.
  static int defaultIntensityMouth = 0;
  static int minIntensityMouth = -50;
  static int maxIntensityMouth = 50;
}
