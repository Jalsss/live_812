// 永続化データを扱うリポジトリ

import 'package:live812/domain/model/ec/delivery_address.dart';
import 'package:live812/domain/model/iap/iap_info.dart';
import 'package:live812/domain/model/user/notice.dart';

abstract class PersistentRepository {
  // お知らせ保存
  Future<void> insertNotice(NoticeModel notice);

  // お知らせが既読か？ null=>項目がない、false=>未読、true=>既読
  Future<bool> isNoticeRead(String id);

  // お知らせ既読をセット
  Future<void> setNoticeRead(String id, bool value);

  // 課金情報を保存：戻り値＝ID
  Future<int> insertIapInfo(IapInfo iapInfo);

  // 課金情報を取得
  Future<IapInfo> getIapInfo(int id);

  // 処理中の課金情報のidリストを取得
  Future<List<int>> getPendingIapIdList();

  // 課金情報のステートを登録済みにする
  Future<bool> updateIapInfoRegistered(int id);

  // 課金情報のステートを失敗にする
  Future<bool> updateIapInfoFailed(int id);

  // 配送先住所情報取得
  Future<List<DeliveryAddress>> getDeliveryAddressList();

  // 配送先住所追加（または更新）
  Future<int> putDeliveryAddress(DeliveryAddress deliveryAddress);

  // 配送先住所削除
  Future<bool> deleteDeliveryAddress(int id);
}
