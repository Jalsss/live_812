import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/profile_dialog.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/safe_network_image.dart';
import 'package:provider/provider.dart';

class FanRankDialog extends StatelessWidget {
  final String title;
  final String userId;

  FanRankDialog({this.title, @required this.userId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(Consts.padding),
      // ),
      elevation: 0.0,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height - 200,
          width: double.infinity,
          padding: EdgeInsets.only(
            //top: Consts.padding,
            bottom: Consts.padding,
            //left: Consts.padding,
            //right: Consts.padding,
          ),
          // margin: EdgeInsets.only(
          //     top: Consts.avatarRadius, bottom: Consts.avatarRadius),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorLive.BG2,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.only(top: 16, bottom: 23),
                child: Center(
                  child: Text(
                    Lang.FANRANK,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Divider(
                color: ColorLive.BORDER4,
                thickness: 1,
                height: 1,
              ),
              Expanded(
                child: FutureProvider<List<UserModel>>(
                  create: (context) => _requestFunRanking(context),
                  child: Consumer<List<UserModel>>(
                    builder: (context, list, _) {
                      if (list == null)
                        return Container();

                      return ListView(
                        padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                        children: List.generate(list.length, (index) => _giftItem(context, index, list[index])),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _giftItem(BuildContext context, int rank, UserModel userModel) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            Text("${rank + 1}"),
            SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  shape: BoxShape.circle),
              child: RawMaterialButton(
                elevation: 2,
                shape: CircleBorder(),
                child: CircleAvatar(
                  radius: 15.0,
                  backgroundImage: SafeNetworkImage(
                    BackendService.getUserThumbnailUrl(userModel.id, small: true)),
                  backgroundColor: Colors.white.withAlpha(100),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ProfileDialog(userId: userModel.id),
                  );
                },
              ),
            ),
            SizedBox(width: 7),
            Expanded(
              child: Text(
                userModel.nickname ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${userModel.json['point']}',
              style: TextStyle(fontFamily: "Roboto"),
            ),
            SizedBox(width: 5),
            SvgPicture.asset(
              "assets/svg/gift.svg",
              height: 16,
            ),
          ],
        ),
        Divider(
          height: 15,
          thickness: 1,
          color: ColorLive.BORDER4.withAlpha(400),
        )
      ],
    );
  }

  Future<List<UserModel>> _requestFunRanking(BuildContext context) async {
    final service = BackendService(context);
    final response = await service.getRankFun(userId);
    if (response != null && response.result) {
      final list = List<UserModel>();
      final data = response.getData();
      for (final d in data) {
        list.add(UserModel.fromJson(d));
      }
      return list;
    }
    return null;
  }
}
