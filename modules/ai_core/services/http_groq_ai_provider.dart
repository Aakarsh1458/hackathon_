import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import 'groq_ai_provider.dart';

/// Default Groq provider using HTTP. Safe for modular integration.
///
/// The host app should supply the API key securely (not stored here).
class HttpGroqAIProvider implements GroqAIProvider {
  final String apiKey;
  final Uri endpoint;
  final http.Client _client;

  HttpGroqAIProvider({
    required this.apiKey,
    Uri? endpoint,
    http.Client? client,
  })  : endpoint = endpoint ?? Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        _client = client ?? http.Client();

  @override
  Future<String> generateResponse({
    required List<ChatMessage> messages,
    required GroqRequestOptions options,
  }) async {
    final payload = <String, Object?>{
      'model': options.model,
      'temperature': options.temperature,
      'max_tokens': options.maxTokens,
      'messages': [
        if (options.systemPrompt.trim().isNotEmpty)
          {'role': 'system', 'content': options.systemPrompt},
        ...messages.map(_toGroqMessage),
      ],
    };

    final resp = await _client.post(
      endpoint,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Groq request failed (${resp.statusCode})');
    }

    final decoded = jsonDecode(resp.body) as Map<String, Object?>;
    final choices = decoded['choices'] as List<dynamic>? ?? const [];
    if (choices.isEmpty) return '';
    final message = (choices.first as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    return (content ?? '').trim();
  }

  Map<String, Object?> _toGroqMessage(ChatMessage m) {
    final role = switch (m.role) {
      ChatRole.user => 'user',
      ChatRole.assistant => 'assistant',
      ChatRole.system => 'system',
    };
    return {'role': role, 'content': m.content};
  }
}

