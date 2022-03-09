class GiftInfoModel {
  GiftInfoModel({
    this.id,
    this.name,
    this.point,
    this.isNew,
    this.onlySpecialAccount,
    this.fileName,
    this.md5,
    this.size,
  });

  factory GiftInfoModel.fromJson(Map<String, dynamic> json) => GiftInfoModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        point: json['point'] ?? 0,
        isNew: json['is_new'] ?? false,
        onlySpecialAccount: json['only_special_account'] ?? false,
        fileName: json['file_name'] ?? '',
        md5: json['md5'] ?? '',
        size: json['size'] ?? 0,
      );

  final int id;
  final String name;
  final int point;
  final bool isNew;
  final bool onlySpecialAccount;
  final String fileName;
  final String md5;
  final int size;

  /// 画像用のID.
  int get imageId => id % 3000;

  String toString() {
    return 'GiftInfoModel{id:$id, name:$name, point:$point, isNew:$isNew, only_special_account:$onlySpecialAccount}';
  }
}
