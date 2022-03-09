import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart' show Trace;

class DebugUtil {
  static void dumpStackTrace(int depth, {int startLevel = 1}) {
    final frames = Trace.current(startLevel).frames;
    if (frames != null) {
      debugPrint('Stack Trace:');
      int n = depth <= frames.length ? depth : frames.length;
      for (int i = 0; i < n; ++i)
        debugPrint(frames[i].toString());
      if (depth < frames.length)
        debugPrint('... (eliminated ${frames.length - depth})');
    }
  }

  static void log(dynamic s, {int len = 800}) {
    // 単なる print だとあまり長い文字列は途中までで省略されてしまうので、
    // 細切れにしてすべて表示する

    String ss = s.toString();
    for (int i = 0; i < ss.length; i += len) {
      print(ss.substring(i, min(i + len, ss.length)));
    }
  }
}
