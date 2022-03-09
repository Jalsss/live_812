import 'package:tuple/tuple.dart';

class CreditCardUtil {
  // 'MM/YY' 文字列から数値2つを取り出し
  static Tuple2<int, int> extractExpireMonthYear(String expireDate) {
    if (expireDate != null) {
      final re = RegExp(r'^(\d{2})/(\d{2})$');
      final m = re.firstMatch(expireDate);
      if (m != null) {
        int month = int.tryParse(m.group(1));
        int year = int.tryParse(m.group(2));
        return Tuple2<int, int>(month, year);
      }
    }
    return null;
  }

  // 'YYYYMM' 文字列からMM,YYYY2つを取り出し
  static Tuple2<String, String> extractExpireYearMonth(String expireDate) {
    if (expireDate != null) {
      final re = RegExp(r'^(\d{2})(\d{2})(\d{2})$');
      final m = re.firstMatch(expireDate);
      if (m != null) {
        String month = m.group(2);
        String year = m.group(3);
        return Tuple2<String, String>(month, year);
      }
    }
    return null;
  }
  // 'MM/YY' と現在の年月から 'YYYYMM' 文字列作成
  static String constructExpireYearMonth(String expireDate, DateTime now) {
    final tuple = CreditCardUtil.extractExpireMonthYear(expireDate);
    final month = tuple.item1;
    final year = tuple.item2 + (now.year - now.year % 100);

    // YYYYMMに変換
    final nowYyyymm = now.year * 100 + now.month;
    int expireYyyymm = year * 100 + month;
    if (expireYyyymm > nowYyyymm + 80 * 100) {
      expireYyyymm -= 100 * 100;
    } else if (expireYyyymm < nowYyyymm - 20 * 100) {
      expireYyyymm += 100 * 100;
    }
    return expireYyyymm.toString().padLeft(6, '0');
  }
}
