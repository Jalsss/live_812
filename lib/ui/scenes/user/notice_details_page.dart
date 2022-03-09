import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:live812/domain/model/user/notice.dart';
import 'package:live812/ui/scenes/user/profile_view.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/date_format.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/widget/LiveScaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeDetailsPage extends StatelessWidget {
  final NoticeModel model;
  final RegExp reUserDetailUrl = RegExp(r'^https?://share\.live812\.works/user/(\w+)$');

  NoticeDetailsPage({@required this.model});

  @override
  Widget build(BuildContext context) {
    return LiveScaffold(
      backgroundColor: ColorLive.MAIN_BG,
      title: Lang.NOTICE,
      titleColor: Colors.white,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  model.title ?? "",
                  softWrap: true,
                  maxLines: 3,
                  style:
                      TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Text(dateFormat(model.createDate),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: Colors.white.withAlpha(20),
              ),
              Html(
                data: model.content ?? "",
                defaultTextStyle: TextStyle(color: Colors.white),
                onLinkTap: (url) async {
                  RegExpMatch m;
                  if ((m = reUserDetailUrl.firstMatch(url)) != null) {
                    final userId = m.group(1);
                    _openProfileViewPage(context, userId);
                  } else {
                    if (await canLaunch(url)) {
                      await launch(url, forceSafariVC: false);
                    } else {
                      throw 'Could not Launch $url';
                    }
                  }
                },
              ),
              model.imageUrl?.isNotEmpty != true ? null : Image.network(model.imageUrl),
            ].where((w) => w != null).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _openProfileViewPage(BuildContext context, String userId) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProfileViewPage(userId: userId)));
  }
}
