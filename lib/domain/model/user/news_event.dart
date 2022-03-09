import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NewsEventModel extends ChangeNotifier {
  final String _lastReadDateKey = "news_event_last_read_date";
  final String _lastShowIdKey = "news_event_last_show_id";
  final String _lastShowDateKey = "news_event_last_show_date";

  SharedPreferences _preferences;

  List<NewsEvent> newsEvent;

  NewsEventModel();

  /// 最後の既読の日付を取得.
  /// データがない場合はその日より30日前を返す.
  Future<DateTime> getLastReadDate() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    String value = _preferences.getString(_lastReadDateKey);
    return value != null ? DateTime.parse(value) : DateTime.now().add(Duration(days: -30));
  }

  /// 最後の既読の日付を設定.
  Future setLastReadDate(DateTime dateTime) async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    await _preferences.setString(_lastReadDateKey, dateTime.toString());
  }

  /// 最後の既読の日付を削除.
  Future deleteLastReadDate() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    await _preferences.remove(_lastReadDateKey);
  }

  /// 最後に表示したIDを取得.
  Future<List<String>> getListShowId () async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    List<String> value = _preferences.getStringList(_lastShowIdKey);
    return value ?? [];
  }

  /// 最後に表示したIDを設定.
  Future setListShowId(List<String> id) async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    await _preferences.setStringList(_lastShowIdKey, id);
  }

  /// 最後の表示したIDを削除.
  Future deleteLastShowId() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    await _preferences.remove(_lastShowIdKey);
  }

  /// 最後に表示した日付を取得.
  Future<DateTime> getLastShowDate() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    String value = _preferences.getString(_lastShowDateKey);
    return value != null ? DateTime.parse(value) : DateTime.now().add(Duration(days: -30));
  }

  /// 最後に表示した日付を設定.
  Future setLastShowDate(DateTime dateTime) async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    await _preferences.setString(_lastShowDateKey, dateTime.toString());
  }

  /// 最後に表示した日付を削除.
  Future deleteLastShowDate() async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    await _preferences.remove(_lastShowDateKey);
  }

  /// データの設定.
  void setNewsEvent(List<NewsEvent> news) {
    this.newsEvent = news;
    notifyListeners();
  }

}

class NewsEvent {
  final String id;
  final String title;
  final String body;
  final DateTime dateTime;
  final String imgUrl;

  NewsEvent({this.id, this.title, this.body, this.dateTime, this.imgUrl,});

  factory NewsEvent.fromJson(Map<String, dynamic> json) {
    return NewsEvent(
      id: json["id"],
      title: json["title"],
      body: json["body"],
      dateTime: DateTime.parse(json["public_date"]),
      imgUrl: json["has_img"] == true ? json["img_url"] : "",
    );
  }
}

List<NewsEvent> getListNewsEvent(List<dynamic> jsonData) {
  List<NewsEvent> result = [];
  for (var item in jsonData) {
    try {
      result.add(NewsEvent.fromJson(item));
    } catch (e) {
      continue;
    }
  }
  return result;
}
