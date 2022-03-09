import 'package:flutter/material.dart';
import 'package:live812/ui/scenes/live/widget/required_mark.dart';

enum Ivt {
  V,
  I,
  T,
}

typedef OnChangeIvt = Function(Ivt);

class IvtClassification extends StatefulWidget {
  final Ivt ivt;
  final OnChangeIvt onChangeIvt;

  IvtClassification(this.ivt, this.onChangeIvt);

  @override
  State createState() {
    return IvtClassificationState();
  }
}

class IvtClassificationState extends State<IvtClassification> {


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'IVT区分',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            requiredMark(),
          ],
        ),
        ListTile(
          title: const Text(
            'V(詞曲の両方を使用)',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: Ivt.V,
            groupValue: widget.ivt,
            onChanged: (value) {
              widget.onChangeIvt(value);
            },
          ),
        ),
        ListTile(
          title: const Text(
            'I(曲のみ使用)',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: Ivt.I,
            groupValue: widget.ivt,
            onChanged: (value) {
              widget.onChangeIvt(value);
            },
          ),
        ),
        ListTile(
          title: const Text(
            'T(詞のみ使用)',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: Ivt.T,
            groupValue: widget.ivt,
            onChanged: (value) {
              widget.onChangeIvt(value);
            },
          ),
        ),
      ],
    );
  }
}
