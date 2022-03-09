import 'package:flutter/material.dart';
import 'package:live812/ui/scenes/live/widget/required_mark.dart';
import 'package:live812/utils/custom_validator.dart';

class SongViews extends StatefulWidget {
  final TextEditingController controller;

  SongViews(this.controller);

  @override
  State createState() {
    return SongViewsState();
  }
}

class SongViewsState extends State<SongViews> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              '再生回数',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            requiredMark(),
          ],
        ),
        SizedBox(
          height: 16.0,
        ),
        Text(
          '1回の配信で利用した楽曲の再生回数を記載',
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(
          height: 8.0,
        ),
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white),
          validator: CustomValidator.validateRequired,
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
              hintText: "例)1",
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
        )
      ],
    );
  }
}
