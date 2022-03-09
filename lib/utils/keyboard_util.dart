import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardUtil {
  // iOS, Androidでの仮想キーボードを閉じる
  static void close(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus)
      currentFocus.unfocus();
  }
}
