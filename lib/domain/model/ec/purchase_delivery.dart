class PurchaseDelivery {
  final String itemId;
  final String deliveryName;
  final String deliveryPostalCode;
  final String deliveryAddr;
  final String deliveryBuild;
  final String deliveryPhone;
  final String trackingNum;
  final bool trackingFlag;
  final bool updateInfo;
  final bool updateBegin;
  final bool updateEnd;
  final String deliveryProviderId;
  final bool irregular;

  PurchaseDelivery(
    this.itemId, {
    this.deliveryName,
    this.deliveryPostalCode,
    this.deliveryAddr,
    this.deliveryBuild,
    this.deliveryPhone,
    this.trackingNum,
    this.trackingFlag,
    this.updateInfo,
    this.updateBegin,
    this.updateEnd,
    this.deliveryProviderId,
    this.irregular,
  });

  Map toMap() {
    var map = {
      'item_id': this.itemId,
      'delivery_name': this.deliveryName,
      'delivery_postal_code': this.deliveryPostalCode,
      'delivery_addr': this.deliveryAddr,
      'delivery_build': this.deliveryBuild,
      'delivery_phone': this.deliveryPhone,
      'tracking_num': this.trackingNum,
      'tracking_flag': this.trackingFlag,
      'update_info': this.updateInfo,
      'update_begin': this.updateBegin,
      'update_end': this.updateEnd,
      'delivery_provider_id': this.deliveryProviderId,
      'irregular': this.irregular,
    };

    map.keys.toList().forEach((key) {
      if (map[key] == null) map.remove(key);
    });

    return map;
  }
}
