import 'dart:async';

import '../chat/ai_provider.dart';
import '../chat/chat_models.dart';
import '../memory/conversation_memory.dart';
import '../prompt/wellness_prompt_builder.dart';
import '../recommendations/recommendation_engine.dart';
import '../safety/crisis_guard.dart';
import './emotional_context_service.dart';

/// Emotional companion chat service (architecture-only).
///
/// The module accepts EmotionalContext from upstream modules, then produces
/// a non-medical wellness response.
class WellnessChatService {
  WellnessChatService({
    required AIProvider aiProvider,
    required EmotionalContextService emotionalContextService,
    required WellnessPromptBuilder promptBuilder,
    required RecommendationEngine recommendationEngine,
    required CrisisEscalation crisisEscalation,
    CrisisGuard? crisisGuard,
    ConversationMemory? memory,
    String modelName = '',
  })  : _aiProvider = aiProvider,
        _emotionalContextService = emotionalContextService,
        _promptBuilder = promptBuilder,
        _recommendationEngine = recommendationEngine,
        _crisisEscalation = crisisEscalation,
        _crisisGuard = crisisGuard ?? CrisisGuard(),
        _memory = memory ?? ConversationMemory(),
        _modelName = modelName;

  final AIProvider _aiProvider;
  final EmotionalContextService _emotionalContextService;
  final WellnessPromptBuilder _promptBuilder;
  final RecommendationEngine _recommendationEngine;
  final CrisisEscalation _crisisEscalation;
  final CrisisGuard _crisisGuard;
  final ConversationMemory _memory;
  final String _modelName;

  /// Sends a message and returns the full assistant response.
  Future<ChatResponse> sendUserMessage({
    required String userText,
    required EmotionalContext context,
  }) async {
    final crisisCheck = _crisisGuard.check(userText);
    if (crisisCheck.isCrisis) {
      final assistant = ChatMessage(
        role: 'assistant',
        content: _crisisEscalation.safeCrisisResponse(),
      );
      _memory.add(
        ChatMessage(role: 'user', content: userText),
      );
      _memory.add(assistant);

      final recs = _recommendationEngine.build(
        context: context,
        crisisMode: true,
      );
      return ChatResponse(assistantMessage: assistant, recommendations: recs);
    }

    final normalized = _emotionalContextService.normalize(context);
    final systemPrompt = _promptBuilder.buildSystemPrompt(crisisMode: false);

    final summary = _memory.summary;
    final messages = <ChatMessage>[
      ChatMessage(role: 'system', content: systemPrompt),
      if (summary != null) ...[
        ChatMessage(
          role: 'system',
          content: 'Conversation context summary: $summary',
        ),
      ],
      ..._memory.contextForPrompt(),
      ChatMessage(
        role: 'user',
        content: _promptBuilder.buildUserPrompt(
          userText: userText,
          context: normalized,
          crisisMode: false,
        ),
      ),
    ];

    final modelName = _modelName;
    try {
      final text = await _aiProvider.generateCompletion(
        messages: messages,
        modelName: modelName,
      );

      final assistant = ChatMessage(role: 'assistant', content: text);
      _memory.addUserAndAssistant(userText: userText, assistantText: text);

      final recs = _recommendationEngine.build(
        context: normalized,
        crisisMode: false,
      );
      return ChatResponse(assistantMessage: assistant, recommendations: recs);
    } catch (_) {
      // Safe fallback: never expose provider errors or stack traces.
      final assistantText =
          'I’m here with you. I ran into a temporary issue generating that response, but we can still take a small next step together.\n\n'
          'If you’d like, tell me one sentence: what feels heaviest right now?';

      final assistant = ChatMessage(role: 'assistant', content: assistantText);
      _memory.addUserAndAssistant(
        userText: userText,
        assistantText: assistantText,
      );

      final recs = _recommendationEngine.build(
        context: normalized,
        crisisMode: false,
      );
      return ChatResponse(assistantMessage: assistant, recommendations: recs);
    }
  }

  /// Streaming variant: yields text deltas for responsive typing UI.
  Stream<ChatMessageChunk> streamUserMessage({
    required String userText,
    required EmotionalContext context,
  }) async* {
    final crisisCheck = _crisisGuard.check(userText);
    if (crisisCheck.isCrisis) {
      final assistantText = _crisisEscalation.safeCrisisResponse();
      // Yield the full text in a single delta to keep the UI simple.
      yield ChatMessageChunk(
        textDelta: assistantText,
        isFinal: true,
        assistantMessage: ChatMessage(role: 'assistant', content: assistantText),
      );
      // Note: memory update is done only for the final assistant message.
      _memory.add(ChatMessage(role: 'user', content: userText));
      _memory.add(ChatMessage(role: 'assistant', content: assistantText));
      return;
    }

    final normalized = _emotionalContextService.normalize(context);
    final systemPrompt = _promptBuilder.buildSystemPrompt(crisisMode: false);

    final summary = _memory.summary;
    final messages = <ChatMessage>[
      ChatMessage(role: 'system', content: systemPrompt),
      if (summary != null) ...[
        ChatMessage(
          role: 'system',
          content: 'Conversation context summary: $summary',
        ),
      ],
      ..._memory.contextForPrompt(),
      ChatMessage(
        role: 'user',
        content: _promptBuilder.buildUserPrompt(
          userText: userText,
          context: normalized,
          crisisMode: false,
        ),
      ),
    ];

    final modelName = _modelName;
    final buffer = StringBuffer();
    try {
      await for (final delta in _aiProvider.streamCompletion(
        messages: messages,
        modelName: modelName,
      )) {
        buffer.write(delta);
        yield ChatMessageChunk(textDelta: delta, isFinal: false);
      }
    } catch (_) {
      final assistantText =
          'I’m here with you. There was a temporary issue while generating my response, but we can still slow down together.\n\n'
          'What emotion are you noticing most strongly right now?';
      _memory.addUserAndAssistant(userText: userText, assistantText: assistantText);
      yield ChatMessageChunk(
        textDelta: assistantText,
        isFinal: true,
        assistantMessage: ChatMessage(role: 'assistant', content: assistantText),
      );
      return;
    }

    final fullText = buffer.toString();
    _memory.addUserAndAssistant(userText: userText, assistantText: fullText);

    yield ChatMessageChunk(
      textDelta: '',
      isFinal: true,
      assistantMessage: ChatMessage(role: 'assistant', content: fullText),
    );
  }
}

