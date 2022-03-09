import 'dart:convert';

class JsonData {
  final Map<String, dynamic> _json;
  JsonData(String jsonStr) : _json = jsonDecode(jsonStr);
  JsonData.fromData(dynamic jsonObj) : _json = jsonObj['data'];
  JsonData.fromMap(Map<String, dynamic> jsonObj) : _json = jsonObj;

  bool get result => _json['result'];
  JsonData get data => JsonData.fromData(_json);

  dynamic getData() => _json['data'];
  dynamic getByKey(String key) => _json[key];
  dynamic containsKey(String key) => _json.containsKey(key);

  @override
  String toString() {
    return this._json.toString();
  }
}
