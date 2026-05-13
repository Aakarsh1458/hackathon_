import '../chat/chat_models.dart';

/// Lightweight in-module memory.
///
/// This keeps recent messages and a heuristic summary. It is intentionally
/// simple to stay safe, deterministic, and modular.
class ConversationMemory {
  ConversationMemory({this.maxMessages = 14});

  final int maxMessages;

  final List<ChatMessage> _recent = [];
  String? _summary;

  List<ChatMessage> get recent => List.unmodifiable(_recent);
  String? get summary => _summary;

  void add(ChatMessage message) {
    _recent.add(message);
    if (_recent.length > maxMessages) {
      _recent.removeRange(0, _recent.length - maxMessages);
    }
    _summary = _buildHeuristicSummary();
  }

  void addUserAndAssistant({
    required String userText,
    required String assistantText,
  }) {
    add(ChatMessage(role: 'user', content: userText));
    add(ChatMessage(role: 'assistant', content: assistantText));
  }

  List<ChatMessage> contextForPrompt() {
    // Keep last messages only.
    return recent;
  }

  String? _buildHeuristicSummary() {
    // Heuristic: combine last user + assistant themes without LLM calls.
    final lastUser =
        _recent.where((m) => m.isUser).isNotEmpty ? _recent.lastWhere((m) => m.isUser) : null;
    final lastAssistant = _recent.where((m) => m.isAssistant).isNotEmpty
        ? _recent.lastWhere((m) => m.isAssistant)
        : null;

    if (lastUser == null) return _summary;

    final userSnip = lastUser.content.trim();
    final userTake = userSnip.length > 160 ? userSnip.substring(0, 160) : userSnip;

    final assistantTake = (lastAssistant?.content ?? '').trim();
    final assistantSnip = assistantTake.isEmpty
        ? ''
        : (assistantTake.length > 160 ? assistantTake.substring(0, 160) : assistantTake);

    final combined = assistantSnip.isEmpty
        ? 'Recent theme: $userTake'
        : 'Recent theme: $userTake\nCompanion focus: $assistantSnip';

    // Avoid unbounded growth.
    if (combined.length > 280) {
      return combined.substring(0, 280);
    }
    return combined;
  }
}

