import 'package:flutter/foundation.dart';

abstract class VersionUtil {
  // 実行中のアプリのバージョンと比べて、更新が必要かどうかを返す
  static bool updateRequired({@required String requiredVersion, @required String appVersion}) {
    assert(requiredVersion != null);
    assert(appVersion != null);
    final requiredVers = requiredVersion.split('.').map((d) => int.tryParse(d)).toList();
    final appVers = appVersion.split('.').map((d) => int.tryParse(d)).toList();
    for (int i = 0; i < requiredVers.length; ++i) {
      int r = requiredVers[i] ?? 0;
      int a = appVers[i] ?? 0;
      if (r != a)
        return r > a;
    }
    return false;
  }
}
