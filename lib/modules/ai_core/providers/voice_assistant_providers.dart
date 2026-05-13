import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/emotional_context.dart';
import '../services/emotional_adaptation.dart';
import '../services/safety_guardrails.dart';
import '../services/voice_conversation_service.dart';
import '../services/voice_io.dart';
import '../services/adaptive_wellness_chat_service.dart';
import 'voice_assistant_controller.dart';

/// Host app must override these with real implementations wired to:
/// - speech_to_text
/// - flutter_tts
///
/// This module intentionally does NOT add those dependencies here.
final sttClientProvider = Provider<SpeechToTextClient>((ref) {
  throw UnimplementedError('Provide SpeechToTextClient from host app (speech_to_text).');
});

final ttsClientProvider = Provider<TextToSpeechClient>((ref) {
  throw UnimplementedError('Provide TextToSpeechClient from host app (flutter_tts).');
});

/// Host app provides WellnessChatService with a GroqAIProvider implementation.
final wellnessChatServiceProvider = Provider<AdaptiveWellnessChatService>((ref) {
  throw UnimplementedError('Provide AdaptiveWellnessChatService from host app (with GroqAIProvider).');
});

final voiceConversationServiceProvider = Provider<VoiceConversationService>((ref) {
  return VoiceConversationService(
    stt: ref.watch(sttClientProvider),
    tts: ref.watch(ttsClientProvider),
    chat: ref.watch(wellnessChatServiceProvider),
    safety: const SafetyGuardrails(),
    adaptationEngine: const EmotionalAdaptationEngine(),
  );
});

final voiceAssistantControllerProvider = ChangeNotifierProvider<VoiceAssistantController>((ref) {
  return VoiceAssistantController(service: ref.watch(voiceConversationServiceProvider));
});

/// Optional helper provider shape for passing in current emotional context.
final currentEmotionalContextProvider = Provider<EmotionalContext>((ref) {
  return const EmotionalContext(
    stressScore: 45,
    burnoutRiskScore: 35,
    emotionalStabilityScore: 65,
    confidence: 0.5,
  );
});

