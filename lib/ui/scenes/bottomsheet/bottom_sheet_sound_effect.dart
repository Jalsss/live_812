import 'dart:math';

import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';

const int _ITEM_COUNT = 6;

class BottomSheetSoundEffect extends StatefulWidget {
  final Function onBack;
  final void Function(int) onTap;

  BottomSheetSoundEffect({this.onBack, this.onTap});

  @override
  _BottomSheetSoundEffectState createState() => _BottomSheetSoundEffectState();
}

class _BottomSheetSoundEffectState extends State<BottomSheetSoundEffect> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final mq = MediaQuery.of(context);
        final leftPadding = max(mq.padding.left, 10.0);
        final rightPadding = max(mq.padding.right, 10.0);
        final div = orientation == Orientation.portrait ? 3 : 6;
        final itemWidth = (mq.size.width - leftPadding - rightPadding) / div;

        return Container(
          padding: EdgeInsets.only(
            left: leftPadding,
            right: rightPadding,
            bottom: mq.padding.bottom,
          ),
          color: ColorLive.BLUE_BG,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MaterialButton(
                    minWidth: 50,
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    onPressed: () {
                      widget.onBack();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          Lang.BACK_MENU,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: itemWidth * _ITEM_COUNT / div,
                child: GridView.count(
                  crossAxisCount: div,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  children: List.generate(_ITEM_COUNT, (index) {
                    return RawMaterialButton(
                      shape: CircleBorder(),
                      onPressed: () {
                        widget.onTap(index);
                      },
                      child: Image.asset('assets/images/sound${index + 1}.png'),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
