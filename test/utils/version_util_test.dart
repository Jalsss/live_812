import 'package:flutter_test/flutter_test.dart';
import 'package:live812/utils/version_util.dart';

void main() {
  test('Version.updateRequired', () {
    expect(VersionUtil.updateRequired(requiredVersion: '1.2.3', appVersion: '1.2.3'), false);
    expect(VersionUtil.updateRequired(requiredVersion: '1.2.3', appVersion: '1.2.2'), true);
    expect(VersionUtil.updateRequired(requiredVersion: '1.2.3', appVersion: '1.2.4'), false);
    expect(VersionUtil.updateRequired(requiredVersion: '1.2.3', appVersion: '2.0.0'), false);

    expect(VersionUtil.updateRequired(requiredVersion: '1.2.3', appVersion: '2.0'), false);
    expect(VersionUtil.updateRequired(requiredVersion: '2.0', appVersion: '1.2.3'), true);
    expect(VersionUtil.updateRequired(requiredVersion: '2.1', appVersion: '2.1.1'), false);
  });
}
