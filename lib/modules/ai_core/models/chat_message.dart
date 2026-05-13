enum ChatRole { user, assistant, system }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;

  /// Optional metadata for UI/analytics (non-clinical).
  final Map<String, Object?> meta;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.meta = const {},
  });
}

