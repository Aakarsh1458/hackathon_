/// Groq configuration loaded from Dart compile-time environment.
///
/// IMPORTANT:
/// - This module does not hardcode secrets.
/// - For Flutter builds, you can supply values via:
///   - `--dart-define=GROQ_API_KEY=...`
///   - `--dart-define=MODEL_NAME=...`
///
/// If your toolchain supports loading `.env`, those values should be mapped
/// into `--dart-define` by your build scripts.
class GroqConfig {
  const GroqConfig({
    this.apiKey,
    this.modelName,
    this.baseUrl = 'https://api.groq.com/openai/v1/chat/completions',
    this.temperature = 0.5,
    this.maxTokens = 900,
  });

  /// If empty, the provider will throw an error when called.
  final String? apiKey;

  /// Model name (e.g. `llama3-70b-8192`).
  final String? modelName;

  final String baseUrl;
  final double temperature;
  final int maxTokens;

  factory GroqConfig.fromEnvironment() {
    const apiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
    const modelName = String.fromEnvironment('MODEL_NAME', defaultValue: '');
    return GroqConfig(
      apiKey: apiKey.isEmpty ? null : apiKey,
      modelName: modelName.isEmpty ? null : modelName,
    );
  }

  GroqConfig copyWith({
    String? apiKey,
    String? modelName,
  }) {
    return GroqConfig(
      apiKey: apiKey ?? this.apiKey,
      modelName: modelName ?? this.modelName,
      baseUrl: baseUrl,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }
}

