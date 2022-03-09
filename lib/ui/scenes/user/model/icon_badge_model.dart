final linkImage = 'https://asset.live812.works/badge_title/';

class IconBadge {
  String id;
  String imagePath;
  String title;
  String description;

  IconBadge({this.id, this.title, this.description, this.imagePath});

  factory IconBadge.fromJson(Map<String, dynamic> json) {
    return IconBadge(
        id: json['id'],
        imagePath: linkImage + json['id'] + '.png',
        title: json['name'],
        description: json['description']);
  }
}

List<IconBadge> getListIconBadge(List<dynamic> jsonData) {
  List<IconBadge> result = [];
  for (var item in jsonData) {
    try {
      result.add(IconBadge.fromJson(item));
    } catch (e) {
      continue;
    }
  }
  return result;
}
