import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:live812/domain/model/user/other_user.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/date_format.dart';
import 'package:provider/provider.dart';

class FollowingItem extends StatefulWidget {
  final OtherUserModel follower;
  final void Function() onBack;
  final Future<bool> Function() changeNotification;

  FollowingItem(this.follower,
      {Key key, this.onBack, @required this.changeNotification})
      : super(key: key);

  @override
  FollowingItemState createState() => FollowingItemState();
}

class FollowingItemState extends State<FollowingItem> {
  var _isFollow = true;
  bool _notificationEnabled;

  @override
  void initState() {
    super.initState();
    _notificationEnabled = widget.follower.notify;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () async {
                final _follower = await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfileViewPage(userId: widget.follower.id)));
                if ((_follower != null) && (_follower is OtherUserModel)) {
                  // 通知設定を書き換える.
                  setState(() {
                    _notificationEnabled = _follower.notify;
                  });
                }
                if (widget.onBack != null) widget.onBack();
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                      image: widget.follower.imgSmallUrl == null
                          ? null
                          : DecorationImage(
                              image: NetworkImage(widget.follower.imgSmallUrl),
                              fit: BoxFit.cover,
                            ),
                      color: widget.follower.imgSmallUrl != null
                          ? null
                          : Color(0xff404040),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.follower.nickname ?? "-",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.follower.symbol ?? "-",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: !_isFollow ? null : _toggleNotification,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Container(
                margin: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  _isFollow && _notificationEnabled
                      ? 'assets/svg/bell_on.svg'
                      : 'assets/svg/bell_off.svg',
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Container(
                height: 30,
                width: 100,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  border: Border.all(color: ColorLive.BORDER2, width: 1),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    colors: [
                      _isFollow ? ColorLive.BORDER2 : ColorLive.BLUE,
                      _isFollow ? ColorLive.BORDER2 : ColorLive.BLUE_GR
                    ],
                  ),
                ),
                child: FlatButton(
                  textColor: Colors.white,
                  onPressed: _toggleFollow,
                  child: Text(
                    !_isFollow ? Lang.FOLLOW : Lang.FOLLOWING,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              Text(
                '${dateFormat(widget.follower.followDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorLive.ORANGE,
                ),
              ),
            ],
          ),
        ].where((w) => w != null).toList(),
      ),
    );
  }

  Future<void> _toggleFollow() async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (_isFollow) {
      final response = await BackendService(context)
          .postUserFollow(unfollowId: widget.follower.id);
      if (response?.result == true) {
        setState(() {
          _isFollow = false;
          userModel.removeFollow(widget.follower.symbol);
        });
      }
    } else {
      final response = await BackendService(context)
          .postUserFollow(followId: widget.follower.id);
      if (response?.result == true) {
        setState(() {
          _isFollow = true;
          userModel.addFollow(widget.follower.symbol);
        });
      }
    }
  }

  Future<void> _toggleNotification() async {
    final result = await widget.changeNotification();
    setState(() => _notificationEnabled = result);
  }
}
