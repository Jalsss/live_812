import 'package:flutter/foundation.dart';

class BenefitLog {
  final String id;
  final int benefit;
  final DateTime createDate;
  final DateTime withdrawRequestDate;
  final DateTime withdrawEstimateDate;

  BenefitLog({
    @required this.id,
    @required this.benefit,
    @required this.createDate,
    @required this.withdrawRequestDate,
    @required this.withdrawEstimateDate,
  });

  factory BenefitLog.fromJson(Map<String, dynamic> json) {
    int benefit;
    dynamic benefitValue = json['benefit'];
    if (benefitValue is String)
      benefit = int.tryParse(benefitValue);
    else if (benefitValue is int)
      benefit = benefitValue;

    return BenefitLog(
      id: json['id'],
      benefit: benefit,
      createDate: parseDate(json['create_date']),
      withdrawRequestDate: parseDate(json['withdraw_request_date']),
      withdrawEstimateDate: parseDate(json['withdraw_estimate_date']),
    );
  }

  String toString() {
    return 'BenefitLog{id=$id, benefit=$benefit, createDate=$createDate, requestDate=$withdrawRequestDate, estimateDate=$withdrawEstimateDate}';
  }

  static DateTime parseDate(String dateStr) {
    if (dateStr == null)
      return null;
    try {
      return DateTime.tryParse(dateStr);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
