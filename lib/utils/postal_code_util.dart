import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:live812/utils/consts/consts.dart';

class PostalCodeUtil {
  static String _url = "https://zipcloud.ibsnet.co.jp/api/search";

  /// 郵便番号検索APIの通信処理.
  static Future<http.Response> _sendRequest({
    @required String zipcode,
    int limit = 1,
  }) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    final url = "$_url?zipcode=$zipcode&limit=$limit";
    try {
      return await http
          .get(url, headers: headers)
          .timeout(Duration(seconds: Consts.TIME_OUT));
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// 郵便番号から住所を取得.
  static Future<PostalCodeResult> getAddress(String zipcode) async {
    final response = await _sendRequest(zipcode: zipcode);
    if ((response == null) || (response?.statusCode != 200)) {
      // エラー.
      return null;
    }
    final postalCodeResponse =
        PostalCodeResponse.fromJson(json.decode(response.body));
    if (postalCodeResponse.status != 200) {
      print(postalCodeResponse.toString());
      return null;
    }
    if ((postalCodeResponse.results == null) ||
        (postalCodeResponse.results.length <= 0)) {
      return null;
    }
    return postalCodeResponse.results[0];
  }
}

class PostalCodeResponse {
  /// ステータス(正常時は 200、エラー発生時にはエラーコードが返される).
  final int status;

  /// メッセージ(エラー発生時に、エラーの内容が返される).
  final String message;

  /// 検索結果.
  final List<PostalCodeResult> results;

  PostalCodeResponse({this.status, this.message, this.results});

  factory PostalCodeResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic> results = json["results"];
    if ((results != null) && (results.length > 0)) {
      return PostalCodeResponse(
        status: json["status"],
        message: json["message"],
        results: results.map((e) => PostalCodeResult.fromJson(e)).toList(),
      );
    } else {
      return PostalCodeResponse(
        status: json["status"],
        message: json["message"],
        results: null,
      );
    }
  }

  @override
  String toString() {
    return "[PostalCodeResponse]status:$status, message:$message";
  }
}

class PostalCodeResult {
  /// 郵便番号7桁の郵便番号(ハイフンなし).
  final String zipcode;

  ///   都道府県コード(JIS X 0401 に定められた2桁の都道府県コード).
  final String prefcode;

  /// 都道府県名.
  final String address1;

  /// 市区町村名.
  final String address2;

  /// 町域名.
  final String address3;

  /// 都道府県名カナ.
  final String kana1;

  /// 市区町村名カナ.
  final String kana2;

  /// 町域名カナ.
  final String kana3;

  PostalCodeResult({
    this.zipcode,
    this.prefcode,
    this.address1,
    this.address2,
    this.address3,
    this.kana1,
    this.kana2,
    this.kana3,
  });

  factory PostalCodeResult.fromJson(Map<String, dynamic> json) {
    return PostalCodeResult(
      zipcode: json["zipcode"],
      prefcode: json["prefcode"],
      address1: json["address1"],
      address2: json["address2"],
      address3: json["address3"],
      kana1: json["kana1"],
      kana2: json["kana3"],
      kana3: json["kana3"],
    );
  }
}
