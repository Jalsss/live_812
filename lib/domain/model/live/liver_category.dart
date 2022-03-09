class LiverCategoryModel {
  const LiverCategoryModel({
    this.id,
    this.name,
    this.isForced,
  });

  factory LiverCategoryModel.fromJson(Map<String, dynamic> json) =>
      LiverCategoryModel(
        id: json['id'].toString(),
        name: json['name'],
        isForced: json['is_forced'] ?? false,
      );

  final String id;
  final String name;
  final bool isForced;

  @override
  String toString() {
    return 'id=$id, name=$name, isForced=$isForced';
  }
}
