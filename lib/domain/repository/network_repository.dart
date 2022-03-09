import 'dart:convert';

import 'package:http/http.dart' as http;

enum Method {
  GET,
  POST,
  PUT,
  DELETE,
}

abstract class NetworkRepository {
  Future<http.Response> sendRequest(
      Method method, String api,
      {
        Map<String, String> headers, Map<String, dynamic> query, Map body, Encoding encoding,
        bool isJson, int timeOut,
      });
}
