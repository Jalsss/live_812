import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/usecase/jasrac_usecase.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:live812/utils/widget/primary_button.dart';
import 'package:provider/provider.dart';

class ApplyJasracPage extends StatefulWidget {
  final liveId;

  ApplyJasracPage(this.liveId);

  @override
  State createState() {
    return ApplyJasracPageState();
  }
}

class ApplyJasracPageState extends State<ApplyJasracPage> {
  var _isLoading = false;

  Future _requestJasrac() async {
    setState(() {
      _isLoading = true;
    });
    final token = await JasracUseCase.requestWebToken(context);
    setState(() {
      _isLoading = false;
    });
    if ((token == null) || (token.isEmpty)) {
      await JasracUseCase.showMessage(context, 'エラー', 'ウェブトークンの取得に失敗しました');
      return;
    }
    await JasracUseCase.transitionJasrac(context, token);
  }

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      title: 'JASRAC楽曲使用申請',
      backgroundColor: ColorLive.MAIN_BG,
      titleColor: Colors.white,
      isBackButton: false,
      isLoading: _isLoading,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.close,
            color: ColorLive.BLUE,
          ),
          onPressed: () {
            // 配信中フラグがtrueの場合はAgora通信を切断する
            final userModel = Provider.of<UserModel>(context, listen: false);
            if (userModel.isBroadcasting) {
              userModel.setIsBroadcasting(false);
              userModel.saveToStorage();
            }

            Navigator.pop(context);
          },
        ),
      ],
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '配信お疲れ様でした。\nJASRACへの楽曲使用申請のため必要事項の記載をお願い致します。\n楽曲を使用していない場合は、右上の閉じるボタンを押してください。',
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          PrimaryButton(
            text: '楽曲使用申請へ',
            onPressed: () async {
              await _requestJasrac();
            },
          )
        ],
      ),
    );
  }
}
