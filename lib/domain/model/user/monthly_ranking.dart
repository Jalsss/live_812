class MonthlyRanking {
  String id;
  String symbol;
  String nickname;
  int rank;
  String imgUrl;
  String imgThumbUrl;
  String imgSmallUrl;

  MonthlyRanking(
      {this.id,
      this.symbol,
      this.nickname,
      this.rank,
      this.imgUrl,
      this.imgThumbUrl,
      this.imgSmallUrl});

  factory MonthlyRanking.fromJson(Map<String, dynamic> json) {
    return MonthlyRanking(
        id: json['id'],
        symbol: json['user_id'],
        nickname: json['nickname'],
        rank: json['rank'],
        imgUrl: json['img_url'],
        imgThumbUrl: json['img_thumb_url'],
        imgSmallUrl: json['img_small_url']);
  }
}
