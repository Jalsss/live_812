import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/other_user.dart';
import 'package:live812/ui/dialog/profile_dialog.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:live812/utils/route/fade_route.dart';

class LiverGridItem extends StatelessWidget {
  final OtherUserModel user;

  LiverGridItem(this.user);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (user.isLiver) {
          Navigator.push(
              context, FadeRoute(builder: (context) => ProfileViewPage(userId: user.id)));
        } else {
          showDialog(
            context: context,
            builder: (context) => ProfileDialog(userId: user.id),
          );
        }
      },
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width / 3 - 15,
            height: MediaQuery.of(context).size.width / 3 - 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
              image: DecorationImage(
                image: NetworkImage(
                    user.imgThumbUrl),
                fit: BoxFit.cover,
                onError: (d, s) {
                  print("$d");
                }
              ),
            ),
          ),
          SizedBox(height: 1),
          Text(
            user.nickname ?? '',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
