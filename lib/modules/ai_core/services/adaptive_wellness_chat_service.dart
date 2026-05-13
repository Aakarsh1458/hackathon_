import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/emotional_context.dart';
import '../services/conversation_memory.dart';
import '../services/emotional_adaptation.dart';
import '../services/groq_ai_provider.dart';
import '../services/safety_guardrails.dart';

/// Voice/chat-focused service (v2) that works with the `services/*` models.
///
/// Kept separate from the legacy `WellnessChatService` used by `ui/wellness_chat_widget.dart`.
class AdaptiveWellnessChatService {
  final GroqAIProvider groq;
  final ConversationMemory memory;
  final SafetyGuardrails safety;
  final EmotionalAdaptationEngine adaptationEngine;

  final GroqRequestOptions options;

  AdaptiveWellnessChatService({
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
    if (safetyResult.severity != SafetySeverity.none &&
        safetyResult.safeResponse != null) {
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

    String modelReply;
    try {
      modelReply = await groq.generateResponse(
        messages: [
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
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AdaptiveWellnessChat Groq error: $e');
        debugPrint('$st');
      }
      modelReply =
          'I’m having trouble reaching the AI service right now. '
          'You can still journal or try voice again in a moment. '
          'What’s one small thing that felt manageable today?';
    }

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
        : (p.groundingIntensity >= 0.4
            ? 'warm, steady, practical'
            : 'encouraging, reflective');

    final length = p.verbosity <= 0.45
        ? 'short'
        : (p.verbosity <= 0.70 ? 'medium' : 'slightly longer');

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

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
}

