import 'package:flutter_test/flutter_test.dart';
import 'package:live812/domain/model/user/user.dart';

void main() {
  test('followCsv test', () {
    final userModel1 = UserModel.fromJson({
      "follow_csv": "abc,xyz",
    });
    expect(userModel1.followCsv.length, 2);

    final userModel2 = UserModel.fromJson({
      "follow_csv": "",
    });
    expect(userModel2.followCsv.isEmpty, true);

    final userModel3 = UserModel.fromJson({});
    expect(userModel3.followCsv.isEmpty, true);
  });
}
