import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/other_user.dart';
import 'package:live812/ui/dialog/profile_dialog.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:intl/intl.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class FollowerItem extends StatelessWidget {
  final Function onBack;
  final OtherUserModel followerUser;

  FollowerItem({this.onBack, this.followerUser});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (followerUser.isLiver) {
          final _ = await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProfileViewPage(userId: followerUser.id)));
          onBack();
        } else {
          showDialog(
            context: context,
            builder: (context) => ProfileDialog(userId: followerUser.id),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                      image: followerUser.imgSmallUrl == null ? null : DecorationImage(
                        image: NetworkImage(followerUser.imgSmallUrl),
                        fit: BoxFit.cover,
                      ),
                      color: followerUser.imgSmallUrl != null ? null : Color(0xff404040),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          followerUser.nickname ?? "-",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          followerUser.symbol ?? "-",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('yyyy.MM.dd').format(followerUser.followDate),
                    style: TextStyle(color: ColorLive.TAB_SELECT_BG),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}