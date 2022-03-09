// Sqlite を使用した PersistentRepositoryの実体

import 'dart:io';

import 'package:live812/domain/model/ec/delivery_address.dart';
import 'package:live812/domain/model/iap/iap_info.dart';
import 'package:live812/domain/model/user/notice.dart';
import 'package:live812/domain/repository/persistent_repository.dart';
import 'package:mutex/mutex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// バージョン：テーブル内容に変更がある場合には増やしていく
const int _DB_VERSION = 6;

const String _DB_FILENAME = 'persistent.db';

// お知らせテーブル
const String _CREATE_NOTICE_TABLE =
  'CREATE TABLE notices(' +
  '  id TEXT PRIMARY KEY,' +         // ID
  '  title TEXT,' +                  // タイトル
  '  content TEXT,' +                // 内容
  '  create_date INTEGER,' +         // 日付（エポックタイム）
  '  has_eyecatch INTEGER,' +        // ?
  '  status INTEGER,' +              // ?
  '  public_date INTEGER,' +         // ?（エポックタイム）
  '  img_url TEXT,' +                // 画像
  '  read INTEGER' +                 // 0=未読、1=既読
  ')';

// アプリ内課金テーブル
const String _CREATE_IAP_INFO_TABLE =
    'CREATE TABLE iap_infos(' +
    '  id INTEGER PRIMARY KEY,' +          // ID (AUTOINCREMENT)
    '  productId TEXT,' +                  // 商品ID
    '  transactionId TEXT,' +              //
    '  transactionReceipt TEXT,' +         //
    '  purchaseToken TEXT,' +              //
    '  orderId TEXT,' +                    //
    '  purchaseStateAndroid INTEGER,' +    //
    '  developerPayloadAndroid TEXT,' +    //
    '  originalJsonAndroid TEXT,' +        //
    '  signatureAndroid TEXT,' +           //
    '  price TEXT,' +                      //
    '  currency TEXT,' +                   //
    '  coin INTEGER,' +                    // コイン数
    '  state INTEGER,' +                   // 状態（1=購入済み、2=APIサーバに登録済み）
    '  createdAt TIMESTAMP DEFAULT (datetime(CURRENT_TIMESTAMP))' +  // 日付（エポックタイム）
    ')';

// 配送先住所テーブル
const String _TABLE_DELIVERY_ADDRESS = 'delivery_addresses';
const String _CREATE_DELIVERY_ADDRESS_TABLE =
    'CREATE TABLE $_TABLE_DELIVERY_ADDRESS (' +
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,' + // ID
        '  name TEXT,' +                  // 氏名
        '  post1 TEXT,' +                 // 郵便番号１
        '  post2 TEXT,' +                 // 郵便番号２
        '  address TEXT,' +               // 住所
        '  building TEXT,' +              // ビル名
        '  phone TEXT' +                  // 電話番号
        ')';

// お知らせテーブルをリネーム
const String _ALTER_NOTICE_TABLE =
    'ALTER TABLE notifications RENAME TO notices';

// アプリ内課金テーブルにコイン数のカラムを追加
const String _ALTER_IAP_INFO_TABLE_ADD_COIN =
    'ALTER TABLE iap_infos ADD COLUMN coin INTEGER';

// アプリ内課金テーブルにsignatureAndroidのカラムを追加
const String _ALTER_IAP_INFO_TABLE_ADD_SIGNATURE_ANDROID =
    'ALTER TABLE iap_infos ADD COLUMN signatureAndroid TEXT';

class SqlitePersistentRepository implements PersistentRepository {
  Database _db;
  final _mutex = Mutex();

  Future<Database> _setUpDb() async {
    await _mutex.acquire();
    try {
      if (_db == null) {
        final path = await _getDbPath();
        _db = await openDatabase(
          path,
          version: _DB_VERSION,
          onCreate: (Database newDb, int version) async {
            await newDb.transaction((txn) async {
              await txn.execute(_CREATE_NOTICE_TABLE);
              await txn.execute(_CREATE_IAP_INFO_TABLE);
              await txn.execute(_CREATE_DELIVERY_ADDRESS_TABLE);
              return true;
            });
          },
          onUpgrade: (Database db, int oldVersion, int newVersion) async {
            await db.transaction((txn) async {
              for (int v = oldVersion; ++v <= newVersion; ) {
                try {
                  switch (v) {
                    case 2:
                      await txn.execute(_ALTER_NOTICE_TABLE);
                      break;
                    case 3:
                      await txn.execute(_CREATE_IAP_INFO_TABLE);
                      break;
                    case 4:
                      await txn.execute(_ALTER_IAP_INFO_TABLE_ADD_COIN);
                      break;
                    case 5:
                      await txn.execute(_ALTER_IAP_INFO_TABLE_ADD_SIGNATURE_ANDROID);
                      break;
                    case 6:
                      await txn.execute(_CREATE_DELIVERY_ADDRESS_TABLE);
                      break;
                  }
                } catch (e) {
                  print('DB upgrade to version $v failed: ${e?.toString()}');
                }
              }
            });
          },
        );
      }
    } finally {
      _mutex.release();
    }
    return _db;
  }

  Future<String> _getDbPath() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    return join(documentDirectory.path, _DB_FILENAME);
  }

  @override
  Future<void> insertNotice(NoticeModel notice) async {
    final db = await _setUpDb();
    await db.execute(
        'INSERT INTO notices VALUES (?,?,?,?,?,?,?,?,?)',
        [
          notice.id, notice.title, notice.content,
          toEpochTime(notice.createDate),
          notice.hasEyeCatch == true ? 1 : 0,
          notice.status,
          toEpochTime(notice.publicDate),
          notice.imageUrl,
          notice.read,
        ]);
  }

  @override
  Future<bool> isNoticeRead(String id) async {
    final db = await _setUpDb();
    final result = await db.rawQuery('SELECT read from notices where id=? limit 1', [id]);
    return result.isNotEmpty != true ? null : result[0]['read'] != 0;
  }

  // お知らせ既読をセット
  @override
  Future<void> setNoticeRead(String id, bool value) async {
    final db = await _setUpDb();
    final v = value ? 1 : 0;
    await db.execute('UPDATE notices SET read=? WHERE id=?', [v, id]);
  }

  // 課金情報を保存：戻り値＝ID
  @override
  Future<int> insertIapInfo(IapInfo iapInfo) async {
    final db = await _setUpDb();
    final result = await db.insert('iap_infos', {
      'productId': iapInfo.productId,
      'transactionId': iapInfo.transactionId,
      'transactionReceipt': iapInfo.transactionReceipt,
      'purchaseToken': iapInfo.purchaseToken,
      'orderId': iapInfo.orderId,
      'purchaseStateAndroid': iapInfo.purchaseStateAndroid,
      'developerPayloadAndroid': iapInfo.developerPayloadAndroid,
      'originalJsonAndroid': iapInfo.originalJsonAndroid,
      'signatureAndroid': iapInfo.signatureAndroid,
      'price': iapInfo.price,
      'currency': iapInfo.currency,
      'state': iapInfo.state,
      'coin': iapInfo.coin,
    });
    return result;
  }

  // 課金情報を取得
  @override
  Future<IapInfo> getIapInfo(int id) async {
    final db = await _setUpDb();
    final result = await db.rawQuery('SELECT * from iap_infos where id=? limit 1', [id]);
    if (result?.isNotEmpty != true)
      return null;
    return _convertToIapInfo(result[0]);
  }

  static IapInfo _convertToIapInfo(Map<String, dynamic> row) {
    try {
      return IapInfo(
        productId: row['productId'],
        transactionId: row['transactionId']?.toString(),
        transactionReceipt: row['transactionReceipt'],
        purchaseToken: row['purchaseToken'],
        orderId: row['orderId'],
        purchaseStateAndroid: row['purchaseStateAndroid'],
        developerPayloadAndroid: row['developerPayloadAndroid'],
        originalJsonAndroid: row['originalJsonAndroid'],
        signatureAndroid: row['signatureAndroid'],
        price: row['price'].toString(),
        currency: row['currency'],
        coin: row['coin'],
        id: row['id'],
        state: row['state'],
        createdAt: DateTime.parse(row['createdAt']),
      );
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  // 処理中の課金情報のidリストを取得
  @override
  Future<List<int>> getPendingIapIdList() async {
    final db = await _setUpDb();
    final result = await db.rawQuery('SELECT id from iap_infos where state=? order by id', [IapInfo.PURCHASED]);
    if (result?.isNotEmpty != true)
      return null;
    try {
      return List.generate(result.length, (index) => result[index]['id']);
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  // 課金情報のステートを登録済みにする
  @override
  Future<bool> updateIapInfoRegistered(int id) async {
    final db = await _setUpDb();
    final result = await db.rawUpdate('UPDATE iap_infos SET state=?,transactionReceipt=?,originalJsonAndroid=?,signatureAndroid=? WHERE id=?', [IapInfo.REGISTERED, null, null, null, id]);
    return result == 1;
  }

  // 課金情報のステートを失敗にする
  @override
  Future<bool> updateIapInfoFailed(int id) async {
    final db = await _setUpDb();
    final result = await db.rawUpdate('UPDATE iap_infos SET state=? WHERE id=?', [IapInfo.FAILED, id]);
    return result == 1;
  }

  // 処理中の課金情報のidリストを取得
  @override
  Future<List<DeliveryAddress>> getDeliveryAddressList() async {
    final db = await _setUpDb();
    final result = await db.rawQuery('SELECT * from delivery_addresses order by id');
    if (result?.isNotEmpty != true)
      return null;
    try {
      return List.generate(result.length, (index) => DeliveryAddress(
        id: result[index]['id'],
        name: result[index]['name']?.toString(),
        post1: result[index]['post1']?.toString(),
        post2: result[index]['post2']?.toString(),
        address: result[index]['address']?.toString(),
        building: result[index]['building']?.toString(),
        phone: result[index]['phone']?.toString(),
      ));
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  // 配送先住所追加（または更新）
  @override
  Future<int> putDeliveryAddress(DeliveryAddress deliveryAddress) async {
    final db = await _setUpDb();

    if (deliveryAddress.id == null) {
      /*final result =*/ await db.insert(_TABLE_DELIVERY_ADDRESS, {
        'name': deliveryAddress.name,
        'post1': deliveryAddress.post1,
        'post2': deliveryAddress.post2,
        'address': deliveryAddress.address,
        'building': deliveryAddress.building,
        'phone': deliveryAddress.phone,
      });
      // 挿入したRowのidを読み出す。
      final result2 = await db.rawQuery('SELECT id from "$_TABLE_DELIVERY_ADDRESS" where rowid=last_insert_rowid() limit 1;');
      return result2?.isNotEmpty == true ? result2.first['id'] : null;
    } else {
      final result = await db.update(
        _TABLE_DELIVERY_ADDRESS,
        {
          'name': deliveryAddress.name,
          'post1': deliveryAddress.post1,
          'post2': deliveryAddress.post2,
          'address': deliveryAddress.address,
          'building': deliveryAddress.building,
          'phone': deliveryAddress.phone,
        },
        where: 'id=?',
        whereArgs: [deliveryAddress.id],
      );
      return result != null && result > 0 ? deliveryAddress.id  : null;
    }
  }

  // 配送先住所削除
  Future<bool> deleteDeliveryAddress(int id) async {
    final db = await _setUpDb();
    final result = await db.delete(
      _TABLE_DELIVERY_ADDRESS,
      where: 'id=?',
      whereArgs: [id],
    );
    return result != null && result > 0;
  }
}

int toEpochTime(DateTime t) {
  return (t.millisecondsSinceEpoch / 1000).floor();
}
