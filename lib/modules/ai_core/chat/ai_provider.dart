import 'dart:async';

import 'chat_models.dart';

/// Abstract contract for LLM providers.
///
/// Providers must NOT contain wellness logic. Only transport the request
/// to an LLM and stream or return generated text.
abstract class AIProvider {
  /// Non-streaming chat completion.
  Future<String> generateCompletion({
    required List<ChatMessage> messages,
    required String modelName,
  });

  /// Streaming chat completion.
  ///
  /// Emits text deltas. The caller is responsible for assembling final text.
  Stream<String> streamCompletion({
    required List<ChatMessage> messages,
    required String modelName,
  });
}

