import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live812/domain/model/timeline/timeline_post_model.dart';
import 'package:live812/utils/timeline_post_manager.dart';

TimelinePostModel _post({@required String id, @required String msg}) {
  return TimelinePostModel.fromJson({
    'id': id,
    'msg': msg,
  });
}

void main() {
  test('initial', () {
    final man = TimelinePostManager();
    expect(man.posts, isNull);

    man.setPosts([
      _post(id: 'id3', msg: 'msg3'),
      _post(id: 'id2', msg: 'msg2'),
    ], true);
    expect(man.posts.length, 2);
    expect(man.posts[0].id, 'id3');
    expect(man.posts[1].id, 'id2');
  });

  test('refresh', () {
    final man = TimelinePostManager();
    man.setPosts([
      _post(id: 'id3', msg: 'msg3'),
      _post(id: 'id2', msg: 'msg2'),
      _post(id: 'id1', msg: 'msg1'),
    ], true);
    man.setPosts([
      _post(id: 'id4', msg: 'msg4'),
      _post(id: 'id3', msg: 'msg3'),
      _post(id: 'id2', msg: 'msg2'),
    ], true);

    // リフレッシュは取得済みのポストがクリアされ、新しく取得したリストに置き換えられる
    expect(man.posts.length, 3);
    expect(man.posts[0].id, 'id4');
    expect(man.posts[1].id, 'id3');
    expect(man.posts[2].id, 'id2');
  });

  test('older', () {
    final man = TimelinePostManager();
    man.setPosts([
      _post(id: 'id9', msg: 'msg9'),
    ], true);

    man.setPosts([
      _post(id: 'id8', msg: 'msg8'),
      _post(id: 'id7', msg: 'msg7'),
    ], false);

    // 古いポストは後ろに追加される
    expect(man.posts.length, 3);
    expect(man.posts[0].id, 'id9');
    expect(man.posts[1].id, 'id8');
    expect(man.posts[2].id, 'id7');
  });

  test('update', () {
    final man = TimelinePostManager();
    man.setPosts([
      _post(id: 'id3', msg: 'msg3'),
      _post(id: 'id2', msg: 'msg2'),
      _post(id: 'id1', msg: 'msg1'),
    ], true);

    man.setPosts([
      _post(id: 'id4', msg: 'msg4'),
      _post(id: 'id3', msg: 'msg3'),
      _post(id: 'id2', msg: 'msg2 updated'),
    ], true);

    // 変更が反映される
    expect(man.posts.length, 3);
    expect(man.posts[2].id, 'id2');
    expect(man.posts[2].msg, 'msg2 updated');
  });

  test('update older', () {
    final man = TimelinePostManager();
    man.setPosts([
      _post(id: 'id3', msg: 'msg3'),
      _post(id: 'id2', msg: 'msg2'),
      _post(id: 'id1', msg: 'msg1'),
    ], true);

    man.setPosts([
      _post(id: 'id2', msg: 'msg2'),
      _post(id: 'id1', msg: 'msg1 updated'),
      _post(id: 'id0', msg: 'msg0'),
    ], false);

    // 変更が反映される
    expect(man.posts.length, 4);
    expect(man.posts[2].id, 'id1');
    expect(man.posts[2].msg, 'msg1 updated');
  });

  test('update inner', () {
    final man = TimelinePostManager();
    man.setPosts([
      _post(id: 'id3', msg: 'msg3'),
      _post(id: 'id2', msg: 'msg2'),
      _post(id: 'id1', msg: 'msg1'),
    ], true);

    man.setPosts([
      _post(id: 'id2', msg: 'msg2 updated'),
    ], false);

    // 変更が反映される
    expect(man.posts.length, 3);
    expect(man.posts[1].id, 'id2');
    expect(man.posts[1].msg, 'msg2 updated');
  });
}
