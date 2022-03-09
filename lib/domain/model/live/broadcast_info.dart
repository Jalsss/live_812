// 配信情報 : postLiveRoom の結果
class BroadcastInfo {
  const BroadcastInfo({
    this.liveId,
    this.eventId,
    this.eventType,
    this.eventStartDate,
    this.eventEndDate,
    this.memberStartDate,
    this.memberEndDate,
  });

  /// 配信ID.
  final String liveId;

  /// イベントタイプ.
  final String eventType;

  /// イベントID.
  final String eventId;

  /// イベント開始時間.
  final DateTime eventStartDate;

  /// イベント終了時間.
  final DateTime eventEndDate;

  /// リレー配信開始時間.
  final DateTime memberStartDate;

  /// リレー配信終了時間.
  final DateTime memberEndDate;

  factory BroadcastInfo.fromJson(data) => BroadcastInfo(
        liveId: data['live_id'],
        eventType: data['event_type'],
        eventId: data['event_id'],
        eventStartDate: DateTime.tryParse(data['event_start_date'] ?? ''),
        eventEndDate: DateTime.tryParse(data['event_end_date'] ?? ''),
        memberStartDate: DateTime.tryParse(data['member_start_date'] ?? ''),
        memberEndDate: DateTime.tryParse(data['member_end_date'] ?? ''),
      );

  @override
  String toString() {
    return 'BroadcastInfo{liveId=$liveId}';
  }
}
