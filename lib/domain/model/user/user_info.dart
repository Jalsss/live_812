class UserInfoModel {
  final Map<String, String> body = {};

  UserInfoModel({
    String updateMail, String nickname, String pass, String updatePass, String profile,
    // 配送先
    String deliveryName, String deliveryPostalCode, String deliveryAddress,
    String deliveryBuilding, String deliveryPhone,
    String registrationId, String itemId,
    String symbol,
  }) {
    body['update_mail'] = updateMail;
    body['nickname'] = nickname;
    body['pass'] = pass;
    body['update_pass'] = updatePass;
    body['profile'] = profile;

    body['delivery_name'] = deliveryName;
    body['delivery_postal_code'] = deliveryPostalCode;
    body['delivery_addr'] = deliveryAddress;
    body['delivery_build'] = deliveryBuilding;
    body['delivery_phone'] = deliveryPhone;
    body['item_id'] = itemId;
    body['user_id'] = symbol;

    body['registration_id'] = registrationId;

    for (final key in body.keys.toList()) {
      if (body[key] == null)
        body.remove(key);
    }
  }

  Map<String, String> getMap() {
    return body;
  }
}
