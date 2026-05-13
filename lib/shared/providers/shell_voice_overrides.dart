import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/ai_core/chat/groq_config.dart';
import '../../modules/ai_core/models/emotional_context.dart';
import '../../modules/ai_core/models/risk_tier.dart';
import '../../modules/ai_core/providers/voice_assistant_providers.dart';
import '../../modules/ai_core/services/adaptive_wellness_chat_service.dart';
import '../../modules/ai_core/services/groq_ai_provider.dart';
import '../../modules/ai_core/services/http_groq_ai_provider.dart';
import 'app_state_provider.dart';
import '../voice/shell_speech_to_text_client.dart';
import '../voice/shell_text_to_speech_client.dart';

/// Riverpod overrides so AI Core voice stack uses real STT/TTS + Groq HTTP.
List<Override> shellVoiceProviderOverrides() {
  return [
    sttClientProvider.overrideWithValue(ShellSpeechToTextClient()),
    ttsClientProvider.overrideWithValue(ShellTextToSpeechClient()),
    wellnessChatServiceProvider.overrideWith((ref) {
      final cfg = GroqConfig.resolvedOrThrow;
      final key = cfg.apiKey ?? '';
      return AdaptiveWellnessChatService(
        groq: HttpGroqAIProvider(apiKey: key),
        options: GroqRequestOptions(
          model: cfg.modelName,
          temperature: cfg.temperature,
          maxTokens: cfg.maxTokens.clamp(120, 8192),
          systemPrompt:
              'You are a calm wellness support assistant. You are not a therapist and you do not diagnose. '
              'Focus on grounding, reflection prompts, and small next steps. Avoid dependency. '
              'If user mentions self-harm or suicide, encourage immediate local emergency help.',
        ),
      );
    }),
    currentEmotionalContextProvider.overrideWith((ref) {
      final app = ref.watch(appStateProvider);
      final stress01 = app.stressScore.clamp(0.0, 1.0);
      final stress = (stress01 * 100).clamp(0.0, 100.0);
      return EmotionalContext(
        stressScore: stress,
        burnoutRiskScore: (stress01 * 88).clamp(0.0, 100.0),
        emotionalStabilityScore: ((1.0 - stress01) * 100).clamp(0.0, 100.0),
        relapseRiskTier: stress01 > 0.75
            ? RiskTier.high
            : (stress01 > 0.48 ? RiskTier.medium : RiskTier.low),
        tags: <String>[app.emotionalState.name],
        confidence: 0.65,
      );
    }),
  ];
}
