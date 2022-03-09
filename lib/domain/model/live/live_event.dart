class LiveEventStatus {
  LiveEventStatus._();

  /// 下書き.
  static const int draft = 1;

  /// 審査待ち.
  static const int waitingForReview = 2;

  /// 参加者募集中.
  static const int wanted = 3;

  /// 確定(実施前).
  static const int confirm = 4;

  /// 開催中.
  static const int inProgress = 5;

  /// 完了.
  static const int completed = 10;

  /// 却下.
  static const int rejected = -99;
}

class LiveEventType {
  LiveEventType._();

  /// 通常イベント.
  static const String none = 'none';

  /// ランキングイベント.
  static const String ranking = 'ranking';

  /// リレーイベント.
  static const String relay = 'relay';
}

class LiveEvent {
  LiveEvent({
    this.id,
    this.status,
    this.eventType,
    this.name,
    this.description,
    this.guideline,
    this.category,
    this.imageUrl,
    this.ownerAccountId,
    this.ownerUserId,
    this.ownerNickname,
    this.ownerImageUrl,
    this.startDate,
    this.endDate,
    this.requestLimitDate,
    this.isRanking,
    this.isLiverPrize,
    this.isListenerPrize,
    this.isJoined,
    this.isFollowed,
    this.inviteOnly,
  });

  factory LiveEvent.fromJson(Map<String, dynamic> json) => LiveEvent(
        id: json['id'],
        status: json['status'] ?? LiveEventStatus.draft,
        eventType: json['event_type'] ?? LiveEventType.none,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        guideline: json['guideline'] ?? '',
        category: json['category'] ?? '',
        imageUrl: json['event_img_url'] ?? '',
        ownerAccountId: json['owner_account_id'],
        ownerUserId: json['owner_user_id'],
        ownerNickname: json['owner_nickname'],
        ownerImageUrl: json['user_img_samll_url'],
        startDate:
            DateTime.tryParse(json['start_date'] ?? DateTime.now().toString()),
        endDate:
            DateTime.tryParse(json['end_date'] ?? DateTime.now().toString()),
        requestLimitDate: DateTime.tryParse(
            json['request_limit_date'] ?? DateTime.now().toString()),
        isRanking: json['is_ranking'] ?? false,
        isLiverPrize: json['is_liver_prize'] ?? false,
        isListenerPrize: json['is_listener_prize'] ?? false,
        inviteOnly: json['invite_only'] ?? false,
        isJoined: json['is_joined'] ?? false,
        isFollowed: json['is_followed'] ?? false,
      );

  /// イベントID.
  final String id;

  /// イベントのステータス.
  final int status;

  /// イベントタイプ.
  final String eventType;

  /// イベント名.
  final String name;

  /// イベントの説明.
  final String description;

  /// 募集要項.
  final String guideline;

  /// イベントのカテゴリ.
  final String category;

  /// イベントの画像URL.
  final String imageUrl;

  /// イベント主催者のアカウントID.
  final String ownerAccountId;

  /// イベント主催者のID.
  final String ownerUserId;

  /// イベント主催者の名前(表示名)
  final String ownerNickname;

  /// イベント主催者の画像URL.
  final String ownerImageUrl;

  /// 開始日.
  final DateTime startDate;

  /// 終了日.
  final DateTime endDate;

  /// 参加募集期限.
  final DateTime requestLimitDate;

  /// ランキングがあるかどうか.
  final bool isRanking;

  /// ライバープライズがあるかどうか.
  final bool isLiverPrize;

  /// リスナープライズがあるかどうか.
  final bool isListenerPrize;

  /// プライズがあるかどうか.
  bool get isPrize => isLiverPrize || isListenerPrize;

  /// 招待専用かどうか.
  final bool inviteOnly;

  /// イベントに参加しているかどうか.
  final bool isJoined;

  /// イベントをフォローしているかどうか.
  final bool isFollowed;

  /// カテゴリをハッシュタグへ変換.
  String categoryToHashTag() {
    if (category == null) {
      return '';
    }
    if (category.isEmpty) {
      return '';
    }
    List tags = category.split(',');
    return tags.map((tag) => '#$tag').join(' ');
  }

  /// イベントタイプ毎のアイコン.
  String eventTypeAssetName() {
    switch (eventType) {
      case LiveEventType.ranking:
        return 'assets/svg/icon_crown.svg';
      case LiveEventType.relay:
        return 'assets/svg/icon_relay.svg';
    }
    return 'assets/svg/icon_crown.svg';
  }

  /// イベントタイプ毎の表示名.
  String eventTypeName() {
    switch (eventType) {
      case LiveEventType.ranking:
        return 'ランキングイベント';
      case LiveEventType.relay:
        return 'リレーイベント';
    }
    return 'イベント';
  }
}
