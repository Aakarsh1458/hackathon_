import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

typedef LogSink = void Function(String message);

/// Central logging — swap [sink] in tests or pipe to crash reporting later.
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  LogSink sink = (m) => developer.log(m, name: 'wellness_shell');

  void info(String message) => sink('[INFO] $message');

  void warning(String message, [Object? error, StackTrace? stack]) {
    sink('[WARN] $message ${error ?? ''}');
    if (kDebugMode && stack != null) {
      sink(stack.toString());
    }
  }

  void error(String message, Object error, StackTrace? stack) {
    sink('[ERROR] $message $error');
    if (kDebugMode && stack != null) {
      sink(stack.toString());
    }
  }
}
