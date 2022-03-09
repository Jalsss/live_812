import 'package:flutter/material.dart';

class OtherUserModel extends ChangeNotifier {
  dynamic _json;

  String get id => _json['id'];
  String get symbol => _json["user_id"];
  String get nickname => _json['nickname'];
  String get imgThumbUrl => _json['img_thumb_url'];
  String get imgSmallUrl => _json["img_small_url"];
  String get profile => _json['profile'];
  int get followerCount => _json['follower_count'];
  String get rank => _json['rank'];
  bool get followed => _json['followed'] == true;
  String get liveId => _json['live_id'];
  bool get isBroadcasting => _json['is_broadcasting'];
  bool get isLiver => _json["is_liver"];
  bool get blocked => _json["blocked"];
  bool get notifyLive => _json["notify_live"] == true;
  bool get notifyTimeline => _json["notify_timeline"] == true;
  bool get notifyEC => _json["notify_ec"] == true;
  bool get notify => notifyLive || notifyTimeline || notifyEC;
  DateTime _followDate;
  DateTime get followDate => _followDate ?? DateTime.now();

  OtherUserModel.fromJson(dynamic json) {
    _json = json;

    final dic = json as Map<String, dynamic>;
    if (dic.containsKey('follow_date')) {
      _followDate = DateTime.tryParse(dic['follow_date']);
    }
    _followDate ??= DateTime.now();
  }

  void setIsBroadcasting(bool value) {
    _json['is_broadcasting'] = value;
  }

  void setBlocked(bool value) {
    _json["blocked"] = value;
  }

  void setNotify(bool live, bool timeline, bool ec) {
    _json["notify_live"] = live;
    _json["notify_timeline"] = timeline;
    _json["notify_ec"] = ec;
  }
}
