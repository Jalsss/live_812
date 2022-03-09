class RoomInfoModel {
  final dynamic json;

  String get id => json['id'];
  String get liveId => json['live_id'];
  String get liverId => json['liver_id'];
  String get liveName => json['live_name'];
  String get nickname => json['nickname'];
  String get description => json['description'];
  int get personCount => json['person_count'];
  int get likeCount => json['like_count'];
  int get point => json['point'];
  String get imgUrl => json['img_url'];
  String get tag1 => json['tag1'] ?? '';
  String get tag2 => json['tag2'] ?? '';
  bool get isPortrait => json['is_landscape'] != true;
  bool get broadcasting => json['broadcasting'];
  String get eventId => json['event_id'];
  String get eventType => json['event_type'];
  DateTime get liveStartDate => DateTime.tryParse(json['live_start_date'] ?? '');
  DateTime get liveEndDate => DateTime.tryParse(json['live_end_date'] ?? '');

  RoomInfoModel.fromJson(this.json);

  /// 配信しているかどうか.
  bool isOnAir() {
    final startDate = liveStartDate;
    final endDate = liveEndDate;
    if ((startDate == null) || (endDate == null)) {
      return true;
    }
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  String toString() {
    return 'RoomInfoModel{liveId:$liveId, liverId:$liverId, liveName:$liveName, broadcasting:$broadcasting, nickname:$nickname, imgUrl:$imgUrl, tag1:$tag1, tag2:$tag2}';
  }
}
