import 'package:flutter_test/flutter_test.dart';
import 'package:live812/utils/result.dart';

void main() {
  test('Result test', () {
    Result<int, String> isOdd(int x) {
      if (x % 2 != 0)
        return Ok(x);
      else
        return Err('Even!');
    }

    isOdd(1).match(
      ok: (ok) => expect(true, true),
      err: (err) => fail('fail'),
    );

    isOdd(2).match(
      ok: (ok) => fail('fail'),
      err: (err) => expect(true, true),
    );
  });
}
