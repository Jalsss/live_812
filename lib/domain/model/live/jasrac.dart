class Jasrac {
  String token;
  String liveId;
  String code;
  String ivt;
  String trans;
  String il;
  int playCount;

  Jasrac(this.token, this.liveId, this.code, this.ivt, this.trans, this.il,
      this.playCount);

  Map toMap() {
    final map = Map<String, dynamic>();
    map['token'] = this.token;
    map['live_id'] = this.liveId;
    map['code'] = this.code;
    map['ivt'] = this.ivt;
    map['trans'] = this.trans;
    map['il'] = this.il;
    map['play_count'] = this.playCount;
    return map;
  }
}
