import 'package:flutter/material.dart';
import 'package:live812/domain/model/live/room_info.dart';
import 'package:live812/utils/consts/ColorLive.dart';

class LiveItem extends StatelessWidget {
  final RoomInfoModel roomInfo;
  final void Function() onTap;

  LiveItem(this.roomInfo, {@required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: ColorLive.MAIN_BG,
        elevation: 5,
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              child: FadeInImage.assetNetwork(
                placeholder: "assets/images/placeholder.png",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                image: roomInfo.imgUrl ?? '',
              )
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(3),
                        bottomLeft: Radius.circular(3)),
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(700),
                          Colors.transparent
                        ])),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHashTagText(roomInfo.tag1),
                  _buildHashTagText(roomInfo.tag2),
                  Text(
                    roomInfo.nickname ?? '',
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
                  ),
                ].where((w) => w != null).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashTagText(String tag) {
    return tag?.isNotEmpty != true ? null : Text(
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
