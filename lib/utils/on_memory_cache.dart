import 'package:live812/utils/result.dart';

abstract class OnMemoryCache {
  static final _cached = Map<String, _Entry>();

  // キャッシュにあったらそれを返し、なかったり期限切れだったらrequestを呼び出してキャッシュする
  static Future<T> fetch<T>(String key, Duration duration, Future<T> Function() request, {bool force = false}) async {
    if (!force && _cached.containsKey(key)) {
      final entry = _cached[key];
      if (DateTime.now().compareTo(entry.expireTime) < 0) {
        return entry.content;
      }
    }
    return update(key, duration, request);
  }

  // requestを呼び出してキャッシュを更新する
  static Future<T> update<T>(String key, Duration duration, Future<T> Function() request) async {
    clearKey(key);

    final content = await request();
    // null または Err の場合には失敗とみなし、キャッシュに登録しない
    if (content != null && !(content is Err)) {
      _cached[key] = _Entry(DateTime.now().add(duration), content);
    }
    return content;
  }

  // 指定のキーのキャッシュをクリア
  static bool clearKey<T>(String key) {
    if (!_cached.containsKey(key))
      return false;
    _cached.remove(key);
    return true;
  }
}

class _Entry {
  DateTime expireTime;
  dynamic content;

  _Entry(this.expireTime, this.content);
}
