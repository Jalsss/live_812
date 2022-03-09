import 'package:live812/domain/model/json_data.dart';

class CoinHistory {
  final int sum;
  final int paid;
  final int free;
  final int monthlyExpirePoint;
  final List<CoinHistoryEntry> entries;

  CoinHistory({
    this.sum,
    this.paid,
    this.free,
    this.monthlyExpirePoint,
    this.entries,
  });

  factory CoinHistory.fromJson(JsonData json) => CoinHistory(
    sum: json.getByKey('sum'),
    paid: json.getByKey('paid'),
    free: json.getByKey('free'),
    monthlyExpirePoint: json.getByKey('monthly_expire_point') ?? 0,
    entries: CoinHistoryEntry.fromJsonList(json.getData()),
  );

  String toString() {
    return 'CoinHistory{sum=$sum, paid=$paid, free=$free, $entries}';
  }
}

class CoinHistoryEntry {
  final int point;
  final String createDate;
  final String sender;
  final String senderId;
  final bool purchased;
  final bool isExpired;

  CoinHistoryEntry({
    this.point,
    this.createDate,
    this.sender,
    this.senderId,
    this.purchased,
    this.isExpired,
  });

  factory CoinHistoryEntry.fromJson(Map<String, dynamic> json) => CoinHistoryEntry(
        point: json["point"],
        createDate: json["create_date"],
        sender: json["sender_nickname"],
        senderId: json["sender_id"],
        purchased: json["purchased"] == true,
        isExpired: json['is_expire'] == true,
      );

  static List<CoinHistoryEntry> fromJsonList(jsonList) {
    return jsonList
        .map<CoinHistoryEntry>((obj) => CoinHistoryEntry.fromJson(obj))
        .toList();
  }

  String toString() {
    return 'CoinHistoryEntry{point=$point, createDate=$createDate, sender=$sender, senderId=$senderId, purchased=$purchased, isExpired=$isExpired}';
  }
}
