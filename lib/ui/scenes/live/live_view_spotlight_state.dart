import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spotlight/flutter_spotlight.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:live812/domain/model/live/live_coach_mark.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LiveViewSpotlightState {
  final List<Key> targetKeys;
  final List<Widget> descriptions;
  final void Function(int) onPageChanged;

  bool enable = false;
  Offset center;
  double radius = 50.0;
  Widget description;
  int index = 0;

  LiveViewSpotlightState(
      List<Key> targetKeys,
      {this.onPageChanged})
      : this.targetKeys = targetKeys
      , descriptions = _createLiveViewSpotlightDescriptions();

  void displaySpotlight(int index) {
    if (index >= targetKeys.length) {
      index = 0;
      enable = false;
      onPageChanged(null);
      LiveCoachMark.saveShowCoachMark();
      return;
    }

    Rect target = Spotlight.getRectFromKey(targetKeys[index]);
    if (target == null) {
      target = Rect.fromCircle(center: Offset(-100, -100), radius: 10);
    }
    enable = true;
    center = Offset(target.center.dx, target.center.dy);
    radius = Spotlight.calcRadius(target);
    description = Container(
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: DotsIndicator(
                dotsCount: descriptions.length,
                position: index.toDouble(),
                decorator: DotsDecorator(
                  color: ColorLive.TRANS_WHITE_90,
                  activeColor: Colors.white,
                  size: const Size(50.0, 5.0),
                  activeSize: const Size(50.0, 5.0),
                  activeShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
              ),
            ),
          ),
          Swiper(
            itemBuilder: (context, index) {
              return descriptions[index];
            },
            loop: false,
            itemCount: descriptions.length,
            onIndexChanged: (index) {
              index = index;
              displaySpotlight(index);
            },
            control: SwiperControl(color: Colors.white),
          ),
          Positioned(
            top: 8.0,
            right: 8.0,
            child: GestureDetector(
              child: Container(
                padding: EdgeInsets.all(8),
                color: ColorLive.TRANS_90,
                child: Icon(
                  Icons.close,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                index = descriptions.length + 1;
                displaySpotlight(index);
              },
            ),
          ),
        ],
      ),
    );
    onPageChanged(index);
  }
}

List<Widget> _createLiveViewSpotlightDescriptions() {
  return [
    Column( // いいね
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 80.0,
          child: Image.asset('assets/images/ico01.png'),
        ),
        SizedBox(height: 16.0),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'ライバーに ',
            style: ThemeData
                .dark()
                .textTheme
                .caption
                .copyWith(color: Colors.white, fontSize: 24.0),
            children: <TextSpan>[
              TextSpan(text: 'いいね！', style: ThemeData
                  .dark()
                  .textTheme
                  .caption
                  .copyWith(color: ColorLive.YELLOW, fontSize: 24.0)),
              TextSpan(text: 'を\n送ってみよう', style: ThemeData
                  .dark()
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 24.0)),
            ],
          ),
        )
      ],
    ),
    Column( // ギフト
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 80.0,
          child: Image.asset('assets/images/ico02.png'),
        ),
        SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'お気に入りのライバーには\n',
            style: ThemeData
                .dark()
                .textTheme
                .caption
                .copyWith(color: Colors.white, fontSize: 24.0),
            children: <TextSpan>[
              TextSpan(text: 'ギフト', style: ThemeData
                  .dark()
                  .textTheme
                  .caption
                  .copyWith(color: ColorLive.YELLOW, fontSize: 24.0)),
              TextSpan(text: 'を贈って応援！', style: ThemeData
                  .dark()
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 24.0)),
            ],
          ),
        ),
      ],
    ),
    Column( // フォロー
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 86.0,
          padding: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4)),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 10),
              Text(Lang.FOLLOW,
                  style: ThemeData
                      .dark()
                      .textTheme
                      .caption
                      .copyWith(color: Colors.white, fontSize: 12))
            ],
          ),
        ),
        SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'フォロー',
            style: ThemeData
                .dark()
                .textTheme
                .caption
                .copyWith(color:  ColorLive.YELLOW, fontSize: 24.0),
            children: <TextSpan>[
              TextSpan(text: 'するのを\n', style: ThemeData
                  .dark()
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 24.0)),
              TextSpan(text: '忘れずに！', style: ThemeData
                  .dark()
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 24.0)),
            ],
          ),
        ),
      ],
    ),
    Column( // メニュー
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'メニュー\n',
            style: ThemeData
                .dark()
                .textTheme
                .caption
                .copyWith(color: ColorLive.YELLOW, fontSize: 24.0),
            children: <TextSpan>[
              TextSpan(text: 'を開くと\nメッセージを送ったり\n出品中の商品が見つかる！？', style: ThemeData
                  .dark()
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 24.0)),
            ],
          ),
        ),
      ],
    ),
    Column( // メニュー
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SvgPicture.asset(
        "assets/svg/icon_01.svg",
        height: 50,
      ),
        SizedBox(height: 16),
        RichText(
          textAlign: TextAlign.center,
          text:
              TextSpan(text: 'お好みの気分に合わせて \n視聴スタイルを選んでみよう！', style: ThemeData
                  .dark()
                  .textTheme
                  .caption
                  .copyWith(color: Colors.white, fontSize: 24.0)),


        ),
      ],
    )
  ];
}
