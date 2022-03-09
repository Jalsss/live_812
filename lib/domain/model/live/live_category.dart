class LiveCategoryModel {
  final String id;
  final String name;
  final String imgUrl;
  final String imgThumbUrl;
  final bool isCustomType;

  factory LiveCategoryModel.fromJson(dynamic json) {
    return LiveCategoryModel(
      id: json['id'],
      name: json['name'],
      imgUrl: json['img_url'],
      imgThumbUrl: json['img_thumb_url'],
      isCustomType: false,
    );
  }

  LiveCategoryModel({
    this.id,
    this.name,
    this.imgUrl,
    this.imgThumbUrl,
    this.isCustomType = false,
  });

  String toString() {
    return 'LiveCategoryModel{id:$id, name:$name, imgUrl:$imgUrl}';
  }
}
