import 'package:flutter_test/flutter_test.dart';
import 'package:live812/utils/credit_card_util.dart';

void main() {
  test('extractExpireMonthYear', () {
    {
      final tuple = CreditCardUtil.extractExpireMonthYear('01/23');
      expect(tuple, isNotNull);
      expect(tuple.item1, 1);
      expect(tuple.item2, 23);
    }
    {
      final tuple = CreditCardUtil.extractExpireMonthYear('0123');
      expect(tuple, isNull);
    }
  });

  test('constructExpireYearMonth', () {
    expect(CreditCardUtil.constructExpireYearMonth('01/23', DateTime(2020, 7, 12)), '202301');
    expect(CreditCardUtil.constructExpireYearMonth('12/99', DateTime(2020, 7, 23)), '209912');

    expect(CreditCardUtil.constructExpireYearMonth('06/01', DateTime(2099, 1, 4)), '210106');
    expect(CreditCardUtil.constructExpireYearMonth('03/99', DateTime(2101, 1, 5)), '209903');
  });
}
