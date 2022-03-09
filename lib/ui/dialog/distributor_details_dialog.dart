import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/super_text_util.dart';
import 'package:live812/utils/widget/safe_network_image.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/user/model/icon_badge_model.dart';
import 'package:live812/ui/scenes/user/widget/list_icon_badge_widget.dart';

class DistributorDetailsDialog extends StatefulWidget {
  final UserModel targetUserModel;

  DistributorDetailsDialog(this.targetUserModel);

  @override
  _DistributorDetailsDialogState createState() =>
      _DistributorDetailsDialogState();
}

class _DistributorDetailsDialogState extends State<DistributorDetailsDialog> {
  List<IconBadge> listIcon = [];
  bool showAllBadge = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBadge();
  }

  getBadge() async {
    final service = BackendService(context);
    final responseBadge = await service.getIconBadge(widget.targetUserModel.id);
    setState(() {
      showAllBadge = listIcon.length > 8 ? false : true;
      listIcon = responseBadge?.result == true
          ? getListIconBadge(responseBadge.data.getByKey('badge'))
          : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: _dialogContent(context),
    );
  }

  Widget _dialogContent(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.height - 200
          : MediaQuery.of(context).size.height - 100,
      padding: EdgeInsets.only(
        top: Consts.padding,
        bottom: Consts.padding,
        left: Consts.padding,
        right: Consts.padding,
      ),
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
      child: ListView(
        children: <Widget>[
          Center(
            child: Container(
              width: 140,
              height: 140,
              child: CircleAvatar(
                radius: 15.0,
                backgroundImage: SafeNetworkImage(
                    BackendService.getUserThumbnailUrl(
                        widget.targetUserModel.id)),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            widget.targetUserModel.nickname ?? '',
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            widget.targetUserModel.symbol ?? '',
            textAlign: TextAlign.center,
          ),
          _divider(),
          listIcon.length > 0
              ? ListIconBadge(
                  listIconBadge: listIcon,
                  showAllBadge: showAllBadge,
                  showAll: () {
                    setState(() {
                      showAllBadge = !showAllBadge;
                    });
                  },
                  colorsDropdown: Colors.black,
                )
              : SizedBox(),
          listIcon.length > 0 ? _divider() : SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text("フォロワー"),
                  Text(
                    _getProperty(widget.targetUserModel, 'follower_count')
                            ?.toString() ??
                        '-',
                    style: TextStyle(
                        color: ColorLive.ORANGE,
                        fontWeight: FontWeight.w700,
                        fontSize: 20),
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Text("月間ランキング"),
                  Text(
                    _getProperty(widget.targetUserModel, 'rank')?.toString() ??
                        '-',
                    style: TextStyle(
                        color: ColorLive.ORANGE,
                        fontWeight: FontWeight.w700,
                        fontSize: 20),
                  )
                ],
              )
            ],
          ),
          _divider(),
          DefaultTextStyle(
            style: TextStyle(color: Colors.black),
            child: _buildProfile(
                context, _getProperty(widget.targetUserModel, 'profile')),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(BuildContext context, String profile) {
    if (profile?.isNotEmpty != true) {
      return Text("-", textAlign: TextAlign.center);
    }

    final list = SuperTextUtil.parse(profile + '\n');

    return SuperTextWidget(
      list,
      textStyle: const TextStyle(color: Colors.black),
      external: true,
      textAlign: TextAlign.center,
    );
  }

  dynamic _getProperty(UserModel userModel, String key) {
    return userModel.json != null ? userModel.json[key] : null;
  }

  Widget _divider({color: ColorLive.BORDER3, height: 20.0}) {
    return Divider(
      color: color,
      height: height,
      thickness: 1,
    );
  }
}
