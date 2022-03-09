import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';

class SettingSpecifiedCommercialPage extends StatefulWidget {
  @override
  _SettingSpecifiedCommercialPageState createState() => _SettingSpecifiedCommercialPageState();
}

class _SettingSpecifiedCommercialPageState extends State<SettingSpecifiedCommercialPage> {
  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.COMMERCIAL,
      titleColor: Colors.white,
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: ListView(
            children: <Widget>[
              Text(
                '販売社名',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '株式会社MyStar',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '運営統括責任者',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '坂根陽平',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '所在地',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '静岡県焼津市栄町1丁目４－１０',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '電話番号',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '050-3503-8589\n※お電話でのお問い合わせは受け付けておりません。お問い合わせは下記メールアドレスにメールをお送りください。またお問い合わせ言語は、日本語のみ対応させていただきます。',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'メールアドレス',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'support@live812.jp',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '販売URL',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'http://live812.jp/',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'お支払い方法',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'クレジットカード、銀行振込',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '商品代金以外の必要金額',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '銀行振込の場合、振込手数料が必要です。',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '販売数量',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '１個から。',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'お申込み有効期限',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '7日間入金がない場合は、キャンセルとさせていただきます。',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '商品引渡し時期',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'クレジットカード払いの場合、入金確認後7営業日以内に販売者より発送致します。\n銀行振込の場合、ご注文確認後7日営業日以内に販売者より発送致します。',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '商品引渡し方法',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '販売者により選択された運送会社による配送',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'キャンセル・不良品について',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '到着した商品に不備や商品説明・画像と相違が合った場合、お問い合わせから、取引番号、事実と違った取引内容、届いた商品の画像等、詳細情報をお送りください。\n原則的に、購入後のキャンセルは出来ません。',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '',
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  '',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              SizedBox(height: 10),
            ],
          )),
    );
  }
}
