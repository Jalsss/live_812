import 'package:flutter/material.dart';
import 'package:live812/ui/scenes/live/widget/required_mark.dart';

enum YesOrNo {
  Yes,
  No,
}

typedef OnChangeYesOrNo = Function(YesOrNo);

class HowManyTimes extends StatefulWidget {

  final YesOrNo yesOrNo;
  final OnChangeYesOrNo onChangeYesOrNo;
  final int times;

  HowManyTimes(this.yesOrNo, this.onChangeYesOrNo, this.times);

  @override
  State createState() {
    return HowManyTimesState();
  }
}

class HowManyTimesState extends State<HowManyTimes> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '${widget.times}曲以上の楽曲を配信で使用しましたか?',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            requiredMark(),
          ],
        ),
        ListTile(
          title: const Text(
            'はい',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: YesOrNo.Yes,
            groupValue: widget.yesOrNo,
            onChanged: (value) {
//              setState(() {
//                yesOrNo = value;
//              });
              widget.onChangeYesOrNo(value);
            },
          ),
        ),
        ListTile(
          title: const Text(
            'いいえ',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: YesOrNo.No,
            groupValue: widget.yesOrNo,
            onChanged: (value) {
              widget.onChangeYesOrNo(value);
            },
          ),
        ),
      ],
    );
  }
}
