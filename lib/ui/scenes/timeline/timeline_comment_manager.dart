import 'package:flutter/material.dart';
import 'package:live812/domain/model/timeline/timeline_comment_model.dart';
import 'package:live812/domain/usecase/timeline_usecase.dart';
import 'package:tuple/tuple.dart';

class TimelineCommentManager {
  final _commentMap = Map<String, List<TimelineCommentModel>>();
  String _commentOpenPostId;  // コメントをオープンする投稿ID

  String get commentOpenPostId => _commentOpenPostId;

  Future<List<TimelineCommentModel>> requestFor(BuildContext context, String postId) async {
    final result = await TimelineUsecase.requestComments(context, timelineId: postId);
    return result.match(
      ok: (comments) {
        _commentMap[postId] = comments;
        return comments;
      },
      err: (_msg) {
        return null;
      },
    );
  }

  List<TimelineCommentModel> getCommentsFor(String postId) {
    return _commentMap[postId];
  }

  bool isOpen(String postId) {
    return postId == _commentOpenPostId;
  }

  bool isAnyOpen() {
    return _commentOpenPostId != null;
  }

  void openComment(String postId) {
    _commentOpenPostId = postId;
  }

  bool closeComment(String _postId) {
    if (_commentOpenPostId == null)
      return false;
    _commentOpenPostId = null;
    return true;
  }

  bool closeAllComments() {
    if (_commentOpenPostId == null)
      return false;
    _commentOpenPostId = null;
    return true;
  }

  // 開いているコメントを更新するフューチャーリストを返す
  List<Future<Tuple2<String, List<TimelineCommentModel>>>> requestOpenedComments(BuildContext context) {
    final openPostId = _commentOpenPostId;
    if (openPostId == null)
      return null;

    return [openPostId].map((postId) async {
      final comments = await requestFor(context, postId);
      if (comments != null)
        return Tuple2<String, List<TimelineCommentModel>>(postId, comments);
      else
        return null;
    }).toList();
  }
}
