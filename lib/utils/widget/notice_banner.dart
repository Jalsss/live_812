import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/notice.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/scenes/user/notice_details_page.dart';
import 'package:live812/utils/focus_util.dart';

class NoticeBanner extends StatefulWidget {
  static const double BANNER_HEIGHT = 80;

  @override
  _NoticeBannerState createState() => _NoticeBannerState();
}

class _NoticeBannerState extends State<NoticeBanner>
    with WidgetsBindingObserver {
  List<NoticeModel> _notices;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _requestNoticeResponse();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _requestNoticeResponse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: NoticeBanner.BANNER_HEIGHT,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: _notices == null
          ? null
          : CarouselSlider(
              height: NoticeBanner.BANNER_HEIGHT,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 5),
              autoPlayAnimationDuration: Duration(milliseconds: 1),
              viewportFraction: 1.0,
              pauseAutoPlayOnTouch: Duration(seconds: 20),
              items: _notices.map((notice) {
                return Builder(
                  builder: (context) {
                    return GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        child: Image.network(
                          notice.imageUrl,
                          loadingBuilder: (context, w, ld) {
                            return ld == null
                                ? w
                                : const CircularProgressIndicator();
                          },
                          errorBuilder: (context, obj, stackTrace) {
                            return const Icon(Icons.error);
                          },
                          height: NoticeBanner.BANNER_HEIGHT,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      onTap: () {
                        FocusUtil.unFocus(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NoticeDetailsPage(
                                      model: notice,
                                    )));
                      },
                    );
                  },
                );
              }).toList(),
            ),
    );
  }

  Future<void> _requestNoticeResponse() async {
    final service = BackendService(context);
    final response = await service.getInfoBanner(size: 30, offset: 0);
    if (response?.result == true) {
      List<NoticeModel> notices = [];
      response
          .getData()
          .forEach((info) => notices.add(NoticeModel.fromJson(info)));
      if (notices.length > 0) {
        setState(() {
          _notices = notices;
        });
      }
    }
  }
}
