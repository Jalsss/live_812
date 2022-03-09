import 'package:flutter/material.dart';

class LiveModel extends ChangeNotifier {
  final int aspectRatioWidth;
  final int aspectRatioHeight;
  final String category1;
  final String category2;
  final bool isBeginner;
  final bool isEvent;
  final String tag1;
  final String tag2;

  LiveModel(
    this.aspectRatioWidth,
    this.aspectRatioHeight,
    this.category1,
    this.category2, {
    this.isBeginner = false,
    this.isEvent = false,
    this.tag1,
    this.tag2,
  });

  Map toMap() {
    var map = Map<String, dynamic>();
    map['aspect_ratio_width'] = aspectRatioWidth;
    map['aspect_ratio_height'] = aspectRatioHeight;
    map['category1'] = category1;
    map['category2'] = category2;
    map['is_beginner'] = isBeginner;
    map['is_event'] = isEvent;
    map['live_name'] = 'a0000010'; // TODO: 必須ではないので外す
    if (tag1 != null && tag1.isNotEmpty) {
      map['tag1'] = tag1;
    }
    if (tag2 != null && tag2.isNotEmpty) {
      map['tag2'] = tag2;
    }
    return map;
  }
}
