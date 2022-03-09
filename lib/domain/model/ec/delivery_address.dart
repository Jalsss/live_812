// 配送先
class DeliveryAddress {
  final int id;
  final String name;  // 氏名
  final String post1;
  final String post2;
  final String address;
  final String building;
  final String phone;

  DeliveryAddress({
    this.id,
    this.name, this.post1, this.post2,
    this.address, this.building, this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'delivery_name': name,
      'delivery_postal_code': '$post1-$post2',
      'delivery_addr': address,
      'delivery_build': building,
      'delivery_phone': phone,
    };
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    var postalCodeArray = json["postal_code"].toString();
    var postalCode = postalCodeArray.split("-");
    return DeliveryAddress(
      id: int.parse(json["id"]),
      name: json["name"],
      post1: postalCode[0],
      post2: postalCode[1],
      address: json["addr"],
      building: json["build"],
      phone: json["phone"],
    );
  }

  String toString() {
    return 'DeliveryAddress{id=$id, name=$name, postalCode=$post1-$post2, address=$address, building=$building, phone=$phone}';
  }
}
