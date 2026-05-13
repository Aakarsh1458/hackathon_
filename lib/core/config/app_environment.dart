/// Compile-time / runtime environment flags for the shell.
///
/// Other agents: add new keys here without coupling to module internals.
enum AppFlavor { development, staging, production }

class AppEnvironment {
  AppEnvironment._();

  /// Parsed from `--dart-define=FLAVOR=development` etc.
  static AppFlavor get flavor {
    const raw = String.fromEnvironment('FLAVOR', defaultValue: 'development');
    return AppFlavor.values.firstWhere(
      (f) => f.name == raw,
      orElse: () => AppFlavor.development,
    );
  }

  static bool get isProduction => flavor == AppFlavor.production;

  /// Base URL for shell-level APIs only — module endpoints stay inside modules.
  static String get apiBaseUrl => const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: '',
      );
}
