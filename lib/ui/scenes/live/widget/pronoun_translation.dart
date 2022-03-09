import 'package:flutter/material.dart';
import 'package:live812/ui/scenes/live/widget/required_mark.dart';

enum PronounTranslationType {
  Original,
  Cover,
  Unknown,
}

typedef OnChangePronounTranslation = Function(PronounTranslationType);

class PronounTranslation extends StatefulWidget {

  final   PronounTranslationType number;
  final OnChangePronounTranslation onChangePronounTranslation;

  PronounTranslation(this.number, this.onChangePronounTranslation);

  @override
  State createState() {
    return PronounTranslationState();
  }
}

class PronounTranslationState extends State<PronounTranslation> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '原詞訳詞区分',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            requiredMark(),
          ],
        ),
        ListTile(
          title: const Text(
            '1(いわゆるオリジナル曲)',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: PronounTranslationType.Original,
            groupValue: widget.number,
            onChanged: (value) {
              widget.onChangePronounTranslation(value);
            },
          ),
        ),
        ListTile(
          title: const Text(
            '2(いわゆるカバー曲)',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: PronounTranslationType.Cover,
            groupValue: widget.number,
            onChanged: (value) {
              widget.onChangePronounTranslation(value);
            },
          ),
        ),
        ListTile(
          title: const Text(
            '3(不明)',
            style: TextStyle(color: Colors.white),
          ),
          leading: Radio(
            value: PronounTranslationType.Unknown,
            groupValue: widget.number,
            onChanged: (value) {
              widget.onChangePronounTranslation(value);
            },
          ),
        ),
      ],
    );
  }
}
