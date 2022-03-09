import 'package:flutter/material.dart';
import 'package:live812/domain/model/timeline/timeline_comment_model.dart';
import 'package:live812/domain/model/timeline/timeline_post_model.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/result.dart';

// タイムラインのユースケース
class TimelineUsecase {
  static const int _PAGE_POST_COUNT = 10;  // １ページのポスト数

  TimelineUsecase._();

  static Future<Result<List<TimelinePostModel>, String>> requestTimeline(BuildContext context, {@required String userId, @required int offset}) async {
    final service = BackendService(context);
    final response = await service.getTimeline(id: userId, size: _PAGE_POST_COUNT, offset: offset);
    if (response?.result != true) {
      return Err<List<TimelinePostModel>, String>(response?.getByKey('msg'));
    }

    var items = response.getData() as List<dynamic>;
    return Ok<List<TimelinePostModel>, String>(items.map((v) => TimelinePostModel.fromJson(v)).toList());
  }

  static Future<Result<List<TimelineCommentModel>, String>> requestComments(BuildContext context, {@required String timelineId}) async {
    final service = BackendService(context);
    final response = await service.getTimelineMessage(timelineId);
    if (response?.result != true) {
      return Err<List<TimelineCommentModel>, String>(response?.getByKey('msg'));
    }

    List<dynamic> list = response.getData();
    return Ok<List<TimelineCommentModel>, String>(list.map((v) => TimelineCommentModel.fromJson(v)).toList());
  }
}
