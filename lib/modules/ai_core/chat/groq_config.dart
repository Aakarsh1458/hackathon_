import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Groq configuration loaded from environment.
///
/// Lookup order:
/// 1) Runtime `.env` via `flutter_dotenv`
/// 2) Compile-time `--dart-define`
class GroqConfig {
  const GroqConfig({
    this.apiKey,
    this.modelName = defaultModelName,
    this.fallbackModelName = fallbackModelNameDefault,
    this.baseUrl = 'https://api.groq.com/openai/v1/chat/completions',
    this.temperature = 0.5,
    this.maxTokens = 900,
  });

  static const defaultModelName = 'llama3-70b-8192';
  static const fallbackModelNameDefault = 'mixtral-8x7b-32768';

  /// If null/empty, provider returns a graceful missing-key error.
  final String? apiKey;

  final String modelName;
  final String fallbackModelName;

  final String baseUrl;
  final double temperature;
  final int maxTokens;

  static Future<void> ensureEnvironmentLoaded() async {
    if (dotenv.isInitialized) return;
    try {
      await dotenv.load(fileName: '.env', isOptional: true);
    } catch (_) {
      // Bundled `.env` may be absent on CI clones without secrets — fallback to dart-define only.
    }
  }

  static String _valueFromEnv(
    String key, {
    required String defaultValue,
  }) {
    final runtimeValue = dotenv.isInitialized ? dotenv.env[key] : null;
    if (runtimeValue != null && runtimeValue.trim().isNotEmpty) {
      return runtimeValue.trim();
    }
    return switch (key) {
      'GROQ_API_KEY' => const String.fromEnvironment('GROQ_API_KEY', defaultValue: ''),
      'MODEL_NAME' => const String.fromEnvironment('MODEL_NAME', defaultValue: defaultModelName),
      'FALLBACK_MODEL_NAME' =>
        const String.fromEnvironment('FALLBACK_MODEL_NAME', defaultValue: fallbackModelNameDefault),
      _ => defaultValue,
    };
  }

  static Future<GroqConfig> fromEnvironment() async {
    await ensureEnvironmentLoaded();
    final resolvedApiKey = _valueFromEnv('GROQ_API_KEY', defaultValue: '');
    return GroqConfig(
      apiKey: resolvedApiKey.isEmpty ? null : resolvedApiKey,
      modelName: _valueFromEnv('MODEL_NAME', defaultValue: defaultModelName),
      fallbackModelName: _valueFromEnv(
        'FALLBACK_MODEL_NAME',
        defaultValue: fallbackModelNameDefault,
      ),
    );
  }

  GroqConfig copyWith({
    String? apiKey,
    String? modelName,
    String? fallbackModelName,
  }) {
    return GroqConfig(
      apiKey: apiKey ?? this.apiKey,
      modelName: modelName ?? this.modelName,
      fallbackModelName: fallbackModelName ?? this.fallbackModelName,
      baseUrl: baseUrl,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }
}

