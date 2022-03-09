import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:http/http.dart' as http;

import 'package:live812/domain/repository/network_repository.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:package_info/package_info.dart';

class HttpNetworkRepository implements NetworkRepository {
  static String get _domain => Injector.getInjector().get<String>(key: Consts.KEY_DOMAIN);
  static String get _apiUrl => "https://$_domain";

  static String _appVerCached;
  static Future<String> get _appVer async {
    if (_appVerCached == null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appVerCached = packageInfo.version;
    }
    return _appVerCached;
  }

  static Uri _constructApiUri(
      String api, Map<String, dynamic> queryParameters) {
    return Uri.https(_domain, api, _toStrMap(queryParameters));
  }

  // 文字列Mapに変換、その際に値がnullの要素は取り除く
  static Map<String, String>_toStrMap(Map<String, dynamic> map) {
    if (map == null)
      return null;

    Map<String, String> strMap = {};
    for (final key in map.keys) {
      if (map[key] == null)
        continue;
      strMap[key] = map[key].toString();
    }
    return strMap;
  }

  @override
  Future<http.Response> sendRequest(Method method, String api, {Map<String, String> headers, Map<String, dynamic> query, Map body, Encoding encoding, bool isJson, int timeOut = Consts.TIME_OUT}) async {
    var os;
    if (Platform.isIOS) {
      os = 'ios';
    } else if (Platform.isAndroid) {
      os = 'android';
    } else {
      os = 'unknown';
    }

    if (method == Method.GET || method == Method.DELETE) {
      if (query == null)
        query = {};
      if (!query.containsKey('os'))
        query['os'] = os;
      if (!query.containsKey('app_version'))
        query['app_version'] = await _appVer;
    } else {
      if (body == null)
        body = {};
      if (!body.containsKey('os'))
        body['os'] = os;
      if (!body.containsKey('app_version'))
        body['app_version'] = await _appVer;
    }

    dynamic url;
    if (query == null) {
      url = _apiUrl + api;
    } else {
      url = _constructApiUri(api, query);
    }

    dynamic sendBody = body;
    if (isJson == true) {
      if (headers == null)
        headers = {};
      headers['Content-type'] = 'application/json';
      if (body != null)
        sendBody = json.encode(body);
    }

    try {
      http.Response response;
      switch (method) {
        case Method.GET:
          response = await http.get(url, headers: headers).timeout(Duration(seconds: timeOut));
          break;
        case Method.POST:
          response = await http.post(url, headers: headers, body: sendBody, encoding: encoding).timeout(Duration(seconds: timeOut));
          break;
        case Method.PUT:
          response = await http.put(url, headers: headers, body: sendBody, encoding: encoding).timeout(Duration(seconds: timeOut));
          break;
        case Method.DELETE:
          response = await http.delete(url, headers: headers).timeout(Duration(seconds: timeOut));
          break;
      }
      return response;
    } on SocketException catch(e) {
      print('SocketException: ${e.message}');
      return http.Response('{"result":false, "msg": "${e.message}", "_exception": "SocketException"}', 499);
    } on TimeoutException catch(e) {
      print('TimeoutException $e.message');
      return http.Response('{"result":false, "msg": Lang.ERROR_NETWORK_TIME_OUT, "_exception": "TimeoutException"}', 408);
    }
  }
}
