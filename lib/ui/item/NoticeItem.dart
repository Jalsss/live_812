import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/notice.dart';
import 'package:live812/utils/date_format.dart';

class NoticeItem extends StatelessWidget {
  final NoticeModel notice;
  final Function onTap;

  NoticeItem({this.notice, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.white.withAlpha(20),
            ),
            SizedBox(height: 9),
            Container(
              child: Text(dateFormat(notice.createDate),
                style: TextStyle(
                  color: notice.read ? Colors.white : Colors.yellow,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 4),
            Container(
              child: Text(
                notice?.title ?? "",
                softWrap: true,
                maxLines: 3,
                style: TextStyle(
                  color: notice.read ? Colors.white : Colors.yellow,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
