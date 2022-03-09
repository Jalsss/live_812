import 'package:flutter/material.dart';
import 'package:live812/domain/usecase/gift_usecase.dart';
import 'package:live812/utils/anim/cat.dart';
import 'package:live812/utils/anim/cherry.dart';
import 'package:live812/utils/anim/flag.dart';
import 'package:live812/utils/anim/greeting.dart';
import 'package:live812/utils/anim/hand.dart';
import 'package:live812/utils/anim/hello.dart';
import 'package:live812/utils/anim/sequence_animation.dart';
import 'package:live812/utils/anim/sequence_animation_multi.dart';
import 'package:live812/utils/anim/spotlight_animation.dart';
import 'package:live812/utils/anim/star.dart';
import 'package:live812/utils/anim/sushi.dart';
import 'package:live812/utils/anim/sweets.dart';
import 'package:live812/utils/anim/fireworks.dart';

class GiftAnimationWidget extends StatefulWidget {
  final List<int> animationQueue;

  GiftAnimationWidget({@required this.animationQueue});

  @override
  _GiftAnimationWidgetState createState() => _GiftAnimationWidgetState();
}

class _GiftAnimationWidgetState extends State<GiftAnimationWidget> {
  final _emptyWidget = Container();
  Widget _child;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.animationQueue.isNotEmpty && _child == null) {
      final child = _createAnimation(widget.animationQueue.first);
      _child = Container(
        key: ValueKey(count++),
        child: child,
      );
    }
    return _child ?? _emptyWidget;
  }

  Widget _createAnimation(int animId) {
    switch (animId) {
      case 3001:
      case 1001:
        return _wrapSquare(200, HandAnimation(_popQueue)); // やっほー
      case 3002:
        return _spotlightAnimation('2');
      case 3003:
        return _spotlightAnimation('3');
      case 3004:
        return _spotlightAnimation('4');
      case 3005:
        return _spotlightAnimation('5');
      case 3006:
      case 1002:
        return _wrapSquare(200, GreetingAnimation(_popQueue)); // はじめまして
      case 3007:
      case 1003:
        return _wrapSquare(200, HelloAnimation(_popQueue)); // HELLO!
      case 3008:
      case 1006:
        return _wrapSquare(200, SweetsAnimation(_popQueue)); // 和菓子
      case 3009:
      case 1007:
        return _wrapSquare(200, SushiAnimation(_popQueue)); // お寿司
      case 3010:
        return _sequenceAnimation(74, '9'); // また来るね！
      case 3011:
      case 1008:
        return _wrapSquare(200, FlagAnimation(_popQueue)); // 大漁
      case 3012:
        return _sequenceAnimation(75, '11'); // ナイス！
      case 3013:
        return _sequenceAnimation(74, '12'); // ガンバレ！
      case 3014:
        return _sequenceAnimation(74, '13'); // 待ってたよ！
      case 3015:
      case 1004:
        return _sequenceAnimation(45, '14'); // おめでとう！
      case 3016:
        return _sequenceAnimation(91, '15'); // 大好き❤
      case 3017:
        return _sequenceAnimation(91, '16'); // ありがとう！
      case 3018:
      // return _sequenceAnimation(85, '18');
      case 1005:
        return _wrapSquare(200, CatAnimation(_popQueue)); // 招き猫
      case 3019:
        return _sequenceAnimation(90, '19'); // 音符
      case 3020:
        return _sequenceAnimationUpDown(75, '19');
      case 3021:
        return _sequenceAnimation(75, '20'); // 爆笑！
      case 3022:
      case 1009:
        return _sequenceAnimation(75, '21'); // おめでとう!!
      case 3023:
      case 1010:
        return _sequenceAnimation(75, '22'); // 大入り袋
      case 3024:
        return _sequenceAnimationUpDown(76, '23',
            additionalOffset: -110); // 紙吹雪
      case 3025:
      case 1011:
        return _wrapSquare(200, StarAnimation(_popQueue)); // 流れ星
      case 3026:
      case 1012:
        return _wrapSquare(200, CherryAnimation(_popQueue)); // 花吹雪
      case 3027:
      case 1014:
        return _sequenceAnimation(149, '26'); // おめでとう!!!
      case 3028:
        return _sequenceAnimation(150, '28'); // 七福神
      case 1013:
        return _wrapSquare(200, FireworksAnimation(_popQueue)); // 打ち上げ花火(期間限定)
      case 3029:
        return _sequenceAnimation(191, '29');
      case 1015:
        break;
      case 3030:
        return _sequenceAnimation(180, '30'); // 宝箱
      case 1016:
        break;
      case 3031:
        return _sequenceAnimation(75, '31'); // かわいい
      case 3032:
        return _sequenceAnimation(75, '32'); // かっこいい
      case 3033:
      // return _sequenceAnimation(121, '33');  // やいぞーサンタ
      case 3034:
        return _sequenceAnimation(71, '34'); // うしぞー
      case 3101:
        return _sequenceAnimation(101, '101'); // おつカレー
      case 3102:
        return _sequenceAnimation(116, '102'); // 合いの手やいぞー
      case 3103:
        return _sequenceAnimation(90, '103'); // 神回ですね！
      case 3104:
        return _sequenceAnimation(60, '104'); // Happy Valentine!
      case 3201:
        return _sequenceAnimation(90, '201'); // 拍手★
      case 3202:
        return _sequenceAnimation(75, '202'); // めでタイ
      case 3203:
        return _sequenceAnimation(90, '203'); // 虹
      case 3204:
        return _sequenceAnimation(76, '204'); // さすが！
      case 3205:
        return _sequenceAnimation(87, '205'); // なんでやねん！
      case 3206:
        return _sequenceAnimation(105, '206'); // お祝い
      case 3207:
        return _sequenceAnimation(152, '207'); // エール
      case 3208:
        return _sequenceAnimation(181, '208'); // お祝い
      case 3301:
        return _sequenceAnimation(60, '301'); // 花
      case 3401:
        return _sequenceAnimation(45, '401'); // かんぱい
      case 3402:
        return _sequenceAnimation(30, '402'); // ただいま
      case 3403:
        return _sequenceAnimation(45, '403'); // すごい！
      case 3501:
        return _sequenceAnimation(36, '501'); // きゅん
      case 3502:
        return _sequenceAnimation(37, '502'); // それな！
      case 3503:
        return _sequenceAnimation(34, '503'); // www
      case 3504:
        return _sequenceAnimation(34, '504'); // やばい！
      case 3505:
        return _sequenceAnimation(34, '505'); // まじか！
      case 3506:
        return _sequenceAnimation(38, '506'); // キター
      case 3507:
        return _sequenceAnimation(34, '507'); // わーい
      case 3508:
        return _sequenceAnimation(34, '508'); // フレフレー
      case 3509:
        return _sequenceAnimation(36, '509'); // え？
      case 3510:
        return _sequenceAnimation(37, '510'); // わかる
      case 3511:
        return _sequenceAnimation(105, '511'); // キャンディ
      case 3512:
        return _sequenceAnimation(81, '512'); // スター
      case 3513:
        return _sequenceAnimation(100, '513'); // 風船
      case 3514:
        return _sequenceAnimation(174, '514'); // お城
      case 3515:
        return _sequenceAnimation(105, '515'); // お城
      case 3516:
        return _sequenceAnimation(105, '516'); // スター
      case 3519:
        return _sequenceAnimation(96, '519'); // 風船
      case 3520:
        return _sequenceAnimation(75, '520'); // お城
      case 3521:
        return _sequenceAnimation(60, '521');
      default:
        // 対応するアニメーションがなかった場合でも、キューから取り除く必要がある。
        // 適当にアニメーションを再生する。
        return _wrapSquare(200, HandAnimation(_popQueue));
    }
  }

  Widget _wrapSquare(double size, Widget child) {
    return Center(
      child: Container(
        width: size,
        height: size,
        child: child,
      ),
    );
  }

  void _popQueue() {
    setState(() {
      widget.animationQueue.removeAt(0);
      _child = null;
    });
  }

  Widget _spotlightAnimation(String prefix) {
    var imagePaths = <String>[];
    if (GiftUseCase.isTargetPlatform) {
      imagePaths = ['${GiftUseCase.giftPath}/$prefix/$prefix.png'];
    } else {
      imagePaths = ['assets/anim/new/$prefix/$prefix.png'];
    }
    var table = [
      SpotlightTable(
          x: 0.0, y: -0.95, delay: 0, duration: 3.125, angle: 20, image: 0),
      SpotlightTable(
          x: -0.9,
          y: -0.9,
          delay: 0,
          duration: 3.0,
          angle: 30,
          loop: 1.5,
          image: 0),
      SpotlightTable(
          x: 0.9,
          y: -0.9,
          delay: 0,
          duration: 3.0,
          angle: -30,
          loop: 1.5,
          image: 0),
    ];

    // スポットライト(限定)
    if (prefix == '5') {
      if (GiftUseCase.isTargetPlatform) {
        imagePaths = [
          '${GiftUseCase.giftPath}/5/05_01.png',
          '${GiftUseCase.giftPath}/5/05_02.png',
          '${GiftUseCase.giftPath}/5/05_01.png',
        ];
      } else {
        imagePaths = [
          'assets/anim/new/5/05_01.png',
          'assets/anim/new/5/05_02.png',
          'assets/anim/new/5/05_01.png',
        ];
      }
      table = [
        SpotlightTable(
            x: 0.0, y: -0.95, delay: 0, duration: 3.125, angle: 20, image: 1),
        SpotlightTable(
            x: -0.9,
            y: -0.9,
            delay: 0,
            duration: 3.0,
            angle: 30,
            loop: 1.5,
            image: 0),
        SpotlightTable(
            x: 0.9,
            y: -0.9,
            delay: 0,
            duration: 3.0,
            angle: -30,
            loop: 1.5,
            image: 2),
      ];
    }

    return SpotlightAnimation(
        imagePaths: imagePaths, table: table, onEndCallback: _popQueue);
  }

  Widget _sequenceAnimation(int count, String no,
      {double duration: 1.0 / 30, double scale: 1.0}) {
    var imagePaths = <String>[];
    if (GiftUseCase.isTargetPlatform) {
      imagePaths = List<String>.generate(
              count,
              (i) =>
                  '${GiftUseCase.giftPath}/$no/${no}_${i.toString().padLeft(5, '0')}.png')
          .toList();
    } else {
      imagePaths = List<String>.generate(count, (i) {
        return 'assets/anim/new/$no/${no}_${i.toString().padLeft(5, '0')}.png';
      }).toList();
    }
    return SequenceAnimation(
        assetPaths: imagePaths,
        scale: scale,
        duration: 1.0 / 15,
        onEndCallback: _popQueue);
  }

  Widget _sequenceAnimationUpDown(int count, String no,
      {double duration = 1.0 / 30,
      double scale = 1.0,
      double additionalOffset = 0}) {
    var imageUpPaths = <String>[];
    var imageDownPaths = <String>[];
    if (GiftUseCase.isTargetPlatform) {
      imageUpPaths = List<String>.generate(
              count,
              (i) =>
                  '${GiftUseCase.giftPath}/$no/${no}u/${no}u_${i.toString().padLeft(5, '0')}.png')
          .toList();
      imageDownPaths = List<String>.generate(
              count,
              (i) =>
                  '${GiftUseCase.giftPath}/$no/${no}d/${no}d_${i.toString().padLeft(5, '0')}.png')
          .toList();
    } else {
      imageUpPaths = List<String>.generate(
              count,
              (i) =>
                  'assets/anim/new/$no/${no}u/${no}u_${i.toString().padLeft(5, '0')}.png')
          .toList();
      imageDownPaths = List<String>.generate(
              count,
              (i) =>
                  'assets/anim/new/$no/${no}d/${no}d_${i.toString().padLeft(5, '0')}.png')
          .toList();
    }
    final infos = [
      SequenceInfo(
          align: SequenceAlign.BOTTOM,
          offset: 200.0 + additionalOffset,
          assetPaths: imageDownPaths), // コメント欄の上に配置
      SequenceInfo(
          align: SequenceAlign.TOP, offset: 0, assetPaths: imageUpPaths),
    ];
    return SequenceAnimationMulti(
        sequenceInfos: infos,
        scale: scale,
        duration: 1.0 / 15,
        onEndCallback: _popQueue);
  }
}
