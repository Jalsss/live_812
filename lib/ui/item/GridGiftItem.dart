import 'package:flutter/material.dart';
import 'package:live812/domain/model/live/gift_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:provider/provider.dart';

class GridGiftItem extends StatelessWidget {
  final double width;
  final GiftInfoModel giftInfo;
  final void Function() onTap;

  GridGiftItem({
    @required this.width,
    @required this.giftInfo,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Container(
            width: width,
            height: width,
            // TODO: 画像もAPIで取得したものに修正する？
            child: FittedBox(
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/gift${giftInfo.imageId}.png",
                  ),
                  giftInfo.isNew
                      ? Image.asset(
                          "assets/images/gift_new.png",
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(3)),
              border: Border.all(color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            giftInfo.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Consumer<UserModel>(
            builder: (context, userModel, _) {
              if (giftInfo.point <= userModel.point) {
                return Text(
                  '${giftInfo.point}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: ColorLive.ORANGE,
                    fontFamily: "Roboto",
                  ),
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${giftInfo.point}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: ColorLive.RED,
                        fontFamily: "Roboto",
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      //color: ColorLive.RED,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        Lang.POINT_DEFICIT,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorLive.YELLOW,
                          fontFamily: "Roboto",
                        ),
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
