import '../models/chat_message.dart';

/// Exportable provider interface. Host app supplies API key/endpoint config.
abstract class GroqAIProvider {
  Future<String> generateResponse({
    required List<ChatMessage> messages,
    required GroqRequestOptions options,
  });
}

class GroqRequestOptions {
  final String model;
  final double temperature;
  final int maxTokens;

  /// Optional system prompt (non-clinical framing + safety).
  final String systemPrompt;

  const GroqRequestOptions({
    required this.model,
    this.temperature = 0.6,
    this.maxTokens = 400,
    this.systemPrompt = '',
  });
}

