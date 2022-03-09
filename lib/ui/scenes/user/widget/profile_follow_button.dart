import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:provider/provider.dart';

class ProfileFollowButton extends StatelessWidget {
  final String userId;
  final bool followed;
  final void Function(bool) onChangeFollowed;

  ProfileFollowButton({Key key, @required this.userId, @required this.followed, @required this.onChangeFollowed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (followed) {
      return Container(
        child: Container(
          height: 40.0,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: ColorLive.BLUE_BG,
            border: Border.all(color: Colors.white),
          ),
          child: FlatButton(
            textColor: Colors.white,
            onPressed: () async {
              await _requestFollow(context, false);
            },
            child: Text(
              Lang.FOLLOWING,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: ColorLive.C26,
        child: Container(
          height: 40.0,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              //end: Alignment.centerRight,s
              colors: [ColorLive.BLUE, ColorLive.BLUE_GR],
              //colors: [Color(0xFF2C7BE5), const Color(0xFF2C7BE5)],
            ),
          ),
          child: FlatButton(
            textColor: Colors.white,
            onPressed: () async {
              _requestFollow(context, true);
            },
            child: Text(
              Lang.FOLLOWING1,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _requestFollow(BuildContext context, bool willFollow) async {
    final userModel = Provider.of<UserModel>(context, listen: false);
    if (willFollow) {
      final response = await BackendService(context)
          .postUserFollow(followId: userId);
      if (response?.result != true)
        return;
      userModel.addFollow(userId);
    } else {
      final response = await BackendService(context)
          .postUserFollow(unfollowId: userId);
      if (response?.result != true)
        return;
      userModel.removeFollow(userId);
    }
    onChangeFollowed(willFollow);
  }
}
