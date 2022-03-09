import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:flutter/material.dart';
import 'package:home_indicator/home_indicator.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/utils/agora_rtc_helper.dart';
import 'package:live812/utils/agora_rtc_rawdata_wrapper.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:provider/provider.dart';

class DebugPreviewPage extends StatefulWidget {
  const DebugPreviewPage();

  @override
  _DebugPreviewPageState createState() => _DebugPreviewPageState();
}

class _DebugPreviewPageState extends State<DebugPreviewPage> {
  RtcEngine _engine;

  bool _isDisplay = true;

  bool _faceBeautification = false;
  String _selectedFilter;
  final _filterList = [
    'origin',
    'bailiang1',
    'bailiang2',
    'bailiang3',
    'bailiang4',
    'bailiang5',
    'bailiang6',
    'bailiang7',
    'fennen1',
    'fennen2',
    'fennen3',
    'fennen4',
    'fennen5',
    'fennen6',
    'fennen7',
    'fennen8',
    'gexing1',
    'gexing2',
    'gexing3',
    'gexing4',
    'gexing5',
    'gexing6',
    'gexing7',
    'gexing8',
    'gexing9',
    'gexing10',
    'heibai1',
    'heibai2',
    'heibai3',
    'heibai4',
    'heibai5',
    'lengsediao1',
    'lengsediao2',
    'lengsediao3',
    'lengsediao4',
    'lengsediao5',
    'lengsediao6',
    'lengsediao7',
    'lengsediao8',
    'lengsediao9',
    'lengsediao10',
    'lengsediao11',
    'nuansediao1',
    'nuansediao2',
    'nuansediao3',
    'xiaoqingxin1',
    'xiaoqingxin2',
    'xiaoqingxin3',
    'xiaoqingxin4',
    'xiaoqingxin5',
    'xiaoqingxin6',
  ];
  double _filterLevel = 100;
  double _colorLevel = 50;
  double _redLevel = 50;
  double _bluerLevel = 600;
  bool _skinDetect = false;
  double _nonskinBlurScale = 50;
  bool _heavyBlur = false;
  double _blurBlendRatio = 0;
  double _eyeBright = 0;
  double _toothWhiten = 0;
  final _faceShapeList = [
    'Goddess',
    'cyber celebrity',
    'nature',
    'default',
    'custom',
  ];
  String _selectedFaceShapeString;
  int _faceShape = 0;
  double _faceShapeLevel = 0;
  double _eyeEnlarging = 50;
  double _cheekThinning = 0;
  double _intensityForehead = 50;
  double _intensityChin = 50;
  double _intensityNose = 0;
  double _intensityMouth = 0;

  @override
  void initState() {
    super.initState();
    HomeIndicator.hide();
    initAgora();
    _selectedFilter = _filterList.first;
    _selectedFaceShapeString = _faceShapeList.first;
  }

  @override
  void dispose() async {
    super.dispose();

    await AgoraRtcRawDataWrapper.unregisterAudioFrameObserver();
    await AgoraRtcRawDataWrapper.unregisterVideoFrameObserver();
    await _engine?.stopPreview();
    await _engine?.destroy();

    HomeIndicator.show();
  }

  /// Agoraの初期化.
  Future initAgora() async {
    _engine = await RtcEngine.create(Consts.AGORA_APP_ID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);
    await _engine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    final userModel = Provider.of<UserModel>(context, listen: false);
    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.dimensions =
        AgoraRtcHelper.dimensions(userModel.liveWidth, userModel.liveHeight);
    config.orientationMode = AgoraRtcHelper.orientationMode(true);
    config.frameRate = AgoraRtcHelper.frameRate(userModel.liveFrameRate);
    config.bitrate = userModel.liveBitrate;
    _engine.setVideoEncoderConfiguration(config);
    await AgoraRtcRawDataWrapper.registerAudioFrameObserver(
        await _engine.getNativeHandle());
    await AgoraRtcRawDataWrapper.registerVideoFrameObserver(
        await _engine.getNativeHandle());
    await _engine.startPreview();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              child: RtcLocalView.SurfaceView(),
            ),
            if (_isDisplay)
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          const Text('Face Beautification ON/OFF'),
                          Switch(
                            value: _faceBeautification,
                            onChanged: (value) {
                              _faceBeautification = value;
                              setState(() {
                                if (_faceBeautification) {
                                  AgoraRtcRawDataWrapper
                                      .enableFaceBeautification();
                                } else {
                                  AgoraRtcRawDataWrapper
                                      .disableFaceBeautification();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Text('Filter'),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: _selectedFilter,
                            onChanged: (String newValue) {
                              setState(() {
                                _selectedFilter = newValue;
                                _setFaceBeautificationFilter();
                              });
                            },
                            items: _filterList.map((String item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Filter Level'),
                          Slider(
                            value: _filterLevel,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Filter Level',
                            onChanged: (value) {
                              setState(() {
                                _filterLevel = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationFilter();
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Text('Skin Whitening'),
                          Slider(
                            value: _colorLevel,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Skin Whitening',
                            onChanged: (value) {
                              setState(() {
                                _colorLevel = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationSkinWhitening();
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Text('Ruddy'),
                          Slider(
                            value: _redLevel,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Ruddy',
                            onChanged: (value) {
                              setState(() {
                                _redLevel = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationRuddy();
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Text('Blur Level'),
                          Slider(
                            value: _bluerLevel,
                            min: 0,
                            max: 600,
                            divisions: 10,
                            label: 'Blur Level',
                            onChanged: (value) {
                              setState(() {
                                _bluerLevel = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationBlur();
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Skin Detect'),
                          Switch(
                            value: _skinDetect,
                            onChanged: (value) {
                              setState(() {
                                _skinDetect = value;
                                _setFaceBeautificationBlur();
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Nonskin Blur Scale'),
                          Slider(
                            value: _nonskinBlurScale,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Nonskin Blur Level',
                            onChanged: (value) {
                              setState(() {
                                _nonskinBlurScale = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationBlur();
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Heavy Blur'),
                          Switch(
                            value: _heavyBlur,
                            onChanged: (value) {
                              setState(() {
                                _heavyBlur = value;
                                _setFaceBeautificationBlur();
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Blur Blend Ratio'),
                          Slider(
                            value: _blurBlendRatio,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Blur Blend Ratio',
                            onChanged: (value) {
                              setState(() {
                                _blurBlendRatio = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationBlur();
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Text('Eye Bright'),
                          Slider(
                            value: _eyeBright,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Eye Bright',
                            onChanged: (value) {
                              setState(() {
                                _eyeBright = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationEyeBrighten();
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Text('Tooth Whiten'),
                          Slider(
                            value: _toothWhiten,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Tooth Whiten',
                            onChanged: (value) {
                              setState(() {
                                _toothWhiten = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationToothWhiten();
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Text('Face Shape'),
                          const SizedBox(width: 10),
                          DropdownButton<String>(
                            value: _selectedFaceShapeString,
                            onChanged: (String newValue) {
                              setState(() {
                                _selectedFaceShapeString = newValue;
                                _faceShape = _faceShapeList
                                    .indexOf(_selectedFaceShapeString);
                                _setFaceBeautificationFaceOutline();
                              });
                            },
                            items: _faceShapeList.map((String item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Face Shape Level'),
                          Slider(
                            value: _faceShapeLevel,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Face Shape Level',
                            onChanged: (value) {
                              setState(() {
                                _faceShapeLevel = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationFaceOutline();
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Eye Enlarging'),
                          Slider(
                            value: _eyeEnlarging,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Eye Enlarging',
                            onChanged: (value) {
                              setState(() {
                                _eyeEnlarging = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationFaceOutline();
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Cheek Thinning'),
                          Slider(
                            value: _cheekThinning,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Cheek Thinning',
                            onChanged: (value) {
                              setState(() {
                                _cheekThinning = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationFaceOutline();
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Intensity Forehead'),
                          Slider(
                            value: _intensityForehead,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Intensity Forehead',
                            onChanged: (value) {
                              setState(() {
                                _intensityForehead = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationFaceOutline();
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Intensity Chin'),
                          Slider(
                            value: _intensityChin,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Intensity Chin',
                            onChanged: (value) {
                              setState(() {
                                _intensityChin = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationFaceOutline();
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Intensity Nose'),
                          Slider(
                            value: _intensityNose,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Intensity Nose',
                            onChanged: (value) {
                              setState(() {
                                _intensityNose = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationFaceOutline();
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Intensity Mouth'),
                          Slider(
                            value: _intensityMouth,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: 'Intensity Mouth',
                            onChanged: (value) {
                              setState(() {
                                _intensityMouth = value;
                              });
                            },
                            onChangeEnd: (value) {
                              _setFaceBeautificationFaceOutline();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ],
              ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: _isDisplay ? const Icon(Icons.close) : const Icon(Icons.face),
        onPressed: () {
          setState(() {
            _isDisplay = !_isDisplay;
          });
        },
      ),
    );
  }

  void _setFaceBeautificationFilter() {
    AgoraRtcRawDataWrapper.setFaceBeautificationFilter(
      filterName: _selectedFilter,
      filterLevel: _filterLevel / 100,
    );
  }

  void _setFaceBeautificationSkinWhitening() {
    AgoraRtcRawDataWrapper.setFaceBeautificationSkinWhitening(
      colorLevel: _colorLevel / 100,
    );
  }

  void _setFaceBeautificationRuddy() {
    AgoraRtcRawDataWrapper.setFaceBeautificationRuddy(
      redLevel: _redLevel / 100,
    );
  }

  void _setFaceBeautificationBlur() {
    AgoraRtcRawDataWrapper.setFaceBeautificationBlur(
      blurLevel: _bluerLevel / 100,
      skinDetect: _skinDetect,
      nonskinBlurScale: _nonskinBlurScale / 100,
      heavyBlur: _heavyBlur,
      blurBlendRatio: _blurBlendRatio / 100,
    );
  }

  void _setFaceBeautificationEyeBrighten() {
    AgoraRtcRawDataWrapper.setFaceBeautificationEyeBrighten(
      eyeBright: _eyeBright / 100,
    );
  }

  void _setFaceBeautificationToothWhiten() {
    AgoraRtcRawDataWrapper.setFaceBeautificationToothWhiten(
      toothWhiten: _toothWhiten / 100,
    );
  }

  void _setFaceBeautificationFaceOutline() {
    AgoraRtcRawDataWrapper.setFaceBeautificationFaceOutline(
      faceShape: _faceShape,
      faceShapeLevel: _faceShapeLevel / 100,
      eyeEnlarging: _eyeEnlarging / 100,
      cheekThinning: _cheekThinning / 100,
      intensityForehead: _intensityForehead / 100,
      intensityChin: _intensityChin / 100,
      intensityNose: _intensityNose / 100,
      intensityMouth: _intensityMouth / 100,
    );
  }
}
