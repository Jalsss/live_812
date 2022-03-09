import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:live812/domain/model/live/gift_info.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/domain/usecase/gift_usecase.dart';
import 'package:live812/ui/dialog/charge_dialog.dart';
import 'package:live812/ui/item/GridGiftItem.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:provider/provider.dart';

class BottomSheetGift extends StatefulWidget {
  final List<GiftInfoModel> giftInfoList;
  final Function onBack;
  final void Function(int, GiftInfoModel) onTap;

  BottomSheetGift({
    @required this.giftInfoList,
    this.onBack,
    this.onTap,
  });

  @override
  _BottomSheetGiftState createState() => _BottomSheetGiftState();

  static Future<List<GiftInfoModel>> requestGiftInfo(
      BackendService backendService, UserModel userModel) async {
    try {
      return GiftUseCase.loadGiftInfoModelList();
    } on Exception catch (e) {
      return Future.value([]);
    }
  }
}

class _BottomSheetGiftState extends State<BottomSheetGift> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);
    bool isSpecialAccount =
        userModel != null ? userModel.symbol == "yaizo-" : true;
    List<GiftInfoModel> giftList = []..addAll(widget.giftInfoList);
 
    if (!isSpecialAccount) {
      giftList.removeWhere((element) => element.onlySpecialAccount);
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        final mq = MediaQuery.of(context);
        double height = orientation == Orientation.portrait ? 420 : 350;
        int colCount = orientation == Orientation.portrait ? 3 : 5;
        double unitWidth = MediaQuery.of(context).size.width / colCount - 32;

        return Container(
          height: height,
          color: ColorLive.BLUE_BG,
          child: Column(
            children: <Widget>[
              Expanded(
                child: giftList == null
                    ? Container()
                    : GridView.count(
                        padding: EdgeInsets.only(
                          top: 16,
                          left: mq.padding.left,
                          right: mq.padding.right,
                        ),
                        crossAxisCount: colCount,
                        childAspectRatio: .7,
                        children: List.generate(
                            giftList.length,
                            (index) => GridGiftItem(
                                  width: unitWidth,
                                  giftInfo: giftList[index],
                                  onTap: () {
                                    widget.onTap(index, giftList[index]);
                                  },
                                )).toList(),
                      ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: mq.padding.left + 16,
                  right: mq.padding.right + 16,
                  bottom: mq.padding.bottom,
                ),
                width: double.infinity,
                height: 50 + mq.padding.bottom,
                decoration: BoxDecoration(
                    color: ColorLive.MAIN_BG,
                    border: Border(
                        top: BorderSide(color: Colors.white, width: 0.1))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(Lang.BALANCE,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Row(
                      children: <Widget>[
                        Consumer<UserModel>(
                          builder: (context, userModel, _) {
                            return Text(
                              '${NumberFormat().format(userModel.point)}',
                              style: TextStyle(
                                  color: ColorLive.ORANGE,
                                  fontSize: 26,
                                  fontFamily: "Roboto"),
                            );
                          },
                        ),
                        Text(
                          " " + Lang.COIN,
                          style:
                              TextStyle(color: ColorLive.ORANGE, fontSize: 12),
                        ),
                        SizedBox(width: 10),
                        MaterialButton(
                          minWidth: 20,
                          onPressed: () {
                            _showChargeDialog((int point) {
                              setState(() {});
                            });
                          },
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          color: ColorLive.ORANGE,
                          child: Text(
                            Lang.CHARGE,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showChargeDialog(void Function(int) callback) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ChargeDialog(callback: callback),
    );
  }
}
