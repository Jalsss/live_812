import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:live812/domain/model/json_data.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/result.dart';

class NetworkService {
  NetworkService._();

  static Future<Result<JsonData, http.Response>> loadJson(String url) async {
    try {
      final response = await http.get(url).timeout(Duration(seconds: Consts.TIME_OUT));
      if (response.statusCode != 200)
        return Err(response);

      final json = JsonData(utf8.decode(response.bodyBytes));
      return Ok(json);
    } on SocketException {
      return Err(null);
    } on TimeoutException {
      return Err(null);
    }
  }
}
