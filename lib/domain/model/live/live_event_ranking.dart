class LiveEventRanking {
  LiveEventRanking({
    this.name,
    this.isRankingGift,
    this.rankingGiftCSV,
    this.users,
  });

  factory LiveEventRanking.fromJson(Map<String, dynamic> json) {
    List<dynamic> list = json['ranking'] as List;
    return LiveEventRanking(
      name: json['ranking_name'],
      isRankingGift: json['is_ranking_gift'] ?? false,
      rankingGiftCSV: json['ranking_gift_csv'] ?? '',
      users: list.map((e) => LiveEventRankingUser.fromJson(e)).toList(),
    );
  }

  /// ランキング名.
  final String name;

  /// 集計対象ギフトがあるかどうか.
  final bool isRankingGift;

  /// 集計対象ギフト.
  /// カンマ区切り.
  final String rankingGiftCSV;

  /// ランキングユーザーデータ.
  final List<LiveEventRankingUser> users;
}

class LiveEventRankingUser {
  LiveEventRankingUser({
    this.id,
    this.userId,
    this.nickname,
    this.imageUrl,
    this.coin,
  });

  factory LiveEventRankingUser.fromJson(Map<String, dynamic> json) =>
      LiveEventRankingUser(
        id: json['id'],
        userId: json['user_id'],
        nickname: json['nickname'],
        imageUrl: json['user_img_samll_url'],
        coin: int.parse(json['gift'] ?? "0"),
      );

  /// ID.
  final String id;

  /// ユーザーID.
  final String userId;

  /// 名前.
  final String nickname;

  /// 画像URL.
  final String imageUrl;

  /// コイン.
  final int coin;
}
