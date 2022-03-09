import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:live812/domain/model/ec/credit_payment_result.dart';
import 'package:live812/domain/model/ec/delivery_address.dart';
import 'package:live812/domain/model/ec/product.dart';
import 'package:live812/domain/model/ec/product_template.dart';
import 'package:live812/domain/model/user/user.dart';
import 'package:live812/domain/services/BackendService.dart';
import 'package:live812/utils/consts/ColorLive.dart';
import 'package:live812/utils/consts/consts.dart';
import 'package:live812/utils/consts/language.dart';
import 'package:live812/utils/image_util.dart';
import 'package:live812/utils/result.dart';
import 'package:tuple/tuple.dart';

class ProductUsecase {
  ProductUsecase._();

  // 戻り値：null=成功、non null=エラーメッセージ
  static Future<String> requestPost(
    String name,
    String desc,
    int price,
    int shipping, {
    @required UserModel userModel,
    @required BackendService backendService,
    String itemId, // 編集の場合：商品ID
    List<dynamic>
        images, // 画像（アップロード済みのものは url: String、新規にアップロードするものは file: File）
    @required List<int> uploadedImageIndices, // サーバにアップロード済みの画像のインデクス
    @required List<int> keepImageIndices, // 保持するインデクス
    @required List<int> deleteImageIndices, // 削除するインデクス
    bool isRelease = true,
    String customerUserId,
  }) async {
    if (price == null) return Future.value('値段異常');

    // 新規にアップロードする画像を構築する
    final newUploadImages = Map<int, File>();
    int index = -1;
    for (int i = 0; i < images.length; ++i) {
      if (keepImageIndices == null || i >= keepImageIndices.length) {
        assert(images[i] is File);
        // 次のインデクスを探す
        for (;;) {
          ++index;
          if (keepImageIndices == null ||
              keepImageIndices.indexWhere((i) => uploadedImageIndices[i] == index) < 0)
            break;
        }
        newUploadImages[index] = images[i];
      }
    }
    // 削除する画像のインデクス
    List<int> deleteImages;
    if (deleteImageIndices != null) {
      deleteImages = deleteImageIndices.map((index) {
        return uploadedImageIndices[index];
      }).toList();
      // アップロードする画像は削除対象から外す
      newUploadImages.keys.forEach((index) => deleteImages.remove(index));
    }

    Map<int, String> base64Images = await _shrinkEncodeImages(newUploadImages);

    final response = await backendService.postEcItem(
      userModel.symbol,
      name: name,
      memo: desc,
      price: price,
      shipping: shipping,
      enabledFlag: true,
      itemId: itemId,
      base64Images: base64Images,
      deleteImageIndices: deleteImages,
      isRelease: isRelease,
      customerUserId: customerUserId,
    );
    if (response?.result == true)
      return null;
    else
      return response.getByKey('msg') ?? '';
  }

  // 画像を縮小、Base64エンコード
  static Future<Map<int, String>> _shrinkEncodeImages(Map<int, File> images) async {
    if (images.length <= 0)
      return Future.value(null);

    final converted = await Future.wait(images.keys.map((index) async {
      final imageFile = images[index];
      final resizedImage = await ImageUtil.shrinkIfNeeded(imageFile, Consts.PRODUCT_IMAGE_WIDTH);
      return Future.value(Tuple2<int, String>(index, ImageUtil.toBase64DataImage(resizedImage)));
    }));

    final stringImages = Map<int, String>();
    converted.forEach((tuple) {
      stringImages[tuple.item1] = tuple.item2;
    });

    return stringImages;
  }

  // 商品削除の確認ダイアログ
  static Future<bool> confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('削除しますか？'),
          content: Text('この商品を削除しますか？削除した商品は取り消しできません。'),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) == true;
  }

  /// 商品を非表示の確認ダイアログ.
  static Future<bool> confirmHide(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('非表示にしますか？'),
          content: Text('この商品を非表示にしますか？\n非表示にした商品は取り消しできません。'),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) == true;
  }

  // クレジットカード決済
  static Future<Result<CreditPaymentSuccess, CreditPaymentFailed>> requestCreditBilling({
    @required String cardNumber, @required String expireDate, @required String securityCode,
    @required String productId,
    @required DeliveryAddress deliveryAddress,
    @required UserModel userModel, @required BackendService backendService,
  }) async {
    final now = DateTime.now();
    // API呼び出し
    final response = await backendService.postCreditBilling(
        productId,
        now,
        deliveryAddress: deliveryAddress);
    if (response?.result != true) {
      return Future.value(Err(CreditPaymentFailed(
        type: CreditPaymentFailedType.FAILED1,
        errorCode: '-11',
        errorMessage: response?.getByKey('msg') ?? 'Cannot reach server',
      )));
    }

    final data = response.getData();
    final post = data['post'] as String;
    final url = data['url'] as String;
    final authId = data['auth_id'] as String;
    final authPassword = data['auth_pass'] as String;
    final hashKey = data['hash'] as String;
    final contentType = data['content_type'] as String;
    if (post == null || url == null || authId == null || hashKey == null || contentType == null || authPassword == null) {
      // 必要な情報がない
      return Future.value(Err(CreditPaymentFailed(
        type: CreditPaymentFailedType.FAILED1,
        errorMessage: 'Illegal server response',
      )));
    }

    final map = {
      'CC_NUMBER': cardNumber,
      'CC_EXPIRATION': expireDate,
      'SECURITY_CODE': securityCode,
    };

    // 1. レスポンス内に含まれる{{CC_NUMBER}}、{{CC_EXPIRATION}}、{{SECURITY_CODE}}にそれぞれ、カード番号、カード期限(YYYYMM)、セキュリティコードの文字列を置き換えてください
    final modifiedPost = post.replaceAllMapped(RegExp(r'{{(CC_NUMBER|CC_EXPIRATION|SECURITY_CODE)}}'), (m) {
      return map[m.group(1)] ?? '';
    });
    final modifiedHash = hashKey.replaceAllMapped(RegExp(r'{{(CC_NUMBER|CC_EXPIRATION|SECURITY_CODE)}}'), (m) {
      return map[m.group(1)] ?? '';
    });

    // 2. hashをsha1でハッシュ計算したものを{{HASH}}の場所に置き換えてください
    var digest = sha1.convert(utf8.encode(modifiedHash));
    final modifiedPost2 = String.fromCharCodes(utf8.encode(modifiedPost)).replaceFirst('{{HASH}}', digest.toString());

    // 3. URLに対してpostをPOSTしてください。このときヘッダーにContent-TypeとBasicAuth（id:auth_id、pass:2のhash）の指定をしてください。
//    String creditResponseBody;
//    xml.XmlDocument creditDoc;
//    try {
//      final basicAuth = 'Basic ' + base64Encode(utf8.encode('$authId:$authPassword'));
//
//      final headers = {'Content-Type': contentType, HttpHeaders.authorizationHeader: basicAuth};
//      final creditResponse = await http.post(url, body: modifiedPost2, headers: headers).timeout(Duration(seconds: BackendService.TIME_OUT));
//      creditResponseBody = creditResponse?.body;
//      creditDoc = xml.parse(creditResponseBody);
//    } on SocketException catch(e) {
//      print('${e.message}');
//      return Future.value(Err(CreditPaymentFailed(
//        type: CreditPaymentFailedType.FAILED2,
//        errorMessage: 'SocketException: $e',
//      )));
//    } on TimeoutException catch(e) {
//      return Future.value(Err(CreditPaymentFailed(
//        type: CreditPaymentFailedType.FAILED2,
//        errorMessage: 'Timeout payment server: $e',
//      )));
//    }
//
//    // TODO: この時点でクレジット決済が済んでいるのを、本体に保存し
//    // 以降のAPIサーバへの登録に失敗した場合にリトライできるようにする

    // 4. 結果を/credit/resultにPOSTしてください。
    final response3 = await backendService.postCreditResult(
        CreditResultType.Payment,
        modifiedPost2,
        productId);

    if (response3?.result != true) {
      return Future.value(Err(CreditPaymentFailed(
        type: CreditPaymentFailedType.FAILED3,
        errorMessage: response3?.getByKey('msg') ?? 'Unknown error',
        //creditResponseBody: creditResponseBody,
      )));
    }

//    final creditResponse = creditDoc.rootElement;
//    final resResult = _getElementInnerText(creditResponse?.findElements('res_result')?.first);
//
//    if (resResult != 'OK') {
//      final resErrCode = _getElementInnerText(creditResponse?.findElements('res_err_code')?.first);
//      final resDate = _getElementInnerText(creditResponse?.findElements('res_date')?.first);
//      return Future.value(Err(CreditPaymentFailed(
//        type: CreditPaymentFailedType.FAILED_PAYMENT_SERVER,
//        errorCode: resErrCode,
//        errorMessage: 'date=$resDate',
//        creditResponseBody: creditResponseBody,
//      )));
//    } else {
//      return Future.value(Ok(CreditPaymentSuccess(
//        response3,
//      )));
//    }

    return Future.value(Ok(CreditPaymentSuccess(
      response3,
    )));
  }

  //static String _getElementInnerText(xml.XmlElement element) {
  //  return element?.children?.first?.toString();
  //}

  /// 販売済みの商品の表示を消す.
  static Future<bool> requestEcItemInvisiblePurchased({
    @required BackendService service,
    @required List<String> itemIds,
  }) async {
    final response =
        await service.postEcItemInvisiblePurchased(itemIds: itemIds);
    return response?.result ?? false;
  }

  /// テンプレートを取得.
  static Future<List<ProductTemplate>> requestTemplate(
    BuildContext context,
  ) async {
    final service = BackendService(context);
    final response = await service.getEcTemplate();
    if (!(response?.result ?? false)) {
      return [];
    }
    List dataList = response.getData();
    List<ProductTemplate> list = [];
    for (int i = 0; i < dataList.length; i++) {
      list.add(ProductTemplate.fromJson(dataList[i]));
    }
    return list;
  }

  /// テンプレートダイアログの表示.
  static Future<int> showTemplateDialog(
    BuildContext context,
    List<ProductTemplate> templates,
  ) async {
    // テンプレートなし.
    if ((templates == null) || (templates.length == 0)) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(Lang.TEMPLATES),
            content: const Text("テンプレートがありません"),
          );
        },
      );
      return null;
    }
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(Lang.TEMPLATES),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "※テンプレート名を基準に昇順で表示されます",
                  style: TextStyle(
                    color: ColorLive.RED,
                    fontSize: 14,
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context, template?.id ?? 0);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('・'),
                              Expanded(
                                child: Container(
                                  child: Text(
                                    '${template?.name ?? ''}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(color: ColorLive.BORDER2);
                    },
                    itemCount: templates?.length ?? 0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// テンプレート商品の作成.
  static Future<Product> createTemplateProduct(
    BuildContext context,
    int id,
  ) async {
    final service = BackendService(context);
    final response = await service.postEcItemFromTemplate(id: id);
    if (!(response?.result ?? false)) {
      String message = response.containsKey("msg")
          ? response?.getByKey("msg")
          : Lang.ERROR_NETWORK_FAILED_TRY_AGAIN_AFTER;
      // エラー.
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(Lang.ERROR),
            content: Text(message),
          );
        },
      );
      return null;
    }
    if (response?.getData() == null) {
      return null;
    }
    return Product.fromJson(response?.getData());
  }

}
