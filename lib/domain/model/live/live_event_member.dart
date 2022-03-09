class LiveEventMember {
  LiveEventMember({
    this.id,
    this.userId,
    this.nickname,
    this.imageUrl,
    this.isBroadcasting,
    this.liveId,
    this.liveStartDate,
    this.liveEndDate,
  });

  factory LiveEventMember.fromJson(Map<String, dynamic> json) =>
      LiveEventMember(
        id: json['account_id'] ?? '',
        userId: json['user_id'] ?? '',
        nickname: json['nickname'] ?? '',
        imageUrl: json['img_small_url'] ?? '',
        isBroadcasting: json['is_broadcasting'] ?? false,
        liveId: json['live_id'],
        liveStartDate: DateTime.tryParse(json['live_start_date'] ?? ''),
        liveEndDate: DateTime.tryParse(json['live_end_date'] ?? ''),
      );

  /// ID.
  final String id;

  /// ユーザーID.
  final String userId;

  /// 名前.
  final String nickname;

  /// 画像URL.
  final String imageUrl;

  /// 配信枠があるかどうか.
  final bool isBroadcasting;

  /// ライブID.
  final String liveId;

  /// リレーイベントの配信開始時間.
  final DateTime liveStartDate;

  /// リレーイベントの配信終了時間.
  final DateTime liveEndDate;

  /// ライブ配信中かどうか
  bool isOnAir() {
    if ((liveStartDate == null) || (liveEndDate == null)) {
      return isBroadcasting;
    }
    final now = DateTime.now();
    return now.isAfter(liveStartDate) &&
        now.isBefore(liveEndDate) &&
        isBroadcasting;
  }
}
