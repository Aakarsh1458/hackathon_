import 'package:flutter/foundation.dart';

import '../services/logging/app_logger.dart';

/// Flutter framework + async platform error hooks for the shell.
/// Modules should add scoped handlers that delegate here if needed.
class GlobalErrorHandler {
  GlobalErrorHandler._();

  static Future<void> install() async {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      AppLogger.instance.error(
        'Flutter framework error',
        details.exception,
        details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.instance.error('PlatformDispatcher error', error, stack);
      return true;
    };
  }
}
