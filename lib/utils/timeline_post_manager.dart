import 'package:live812/domain/model/timeline/timeline_post_model.dart';

class TimelinePostManager {
  List<TimelinePostModel> _posts;

  List<TimelinePostModel> get posts => _posts;
  bool get isNull => _posts == null;
  bool get isEmpty => _posts != null && _posts.isEmpty;

  void clear() {
    _posts = null;
  }

  void setPosts(List<TimelinePostModel> newPosts, bool refresh) {
    assert(newPosts != null);
    if (_posts == null) {
      _posts = newPosts;
      return;
    }
    if (newPosts.isEmpty)
      return;

    if (refresh) {
      // リフレッシュの場合は置き換え
      _posts = newPosts;
    } else {
      // 投稿をマージする
      final index1 = _posts.indexWhere((post) => post.id == newPosts.first.id);
      if (index1 >= 0) {
        var updated = _posts.sublist(0, index1) + newPosts;
        if (_posts.length > index1 + newPosts.length)
          updated += _posts.sublist(index1 + newPosts.length);
        _posts = updated;
      } else {
        final index2 = newPosts.indexWhere((post) => post.id == _posts.last.id);
        if (index2 >= 0) {
          _posts = _posts.sublist(0, _posts.length - (index2 + 1)) + newPosts;
        } else {
          _posts = _posts + newPosts;
        }
      }
    }
  }

  void removePostAt(int index) {
    _posts.removeAt(index);
  }
}
