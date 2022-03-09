import 'package:flutter/foundation.dart';
import 'package:live812/domain/model/json_data.dart';

enum CreditResultType {
  Payment,   // 決済
  Register,  // クレジット情報登録
}

enum CreditPaymentFailedType {
  FAILED1,   // 失敗1：最初のAPIサーバアクセスで失敗
  FAILED2,   // 失敗2：決済サーバへのアクセスで失敗
  FAILED_PAYMENT_SERVER,  // 失敗：決済サーバからの返答がNG
  FAILED3,   // 失敗3：決済結果をAPIサーバに送る際に失敗
  UNKNOWN_FAILED,   // 汎用エラー、タイムアウトも含む
}

class CreditPaymentSuccess {
  // TODO: 決済に成功した場合、決済IDなどが返ってくるんだろうか？
  final JsonData apiResponse;

  CreditPaymentSuccess(this.apiResponse);
}

class CreditPaymentFailed {
  final CreditPaymentFailedType type;

  final String errorCode;  // エラーコード
  final String errorMessage;  // エラー内容
  final String creditResponseBody;  // クレジット会社APIのレスポンス（生文字列）

  CreditPaymentFailed({@required this.type, this.errorCode, this.errorMessage, this.creditResponseBody});
}
