import 'dart:math';

import '../models/chat_message.dart';
import '../models/emotional_context.dart';
import '../services/conversation_memory.dart';
import '../services/emotional_adaptation.dart';
import '../services/groq_ai_provider.dart';
import '../services/safety_guardrails.dart';

/// Exportable orchestrator for conversational wellness (text-first).
///
/// Not a diagnosis. Designed for supportive grounding and reflection prompts.
class WellnessChatService {
  final GroqAIProvider groq;
  final ConversationMemory memory;
  final SafetyGuardrails safety;
  final EmotionalAdaptationEngine adaptationEngine;

  final GroqRequestOptions options;

  WellnessChatService({
    required this.groq,
    ConversationMemory? memory,
    SafetyGuardrails? safety,
    EmotionalAdaptationEngine? adaptationEngine,
    GroqRequestOptions? options,
  })  : memory = memory ?? ConversationMemory(),
        safety = safety ?? const SafetyGuardrails(),
        adaptationEngine = adaptationEngine ?? const EmotionalAdaptationEngine(),
        options = options ??
            const GroqRequestOptions(
              model: 'llama-3.1-8b-instant',
              temperature: 0.6,
              maxTokens: 420,
              systemPrompt:
                  'You are a calm wellness support assistant. You are not a therapist and you do not diagnose. '
                  'Focus on grounding, reflection prompts, and small next steps. Avoid dependency. '
                  'If user mentions self-harm or suicide, encourage immediate local emergency help.',
            );

  Future<ChatMessage> handleUserMessage({
    required String text,
    required EmotionalContext emotionalContext,
  }) async {
    final now = DateTime.now();
    final user = ChatMessage(
      id: _id('u'),
      role: ChatRole.user,
      content: text.trim(),
      timestamp: now,
      meta: {'input': 'text'},
    );
    memory.add(user);

    final safetyResult = safety.evaluateUserText(text);
    if (safetyResult.severity != SafetySeverity.none && safetyResult.safeResponse != null) {
      final assistant = ChatMessage(
        id: _id('a'),
        role: ChatRole.assistant,
        content: safetyResult.safeResponse!,
        timestamp: DateTime.now(),
        meta: {
          'safety': safetyResult.severity.name,
          'keywords': safetyResult.matchedKeywords,
          'suggestions': safetyResult.suggestions,
        },
      );
      final sanitized = safety.sanitizeAssistantMessage(assistant);
      memory.add(sanitized);
      return sanitized;
    }

    final profile = adaptationEngine.compute(emotionalContext);
    final systemHint = _composeDynamicHint(emotionalContext, profile);

    final modelReply = await groq.generateResponse(
      messages: [
        // Inject context as a system-like hint but without diagnosing.
        ChatMessage(
          id: _id('s'),
          role: ChatRole.system,
          content: systemHint,
          timestamp: DateTime.now(),
        ),
        ...memory.snapshot().where((m) => m.role != ChatRole.system),
      ],
      options: options,
    );

    final assistant = ChatMessage(
      id: _id('a'),
      role: ChatRole.assistant,
      content: _trimToTarget(modelReply, profile.verbosity),
      timestamp: DateTime.now(),
      meta: {
        'pacing': profile.pacing,
        'groundingIntensity': profile.groundingIntensity,
      },
    );

    final sanitized = safety.sanitizeAssistantMessage(assistant);
    memory.add(sanitized);
    return sanitized;
  }

  String _composeDynamicHint(EmotionalContext ctx, AdaptationProfile p) {
    final stress = ctx.stressScore.round();
    final burnout = ctx.burnoutRiskScore.round();
    final stability = ctx.emotionalStabilityScore.round();
    final relapse = ctx.relapseRiskTier?.name ?? 'unknown';

    final tone = p.groundingIntensity >= 0.65
        ? 'very gentle, grounding-forward, brief, step-by-step'
        : (p.groundingIntensity >= 0.4 ? 'warm, steady, practical' : 'encouraging, reflective');

    final length = p.verbosity <= 0.45 ? 'short' : (p.verbosity <= 0.70 ? 'medium' : 'slightly longer');

    return 'Context (non-clinical): stress=$stress/100, burnoutRisk=$burnout/100, stability=$stability/100, relapseTier=$relapse. '
        'Respond in a $tone tone. Keep reply $length. '
        'Offer 1 grounding option + 1 small next step. Ask at most 1 question.';
  }

  String _trimToTarget(String text, double verbosity) {
    final t = text.trim();
    if (t.isEmpty) return t;
    final maxChars = (lerp(520, 1150, verbosity)).round();
    if (t.length <= maxChars) return t;
    return '${t.substring(0, maxChars).trimRight()}…';
  }

  String _id(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
}

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

