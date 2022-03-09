/// ランク種別.
class RankType {
  final int id;
  final String name;
  final String url;
  final int sort;
  final String unitName;

  RankType({
    this.id,
    this.name,
    this.url,
    this.sort,
    this.unitName,
  });

  factory RankType.fromJson(Map<String, dynamic> json) => RankType(
        id: json["id"],
        name: json["name"],
        url: json["url"],
        sort: json["sort"],
        unitName: json["unit_name"],
      );
}
