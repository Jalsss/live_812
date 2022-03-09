class LiveEventPrize {
  LiveEventPrize({
    this.id,
    this.isLiverPrize,
    this.isListenerPrize,
    this.description,
  });

  factory LiveEventPrize.fromJson(Map<String, dynamic> json) => LiveEventPrize(
        id: json['id'],
        isLiverPrize: json['is_liver_prize'],
        isListenerPrize: json['is_listener_prize'],
        description: json['liver_prize_other'] ?? '',
      );

  final String id;
  final bool isLiverPrize;
  final bool isListenerPrize;
  final String description;
}
