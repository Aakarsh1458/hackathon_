import '../models/chat_message.dart';

class ConversationMemory {
  final int maxMessages;
  final List<ChatMessage> _messages = [];

  ConversationMemory({this.maxMessages = 24});

  List<ChatMessage> snapshot() => List.unmodifiable(_messages);

  void add(ChatMessage m) {
    _messages.add(m);
    if (_messages.length > maxMessages) {
      _messages.removeRange(0, _messages.length - maxMessages);
    }
  }

  void clear() => _messages.clear();
}

