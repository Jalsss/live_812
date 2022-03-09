import 'package:flutter/material.dart';
import 'package:flutter_simple_dependency_injection/injector.dart';
import 'package:live812/domain/model/json_data.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/http_status_code.dart';
import 'package:tuple/tuple.dart';

enum UpdateMyInfoResult {
  SUCCESS,
  NETWORK_ERROR,
  UNAUTHENTICATED,
}

// ユーザ情報関連のユースケース
class UserInfoUsecase {
  UserInfoUsecase._();

  // 自分の情報を取得し、更新する
  // 結果は自分の情報として、ストレージに保存する
  // 401が返った場合にも自動的にログインページに遷移はしない
  static Future<Tuple2<UpdateMyInfoResult, JsonData>> updateMyInfo(BuildContext context) async {
    final userModel = Injector.getInjector().get<UserModel>(additionalParameters: {'context': context});
    final service = BackendService(context);
    final response1 = await service.getMyRequest();
    if (response1.item1?.result != true) {
      if (response1.item2?.statusCode == HttpStatusCode.UNAUTHENTICATED)
        return Tuple2<UpdateMyInfoResult, JsonData>(UpdateMyInfoResult.UNAUTHENTICATED, response1.item1);
      return Tuple2<UpdateMyInfoResult, JsonData>(UpdateMyInfoResult.NETWORK_ERROR, response1.item1);
    }

    final onetimeToken = response1.item1.getByKey('onetime_token');
    if (onetimeToken == null)
      return Tuple2<UpdateMyInfoResult, JsonData>(UpdateMyInfoResult.NETWORK_ERROR, response1.item1);

    final response2 = await service.getMy(onetimeToken);
    if (response2 == null || !response2.result) {
      return Tuple2<UpdateMyInfoResult, JsonData>(UpdateMyInfoResult.NETWORK_ERROR, response2);
    }

    final data = response2.getData();
    userModel.readFromJson(data);
    await userModel.saveToStorage();
    return Tuple2<UpdateMyInfoResult, JsonData>(UpdateMyInfoResult.SUCCESS, response2);
  }
}
