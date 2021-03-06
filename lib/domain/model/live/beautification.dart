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

  /// ?????????????????????????????????
  int selectedFilter;

  /// ??????????????? : Bright.
  int filterBright;

  /// ??????????????? : Pink.
  int filterPink;

  /// ??????????????? : Unique.
  int filterUnique;

  /// ??????????????? : Sepia.
  int filterSepia;

  /// ??????????????? : Cool.
  int filterCool;

  /// ??????????????? : Warm.
  int filterWarm;

  /// ??????????????? : Fresh.
  int filterFresh;

  /// ??????.
  int colorLevel;

  /// ??????.
  int redLevel;

  /// ?????????(??????).
  int blurLevel;

  /// ?????????????????????.
  int toothWhiten;

  /// ????????????(?????????).
  int eyeEnlarging;

  /// ??????????????????????????????(??????).
  int cheekThinning;

  /// ????????????.
  int intensityForehead;

  /// ???????????????.
  int intensityChin;

  /// ????????????.
  int intensityNose;

  /// ????????????.
  int intensityMouth;

  /// ???????????????????????????.
  BeautificationFilterType filterType() {
    return BeautificationFilterType.values[selectedFilter];
  }

  /// ????????????????????????.
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

/// ???????????????.
enum BeautificationType {
  filter,
  skin,
  shape,
}

/// ??????????????????????????????.
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

/// ???????????????.
enum BeautificationSkinType {
  skinWhitening,
  ruddy,
  blur,
  toothWhiten,
}

/// ???????????????????????????????????????.
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

/// ???????????????????????????.
class BeautificationSkin {
  const BeautificationSkin._();

  /// ??????.
  static int defaultColorLevel = 0;
  static int minColorLevel = 0;
  static int maxColorLevel = 100;

  /// ??????.
  static int defaultRedLevel = 0;
  static int minRedLevel = 0;
  static int maxRedLevel = 100;

  /// ?????????(??????).
  static int defaultBlurLevel = 0;
  static int minBlurLevel = 0;
  static int maxBlurLevel = 100;

  /// ?????????????????????.
  static int defaultToothWhiten = 0;
  static int minToothWhiten = 0;
  static int maxToothWhiten = 100;
}

/// ???????????????.
enum BeautificationShapeType {
  eyeEnlarging,
  cheekThinning,
  intensityForehead,
  intensityChin,
  intensityNose,
  intensityMouth,
}

/// ???????????????????????????.
class BeautificationShape {
  const BeautificationShape._();

  /// ????????????(?????????).
  static int defaultEyeEnlarging = 0;
  static int minEyeEnlarging = 0;
  static int maxEyeEnlarging = 100;

  /// ??????????????????????????????(??????).
  static int defaultCheekThinning = 0;
  static int minCheekThinning = 0;
  static int maxCheekThinning = 100;

  /// ????????????.
  static int defaultIntensityForehead = 0;
  static int minIntensityForehead = -50;
  static int maxIntensityForehead = 50;

  /// ???????????????.
  static int defaultIntensityChin = 0;
  static int minIntensityChin = -50;
  static int maxIntensityChin = 50;

  /// ????????????.
  static int defaultIntensityNose = 0;
  static int minIntensityNose = -50;
  static int maxIntensityNose = 50;

  /// ????????????.
  static int defaultIntensityMouth = 0;
  static int minIntensityMouth = -50;
  static int maxIntensityMouth = 50;
}
