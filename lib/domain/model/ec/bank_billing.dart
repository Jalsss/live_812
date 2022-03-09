class BankBilling {
  final int id;                // ID
  final String bankName;       // 銀行名
  final String branch;         // 支店名
  final String type;           // 普通 or 当座
  final String accountNumber;  // 口座番号
  final String accountName;    // 口座名

  BankBilling._({
    this.id,
    this.bankName,
    this.branch,
    this.type,
    this.accountNumber,
    this.accountName,
  });

  factory BankBilling.fromJson(Map<String, dynamic> json) {
    return BankBilling._(
      id: json['id'],
      bankName: json['name'],
      branch: json['branch'],
      type: json['type'],
      accountNumber: json['num'],
      accountName: json['account'],
    );
  }

  String toString() {
    return 'BankBilling{bank=$bankName, branch=$branch, type=$type, num=$accountNumber, account=$accountName}';
  }
}
