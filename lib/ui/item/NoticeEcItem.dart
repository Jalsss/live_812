import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/notice_ec.dart';
import 'package:live812/utils/date_format.dart';

class NoticeEcItem extends StatelessWidget {
  final NoticeEcModel noticeEc;
  final void Function() onTap;

  NoticeEcItem({this.noticeEc, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:  onTap,
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
              child: Text('${dateFormat(noticeEc.createDate)} ${noticeEc.title ?? ''}',
                style: TextStyle(
                  color: noticeEc.isRead ? Colors.white : Colors.yellow,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 4),
            Container(
              child: Text(
                noticeEc.message ?? "",
                softWrap: true,
                maxLines: 3,
                style: TextStyle(
                  color: noticeEc.isRead ? Colors.white : Colors.yellow,
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
