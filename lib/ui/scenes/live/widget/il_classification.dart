import 'package:flutter/material.dart';
import 'package:live812/ui/scenes/live/widget/required_mark.dart';

enum Il {
  I,
  L,
  Other,
}

typedef OnChangeIl = Function(Il);

class IlClassification extends StatefulWidget {
  final   Il il;
  final OnChangeIl onChangeIl;
  final TextEditingController controller;

  IlClassification(this.il, this.onChangeIl, this.controller);

  @override
  State createState() {
    return IlClassificationState();
  }
}

class IlClassificationState extends State<IlClassification> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'IL区分',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            requiredMark(),
          ],
        ),
        ListTile(
          title: const Text(
            'I(国内楽曲)',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: Il.I,
            groupValue: widget.il,
            onChanged: (value) {
              widget.onChangeIl(value);
            },
          ),
        ),
        ListTile(
          title: const Text(
            'L(海外楽曲)',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: Il.L,
            groupValue: widget.il,
            onChanged: (value) {
              widget.onChangeIl(value);
            },
          ),
        ),
        ListTile(
          title: const Text(
            'その他',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: Il.Other,
            groupValue: widget.il,
            onChanged: (value) {
              widget.onChangeIl(value);
            },
          ),
        ),
        TextFormField(
          controller: widget.controller,
          style: TextStyle(color: Colors.white),
          enabled: widget.il == Il.Other,
          decoration: InputDecoration(
              fillColor: Colors.white.withAlpha(20),
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              errorBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              //labelText: Lang.SEARCH_HINT,
              hintText: "その他の場合、入力してください。",
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
        )
      ],
    );
  }
}
