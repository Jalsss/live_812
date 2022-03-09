import 'package:flutter/material.dart';
import 'package:live812/ui/scenes/live/widget/required_mark.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/custom_validator.dart';
import 'package:url_launcher/url_launcher.dart';

class JasracWorkCode extends StatefulWidget {
  final TextEditingController controller;

  JasracWorkCode(this.controller);

  @override
  State createState() {
    return JasracWorkCodeState();
  }
}

class JasracWorkCodeState extends State<JasracWorkCode> {

  _launchURL() async {
    const url = "http://www2.jasrac.or.jp/eJwid/main?trxID=F00100";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not Launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'JASRAC作品コード',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            requiredMark(),
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        Text(
          '作品コードは下記URLからご確認ください。',
          style: TextStyle(color: Colors.white),
        ),
        GestureDetector(
          child: Text(
            'http://www2.jasrac.or.jp/eJwid/main?trxID=F00100',
            style: TextStyle(
                color: ColorLive.BLUE, decoration: TextDecoration.underline),
          ),
          onTap: () {
            _launchURL();
          },
        ),
        SizedBox(
          height: 8.0,
        ),
        TextFormField(
          controller: widget.controller,
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
              hintText: "例）123-4567-8",
              labelStyle: TextStyle(color: Colors.white),
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
        )
      ],
    );
  }
}
