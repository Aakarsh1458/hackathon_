import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_provider.dart';
import 'chat_models.dart';
import 'groq_config.dart';

/// Groq OpenAI-compatible provider.
///
/// The module consumes the shell prompt messages (system/user/assistant)
/// and returns generated text with optional streaming.
class GroqAIProvider implements AIProvider {
  GroqAIProvider({
    GroqConfig? config,
    http.Client? httpClient,
  })  : _config = config ?? GroqConfig.fromEnvironment(),
        _client = httpClient ?? http.Client();

  final GroqConfig _config;
  final http.Client _client;

  String _requireApiKey() {
    final key = _config.apiKey;
    if (key == null || key.isEmpty) {
      throw StateError(
        'Groq API key missing. Provide GROQ_API_KEY via --dart-define or your env loader.',
      );
    }
    return key;
  }

  String _requireModel(String modelNameOverride) {
    if (modelNameOverride.isNotEmpty) return modelNameOverride;
    final model = _config.modelName;
    if (model == null || model.isEmpty) {
      throw StateError(
        'Groq model name missing. Provide MODEL_NAME via --dart-define or pass a modelName override.',
      );
    }
    return model;
  }

  @override
  Future<String> generateCompletion({
    required List<ChatMessage> messages,
    required String modelName,
  }) async {
    final apiKey = _requireApiKey();
    final finalModel = _requireModel(modelName);

    final uri = Uri.parse(_config.baseUrl);
    final body = jsonEncode({
      'model': finalModel,
      'temperature': _config.temperature,
      'max_tokens': _config.maxTokens,
      'messages': messages
          .map((m) => <String, String>{'role': m.role, 'content': m.content})
          .toList(),
    });

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = response.body.isNotEmpty ? response.body : 'Groq request failed';
      throw StateError('Groq completion failed: HTTP ${response.statusCode}: $msg');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text = decoded['choices']?.first?['message']?['content'];
    if (text is! String) {
      throw StateError('Groq completion returned unexpected response shape.');
    }
    return text;
  }

  @override
  Stream<String> streamCompletion({
    required List<ChatMessage> messages,
    required String modelName,
  }) async* {
    final apiKey = _requireApiKey();
    final finalModel = _requireModel(modelName);

    final uri = Uri.parse(_config.baseUrl);
    final body = jsonEncode({
      'model': finalModel,
      'temperature': _config.temperature,
      'max_tokens': _config.maxTokens,
      'stream': true,
      'messages': messages
          .map((m) => <String, String>{'role': m.role, 'content': m.content})
          .toList(),
    });

    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      })
      ..body = body;

    final streamedResponse = await _client.send(request);
    if (streamedResponse.statusCode < 200 || streamedResponse.statusCode >= 300) {
      final err = await streamedResponse.stream.bytesToString();
      throw StateError(
        'Groq streaming failed: HTTP ${streamedResponse.statusCode}: $err',
      );
    }

    // Groq stream is SSE-like: lines with `data: {json}`.
    // We extract `choices[0].delta.content` for each event.
    final lineStream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lineStream) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (!trimmed.startsWith('data:')) continue;

      final payload = trimmed.substring(5).trim();
      if (payload == '[DONE]') break;

      try {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final delta = decoded['choices']?.first?['delta'];
        final content = delta?['content'];
        if (content is String && content.isNotEmpty) {
          yield content;
        }
      } catch (_) {
        // Ignore malformed chunks to keep chat responsive.
      }
    }
  }
}

