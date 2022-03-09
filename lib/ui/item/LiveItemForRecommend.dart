import 'package:flutter/material.dart';
import 'package:live812/domain/model/live/room_info.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class LiveItemForRecommend extends StatelessWidget {
  final RoomInfoModel roomInfo;
  final void Function() onTap;

  LiveItemForRecommend(this.roomInfo, {@required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 3 - 15,
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: <Widget>[
            Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2.5,
                        height: MediaQuery.of(context).size.width / 3 - 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white),
                          image: DecorationImage(
                              image: NetworkImage(roomInfo.imgUrl),
                              fit: BoxFit.fitHeight,
                              onError: (d, s) {
                                print("$d");
                              }),
                        ),
                      ),
                      if (roomInfo.broadcasting)
                        Image.asset(
                          'assets/gif/broadcasting.gif',
                          width: MediaQuery.of(context).size.width / 2.5,
                          height: MediaQuery.of(context).size.width  / 3 - 30,
                        ),
                    ],
                  ),
            SizedBox(height: 5),
            Text(
              roomInfo.nickname ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashTagText(String tag) {
    return tag?.isNotEmpty != true
        ? null
        : Text(
            '#$tag',
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xffeeeeee),
              fontSize: 12,
              shadows: const [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black,
                  offset: Offset(0, 1),
                ),
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black,
                  offset: Offset(2, 1),
                ),
              ],
            ),
          );
  }
}
