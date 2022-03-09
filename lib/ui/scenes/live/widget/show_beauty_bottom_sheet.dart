import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/live/beautification.dart';
import 'package:live812/domain/usecase/beautification_usecase.dart';
import 'package:live812/utils/agora_rtc_faceunity.dart';
import 'package:live812/utils/consts/ColorLive.dart';

/// 美顔用のダイアログ.
Future<T> showBeautyBottomSheet<T>({
  BuildContext context,
}) {
  final tabs = [
    'フィルター',
    '美肌',
    '美形',
  ];
  var selectedIndex = 0;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white.withAlpha(0),
    barrierColor: Colors.white.withAlpha(0),
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SafeArea(
            child: DefaultTabController(
              initialIndex: selectedIndex,
              length: tabs.length,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 182,
                    color: Colors.white.withAlpha(0),
                    child: TabBarView(
                      children: [
                        _BeautificationFilterView(),
                        _BeautificationSkinView(),
                        _BeautificationShapeView(),
                      ],
                    ),
                  ),
                  Container(
                    color: ColorLive.MAIN_BG,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: tabs
                              .map((e) => Tab(
                                    text: e,
                                  ))
                              .toList(),
                          onTap: (value) {
                            setState(() {
                              selectedIndex = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _BeautificationFilterView extends StatefulWidget {
  const _BeautificationFilterView();

  @override
  _BeautificationFilterViewState createState() =>
      _BeautificationFilterViewState();
}

class _BeautificationFilterViewState extends State<_BeautificationFilterView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<String> _names = [
    'OFF',
    'Bright',
    'Pink',
    'Unique',
    'Sepia',
    'Cool',
    'Warm',
    'Fresh',
  ];

  /// 現在設定している項目.
  var _filterType = BeautificationFilterType.off;

  /// 設定値.
  double _value = 100.0;

  @override
  void initState() {
    super.initState();
    Future(() async {
      final beautification = await BeautificationUseCase.load();
      _filterType =
          BeautificationFilterType.values[beautification.selectedFilter];
      await _setFilterType(_filterType);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      height: 134,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _filterType == BeautificationFilterType.off
              ? const SizedBox(height: 48)
              : Container(
                  constraints: BoxConstraints(
                    maxWidth: 265,
                  ),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      activeTrackColor: ColorLive.BLUE,
                      valueIndicatorColor: ColorLive.BLUE,
                      thumbColor: ColorLive.BLUE,
                      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                      showValueIndicator: ShowValueIndicator.always,
                      inactiveTrackColor: Colors.white,
                    ),
                    child: Slider(
                      min: BeautificationFilter.minValue.toDouble(),
                      max: BeautificationFilter.maxValue.toDouble(),
                      divisions: 100,
                      value: _value,
                      label: '${_value.toInt()}',
                      onChanged: (value) async {
                        await _setValue(value);
                        _value = value;
                        setState(() {});
                      },
                      onChangeEnd: (value) async {
                        await _saveValue(value);
                      },
                    ),
                  ),
                ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: ColorLive.MAIN_BG,
              child: Center(
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _names.length,
                  itemBuilder: (context, index) {
                    return _BeautificationFilterItem(
                      title: _names[index],
                      selected: index == _filterType.index,
                      onTap: () async {
                        await _setFilterType(
                            BeautificationFilterType.values[index]);
                        await _setValue(_value);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 項目を設定.
  Future<void> _setFilterType(BeautificationFilterType filterType) async {
    final beautification = await BeautificationUseCase.load();
    _filterType = filterType;
    switch (filterType) {
      case BeautificationFilterType.off:
        _value = 0.0;
        break;
      case BeautificationFilterType.bright:
        _value = beautification.filterBright.toDouble();
        break;
      case BeautificationFilterType.pink:
        _value = beautification.filterPink.toDouble();
        break;
      case BeautificationFilterType.unique:
        _value = beautification.filterUnique.toDouble();
        break;
      case BeautificationFilterType.sepia:
        _value = beautification.filterSepia.toDouble();
        break;
      case BeautificationFilterType.cool:
        _value = beautification.filterCool.toDouble();
        break;
      case BeautificationFilterType.warm:
        _value = beautification.filterWarm.toDouble();
        break;
      case BeautificationFilterType.fresh:
        _value = beautification.filterFresh.toDouble();
        break;
      case BeautificationFilterType.max:
        break;
    }
    await _saveValue(_value);
    if (mounted) {
      setState(() {});
    }
  }

  /// 設定値を反映.
  Future _setValue(double value) async {
    try {
      await AgoraRtcFaceUnity.setFaceBeautificationFilter(
        filterName: BeautificationFilter.name(_filterType),
        filterLevel: value,
      );
    } catch (e) {
      print('Set Beautification Filter Error.');
    }
  }

  /// 設定値を保存.
  Future _saveValue(double value) async {
    await BeautificationUseCase.setFilter(_filterType, value.toInt());
  }
}

/// 美顔フィルターアイテム.
class _BeautificationFilterItem extends StatelessWidget {
  const _BeautificationFilterItem({
    this.title,
    this.selected,
    this.onTap,
  });

  final String title;
  final bool selected;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 70,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/beauty_filter/$title.jpg'),
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  border: selected
                      ? Border.all(
                          color: ColorLive.BLUE,
                          width: 2,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$title',
                style: TextStyle(
                  color: selected ? ColorLive.BLUE : Colors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 美肌.
class _BeautificationSkinView extends StatefulWidget {
  const _BeautificationSkinView();

  @override
  _BeautificationSkinViewState createState() => _BeautificationSkinViewState();
}

class _BeautificationSkinViewState extends State<_BeautificationSkinView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<String> _fileNames = [
    'icon_bihaku',
    'icon_kenkou',
    'icon_bihada',
    'icon_white',
  ];
  final List<String> _names = [
    '美白',
    '血色',
    '美肌',
    'ホワイトニング',
  ];

  /// 現在設定している項目.
  var _skinType = BeautificationSkinType.skinWhitening;

  /// 設定値.
  double _value = 0;
  double _minValue = 0;
  double _maxValue = 0;

  @override
  void initState() {
    super.initState();
    _setSkinType(_skinType);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: 265,
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: ColorLive.BLUE,
                valueIndicatorColor: ColorLive.BLUE,
                thumbColor: ColorLive.BLUE,
                valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                showValueIndicator: ShowValueIndicator.always,
                inactiveTrackColor: Colors.white,
              ),
              child: Slider(
                min: _minValue,
                max: _maxValue,
                divisions: 100,
                value: _value,
                label: '${_value.toInt()}',
                onChanged: (value) async {
                  await _setValue(value);
                  setState(() {
                    _value = value;
                  });
                },
                onChangeEnd: (value) async {
                  await _saveValue(value);
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: ColorLive.MAIN_BG,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        child: TextButton.icon(
                          onPressed: _resetValue,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'リセット',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: _names.length,
                        itemBuilder: (context, index) {
                          return _BeautificationSkinItem(
                            fileName:
                                'assets/svg/beauty/${_fileNames[index]}.svg',
                            title: _names[index],
                            selected: index == _skinType.index,
                            onTap: () async {
                              await _setSkinType(
                                  BeautificationSkinType.values[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 項目の設定.
  Future<void> _setSkinType(BeautificationSkinType skinType) async {
    final beautification = await BeautificationUseCase.load();
    _skinType = skinType;
    switch (skinType) {
      case BeautificationSkinType.skinWhitening:
        _minValue = BeautificationSkin.minColorLevel.toDouble();
        _maxValue = BeautificationSkin.maxColorLevel.toDouble();
        _value = beautification.colorLevel.toDouble();
        break;
      case BeautificationSkinType.ruddy:
        _minValue = BeautificationSkin.minRedLevel.toDouble();
        _maxValue = BeautificationSkin.maxRedLevel.toDouble();
        _value = beautification.redLevel.toDouble();
        break;
      case BeautificationSkinType.blur:
        _minValue = BeautificationSkin.minBlurLevel.toDouble();
        _maxValue = BeautificationSkin.maxBlurLevel.toDouble();
        _value = beautification.blurLevel.toDouble();
        break;
      case BeautificationSkinType.toothWhiten:
        _minValue = BeautificationSkin.minToothWhiten.toDouble();
        _maxValue = BeautificationSkin.maxToothWhiten.toDouble();
        _value = beautification.toothWhiten.toDouble();
        break;
    }
    if (mounted) {
      setState(() {});
    }
  }

  /// 設定値を反映.
  Future _setValue(double value) async {
    try {
      switch (_skinType) {
        case BeautificationSkinType.skinWhitening:
          await AgoraRtcFaceUnity.setFaceBeautificationSkinWhitening(
            colorLevel: value,
          );
          break;
        case BeautificationSkinType.ruddy:
          await AgoraRtcFaceUnity.setFaceBeautificationRuddy(
            redLevel: value,
          );
          break;
        case BeautificationSkinType.blur:
          await AgoraRtcFaceUnity.setFaceBeautificationBlur(
            blurLevel: value,
          );
          break;
        case BeautificationSkinType.toothWhiten:
          await AgoraRtcFaceUnity.setFaceBeautificationToothWhiten(
            toothWhiten: value,
          );
          break;
      }
    } catch (e) {
      print('Set Beautification Skin Error.');
    }
  }

  /// 設定値を保存.
  Future _saveValue(double value) async {
    switch (_skinType) {
      case BeautificationSkinType.skinWhitening:
        await BeautificationUseCase.setColorLevel(value.toInt());
        break;
      case BeautificationSkinType.ruddy:
        await BeautificationUseCase.setRedLevel(value.toInt());
        break;
      case BeautificationSkinType.blur:
        await BeautificationUseCase.setBlurLevel(value.toInt());
        break;
      case BeautificationSkinType.toothWhiten:
        await BeautificationUseCase.setToothWhiten(value.toInt());
        break;
    }
  }

  /// リセット.
  Future _resetValue() async {
    final beautification = await BeautificationUseCase.resetSkin();
    try {
      switch (_skinType) {
        case BeautificationSkinType.skinWhitening:
          _value = beautification.colorLevel.toDouble();
          break;
        case BeautificationSkinType.ruddy:
          _value = beautification.redLevel.toDouble();
          break;
        case BeautificationSkinType.blur:
          _value = beautification.blurLevel.toDouble();
          break;
        case BeautificationSkinType.toothWhiten:
          _value = beautification.toothWhiten.toDouble();
          break;
      }
      setState(() {});
      await AgoraRtcFaceUnity.setFaceBeautificationSkinWhitening(
        colorLevel: beautification.colorLevel.toDouble(),
      );
      await AgoraRtcFaceUnity.setFaceBeautificationRuddy(
        redLevel: beautification.redLevel.toDouble(),
      );
      await AgoraRtcFaceUnity.setFaceBeautificationBlur(
        blurLevel: beautification.blurLevel.toDouble(),
      );
      await AgoraRtcFaceUnity.setFaceBeautificationToothWhiten(
        toothWhiten: beautification.toothWhiten.toDouble(),
      );
    } catch (e) {
      print('Reset Beautification Skin Error.');
    }
  }
}

/// 美肌アイテム.
class _BeautificationSkinItem extends StatelessWidget {
  const _BeautificationSkinItem({
    this.fileName,
    this.title,
    this.selected,
    this.onTap,
  });

  final String fileName;
  final String title;
  final bool selected;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: 73,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              child: SvgPicture.asset(
                fileName,
                height: 38,
                fit: BoxFit.scaleDown,
                color: selected ? ColorLive.BLUE : Colors.white,
              ),
            ),
            Text(
              '$title',
              style: TextStyle(
                color: selected ? ColorLive.BLUE : Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}

/// 美形.
class _BeautificationShapeView extends StatefulWidget {
  const _BeautificationShapeView();

  @override
  _BeautificationShapeViewState createState() =>
      _BeautificationShapeViewState();
}

class _BeautificationShapeViewState extends State<_BeautificationShapeView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<String> _fileNames = [
    'icon_eye',
    'icon_kogao',
    'icon_odeko',
    'icon_ago',
    'icon_hana',
    'icon_kuchi',
  ];

  final List<String> _names = [
    'デカ目',
    '小顔',
    'おでこ',
    'あご',
    '鼻',
    '口',
  ];

  /// 現在設定している項目.
  var _shapeType = BeautificationShapeType.eyeEnlarging;

  /// 設定値.
  double _value = 0;
  double _minValue = 0;
  double _maxValue = 0;

  @override
  void initState() {
    super.initState();
    _setShapeType(_shapeType);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: 265,
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: ColorLive.BLUE,
                valueIndicatorColor: ColorLive.BLUE,
                thumbColor: ColorLive.BLUE,
                valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                showValueIndicator: ShowValueIndicator.always,
                inactiveTrackColor: Colors.white,
              ),
              child: Slider(
                min: _minValue,
                max: _maxValue,
                divisions: 100,
                value: _value,
                label: '${_value.toInt()}',
                onChanged: (value) async {
                  await _setValue(value);
                  setState(() {
                    _value = value;
                  });
                },
                onChangeEnd: (value) async {
                  await _saveValue(value);
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: ColorLive.MAIN_BG,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        child: TextButton.icon(
                          onPressed: _resetValue,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'リセット',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: _names.length,
                        itemBuilder: (context, index) {
                          return _BeautificationShapeItem(
                            fileName:
                                'assets/svg/beauty/${_fileNames[index]}.svg',
                            title: _names[index],
                            selected: index == _shapeType.index,
                            onTap: () async {
                              await _setShapeType(
                                  BeautificationShapeType.values[index]);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 項目の設定.
  Future<void> _setShapeType(BeautificationShapeType shapeType) async {
    final beautification = await BeautificationUseCase.load();
    _shapeType = shapeType;
    switch (shapeType) {
      case BeautificationShapeType.eyeEnlarging:
        _minValue = BeautificationShape.minEyeEnlarging.toDouble();
        _maxValue = BeautificationShape.maxEyeEnlarging.toDouble();
        _value = beautification.eyeEnlarging.toDouble();
        break;
      case BeautificationShapeType.cheekThinning:
        _minValue = BeautificationShape.minCheekThinning.toDouble();
        _maxValue = BeautificationShape.maxCheekThinning.toDouble();
        _value = beautification.cheekThinning.toDouble();
        break;
      case BeautificationShapeType.intensityForehead:
        _minValue = BeautificationShape.minIntensityForehead.toDouble();
        _maxValue = BeautificationShape.maxIntensityForehead.toDouble();
        _value = beautification.intensityForehead.toDouble();
        break;
      case BeautificationShapeType.intensityChin:
        _minValue = BeautificationShape.minIntensityChin.toDouble();
        _maxValue = BeautificationShape.maxIntensityChin.toDouble();
        _value = beautification.intensityChin.toDouble();
        break;
      case BeautificationShapeType.intensityNose:
        _minValue = BeautificationShape.minIntensityNose.toDouble();
        _maxValue = BeautificationShape.maxIntensityNose.toDouble();
        _value = beautification.intensityNose.toDouble();
        break;
      case BeautificationShapeType.intensityMouth:
        _minValue = BeautificationShape.minIntensityMouth.toDouble();
        _maxValue = BeautificationShape.maxIntensityMouth.toDouble();
        _value = beautification.intensityMouth.toDouble();
        break;
    }
    if (mounted) {
      setState(() {});
    }
  }

  /// 設定値を反映.
  Future _setValue(double value) async {
    final beautification = await BeautificationUseCase.load();
    switch (_shapeType) {
      case BeautificationShapeType.eyeEnlarging:
        beautification.eyeEnlarging = value.toInt();
        break;
      case BeautificationShapeType.cheekThinning:
        beautification.cheekThinning = value.toInt();
        break;
      case BeautificationShapeType.intensityForehead:
        beautification.intensityForehead = value.toInt();
        break;
      case BeautificationShapeType.intensityChin:
        beautification.intensityChin = value.toInt();
        break;
      case BeautificationShapeType.intensityNose:
        beautification.intensityNose = value.toInt();
        break;
      case BeautificationShapeType.intensityMouth:
        beautification.intensityMouth = value.toInt();
        break;
    }
    try {
      await AgoraRtcFaceUnity.setFaceBeautificationFaceOutline(
        eyeEnlarging: beautification.eyeEnlarging.toDouble(),
        cheekThinning: beautification.cheekThinning.toDouble(),
        intensityForehead: beautification.intensityForehead.toDouble(),
        intensityChin: beautification.intensityChin.toDouble(),
        intensityNose: beautification.intensityNose.toDouble(),
        intensityMouth: beautification.intensityMouth.toDouble(),
      );
    } catch (e) {
      print('Set Beautification Shape Error.');
    }
  }

  // 設定値を保存.
  Future _saveValue(double value) async {
    switch (_shapeType) {
      case BeautificationShapeType.eyeEnlarging:
        await BeautificationUseCase.setEyeEnlarging(value.toInt());
        break;
      case BeautificationShapeType.cheekThinning:
        await BeautificationUseCase.setCheekThinning(value.toInt());
        break;
      case BeautificationShapeType.intensityForehead:
        await BeautificationUseCase.setIntensityForehead(value.toInt());
        break;
      case BeautificationShapeType.intensityChin:
        await BeautificationUseCase.setIntensityChin(value.toInt());
        break;
      case BeautificationShapeType.intensityNose:
        await BeautificationUseCase.setIntensityNose(value.toInt());
        break;
      case BeautificationShapeType.intensityMouth:
        await BeautificationUseCase.setIntensityMouth(value.toInt());
        break;
    }
  }

  /// 設定を全てリセット.
  Future _resetValue() async {
    final beautification = await BeautificationUseCase.resetShape();
    switch (_shapeType) {
      case BeautificationShapeType.eyeEnlarging:
        _value = beautification.eyeEnlarging.toDouble();
        break;
      case BeautificationShapeType.cheekThinning:
        _value = beautification.cheekThinning.toDouble();
        break;
      case BeautificationShapeType.intensityForehead:
        _value = beautification.intensityForehead.toDouble();
        break;
      case BeautificationShapeType.intensityChin:
        _value = beautification.intensityChin.toDouble();
        break;
      case BeautificationShapeType.intensityNose:
        _value = beautification.intensityNose.toDouble();
        break;
      case BeautificationShapeType.intensityMouth:
        _value = beautification.intensityMouth.toDouble();
        break;
    }
    setState(() {});
    try {
      await AgoraRtcFaceUnity.setFaceBeautificationFaceOutline(
        eyeEnlarging: beautification.eyeEnlarging.toDouble(),
        cheekThinning: beautification.cheekThinning.toDouble(),
        intensityForehead: beautification.intensityForehead.toDouble(),
        intensityChin: beautification.intensityChin.toDouble(),
        intensityNose: beautification.intensityNose.toDouble(),
        intensityMouth: beautification.intensityMouth.toDouble(),
      );
    } catch (e) {
      print('Reset Beautification Shape Error.');
    }
  }
}

/// 美形アイテム.
class _BeautificationShapeItem extends StatelessWidget {
  const _BeautificationShapeItem({
    this.fileName,
    this.title,
    this.selected,
    this.onTap,
  });

  final String fileName;
  final String title;
  final bool selected;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: 73,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              child: SvgPicture.asset(
                fileName,
                height: 38,
                fit: BoxFit.scaleDown,
                color: selected ? ColorLive.BLUE : Colors.white,
              ),
            ),
            Text(
              '$title',
              style: TextStyle(
                color: selected ? ColorLive.BLUE : Colors.white,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}
