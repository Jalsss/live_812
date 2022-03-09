class RankUser {
  final String id;
  final String userId;
  final String nickname;
  final int point;
  final int rank;
  final String imgUrl;
  final String imgThumbUrl;
  final String imgSmallUrl;

  RankUser({
    this.id,
    this.userId,
    this.nickname,
    this.point,
    this.rank,
    this.imgUrl,
    this.imgThumbUrl,
    this.imgSmallUrl,
  });

  factory RankUser.fromJson(Map<String, dynamic> json) => RankUser(
        id: json["id"],
        userId: json["user_id"],
        nickname: json["nickname"],
        point: json["point"],
        rank: int.parse(json["rank"] ?? "-1"),
        imgUrl: json["img_url"],
        imgThumbUrl: json["img_thumb_url"],
        imgSmallUrl: json["img_small_url"],
      );
}
