import 'dart:async';

import 'ai_provider.dart';
import 'chat_models.dart';
import 'groq_api_exception.dart';
import 'groq_api_service.dart';
import 'groq_config.dart';

/// Groq OpenAI-compatible provider.
///
/// The module consumes the shell prompt messages (system/user/assistant)
/// and returns generated text with optional streaming.
class GroqAIProvider implements AIProvider {
  GroqAIProvider({
    this.config,
    GroqApiService? apiService,
  }) : _apiService = apiService ?? GroqApiService();

  final GroqConfig? config;
  final GroqApiService _apiService;

  Future<GroqConfig> _resolveConfig() async {
    if (config != null) return config!;
    return GroqConfig.fromEnvironment();
  }

  String _requireApiKey(GroqConfig cfg) {
    final key = cfg.apiKey;
    if (key == null || key.isEmpty) {
      throw const MissingGroqApiKeyException();
    }
    return key;
  }

  String _primaryModel(GroqConfig cfg, String modelNameOverride) {
    if (modelNameOverride.isNotEmpty) return modelNameOverride;
    return cfg.modelName;
  }

  @override
  Future<String> generateCompletion({
    required List<ChatMessage> messages,
    required String modelName,
  }) async {
    final cfg = await _resolveConfig();
    final apiKey = _requireApiKey(cfg);
    final primaryModel = _primaryModel(cfg, modelName);
    final uri = Uri.parse(cfg.baseUrl);
    final payload = <String, dynamic>{
      'model': primaryModel,
      'temperature': cfg.temperature,
      'max_tokens': cfg.maxTokens,
      'messages': messages
          .map((m) => <String, String>{'role': m.role, 'content': m.content})
          .toList(),
    };

    Map<String, dynamic> response;
    try {
      response = await _apiService.createCompletion(
        uri: uri,
        apiKey: apiKey,
        payload: payload,
      );
    } on GroqApiException {
      if (cfg.fallbackModelName == primaryModel) rethrow;
      payload['model'] = cfg.fallbackModelName;
      response = await _apiService.createCompletion(
        uri: uri,
        apiKey: apiKey,
        payload: payload,
      );
    }

    final text = response['choices']?.first?['message']?['content'];
    if (text is! String || text.trim().isEmpty) {
      throw const GroqRequestFailedException(
        'Groq completion returned an empty response.',
      );
    }
    return text;
  }

  @override
  Stream<String> streamCompletion({
    required List<ChatMessage> messages,
    required String modelName,
  }) async* {
    final cfg = await _resolveConfig();
    final apiKey = _requireApiKey(cfg);
    final primaryModel = _primaryModel(cfg, modelName);

    final uri = Uri.parse(cfg.baseUrl);
    final payload = <String, dynamic>{
      'model': primaryModel,
      'temperature': cfg.temperature,
      'max_tokens': cfg.maxTokens,
      'stream': true,
      'messages': messages
          .map((m) => <String, String>{'role': m.role, 'content': m.content})
          .toList(),
    };

    try {
      yield* _apiService.createStreamingCompletion(
        uri: uri,
        apiKey: apiKey,
        payload: payload,
      );
    } on GroqApiException {
      if (cfg.fallbackModelName == primaryModel) rethrow;
      payload['model'] = cfg.fallbackModelName;
      yield* _apiService.createStreamingCompletion(
        uri: uri,
        apiKey: apiKey,
        payload: payload,
      );
    }
  }
}

