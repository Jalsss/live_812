import 'package:flutter/material.dart';
import 'package:live812/domain/model/user/news_event.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/ui/dialog/news_event_dialog.dart';
import 'package:live812/utils/modal_overlay.dart';
import 'package:provider/provider.dart';

class NewsEventUseCase {
  NewsEventUseCase._();

  /// ニュースの有無の確認.
  static Future checkNewsEvent(BuildContext context) async {
    final service = BackendService(context);
    final newsEventModel = Provider.of<NewsEventModel>(context, listen: false);

    // final response1 = await service.getNotificationCheck();
    // if (!(response1?.result ?? false)) {
    //   // エラー.
    //   return;
    // }
    //
    // if (!response1.containsKey("public_date")) {
    //   return;
    // }
    // final String publicDate = response1.getByKey("public_date");
    // if ((publicDate == null) || publicDate.isEmpty) {
    //   return;
    // }

    /// データの取得.
    final response2 = await service.getNotificationInfo();
    if (!(response2?.result ?? false)) {
      // エラー.
      return;
    }
    List<NewsEvent> listNewEvent = getListNewsEvent(response2.getData());
    List<NewsEvent> listEvents = [];
    listNewEvent.forEach((element) async {
      final lastReadDateTime = await newsEventModel.getLastReadDate();
      if (lastReadDateTime == null) {
        listEvents.add(element);
      } else {
        if (element.dateTime.isBefore(lastReadDateTime) ||
            element.dateTime.isAtSameMomentAs(lastReadDateTime)) {
          // 既に既読なので何もしない.
          return;
        } else {
          listEvents.add(element);
        }
      }
    });
    newsEventModel.setNewsEvent(listEvents);
  }

  /// ニュースの表示.
  static Future showNewsEvent(BuildContext context) async {
    final newsEventModel = Provider.of<NewsEventModel>(context, listen: false);
    if (newsEventModel.newsEvent == null) {
      // ニュースが無いので何もしない.
      return;
    }
    // final dateTime = newsEventModel.newsEvent.dateTime;
    // final lastReadDateTime = await newsEventModel.getLastReadDate();
    // if (dateTime.isBefore(lastReadDateTime) || dateTime.isAtSameMomentAs(lastReadDateTime)) {
    //   // 既読済みなので何もしない.
    //   return;
    // }

    final now = DateTime.now();
    final lastShowDateTime = await newsEventModel.getLastShowDate();
    // final showDateTime = lastShowDateTime.add(Duration(days: 1));
    List<NewsEvent> list = [];
    newsEventModel.newsEvent.forEach((element) async {
      final List<String> listShowId = await newsEventModel.getListShowId();
      if (listShowId.contains(element.id) && lastShowDateTime.isAfter(now)) {
        // 同じIDは特定の期間表示しない.
        return;
      } else {
        list.add(element);
      }
    });
    Future.delayed(Duration(milliseconds: 100), () {
      if (list.length > 0) {
        Navigator.push(
          context,
          ModalOverlay(
            child: NewsEventDialog(
              listNewsEvent: list,
              index: 0,
            ),
          ),
        );
      }
    });
  }
}
