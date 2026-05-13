import 'dart:async';
import 'dart:math';

import '../models/chat_message.dart';
import '../models/emotional_context.dart';
import '../services/conversation_memory.dart';
import '../services/emotional_adaptation.dart';
import '../services/safety_guardrails.dart';
import 'voice_io.dart';
import 'wellness_chat_service.dart';

enum VoiceTurnState {
  idle,
  listening,
  thinking,
  speaking,
  error,
}

class VoiceConversationSnapshot {
  final VoiceTurnState state;
  final String partialTranscript;
  final ChatMessage? lastAssistantMessage;
  final List<ChatMessage> timeline;
  final SafetySeverity safetySeverity;

  const VoiceConversationSnapshot({
    required this.state,
    required this.partialTranscript,
    required this.timeline,
    required this.safetySeverity,
    this.lastAssistantMessage,
  });
}

/// Exportable service that ties STT->Chat->TTS with calm pacing.
class VoiceConversationService {
  final SpeechToTextClient stt;
  final TextToSpeechClient tts;
  final WellnessChatService chat;
  final ConversationMemory memory;
  final SafetyGuardrails safety;
  final EmotionalAdaptationEngine adaptationEngine;

  final _controller = StreamController<VoiceConversationSnapshot>.broadcast();
  Stream<VoiceConversationSnapshot> get stream => _controller.stream;

  VoiceTurnState _state = VoiceTurnState.idle;
  String _partial = '';
  SafetySeverity _safety = SafetySeverity.none;

  VoiceConversationService({
    required this.stt,
    required this.tts,
    required this.chat,
    ConversationMemory? memory,
    SafetyGuardrails? safety,
    EmotionalAdaptationEngine? adaptationEngine,
  })  : memory = memory ?? chat.memory,
        safety = safety ?? chat.safety,
        adaptationEngine = adaptationEngine ?? chat.adaptationEngine;

  void dispose() {
    _controller.close();
  }

  Future<bool> requestMicPermission() async {
    _emit(state: VoiceTurnState.idle);
    return stt.requestPermission();
  }

  Future<void> startListening({
    required EmotionalContext context,
    Duration? listenFor,
  }) async {
    _partial = '';
    _safety = SafetySeverity.none;
    _emit(state: VoiceTurnState.listening);

    await stt.startListening(
      listenFor: listenFor,
      onResult: (chunk) async {
        _partial = chunk.text;
        _emit(state: VoiceTurnState.listening);

        if (chunk.isFinal && chunk.text.trim().isNotEmpty) {
          await stopListening();
          await handleFinalTranscript(chunk.text, context: context, inputConfidence: chunk.confidence);
        }
      },
      onError: (e) {
        _emit(state: VoiceTurnState.error);
      },
    );
  }

  Future<void> stopListening() async {
    await stt.stopListening();
  }

  Future<void> cancel() async {
    await stt.cancelListening();
    await tts.stop();
    _partial = '';
    _emit(state: VoiceTurnState.idle);
  }

  Future<ChatMessage?> handleFinalTranscript(
    String transcript, {
    required EmotionalContext context,
    double inputConfidence = 0.5,
  }) async {
    final text = transcript.trim();
    if (text.isEmpty) return null;

    _emit(state: VoiceTurnState.thinking);

    final safetyResult = safety.evaluateUserText(text);
    _safety = safetyResult.severity;

    final assistant = await chat.handleUserMessage(
      text: text,
      emotionalContext: context,
    );

    // Speak out with emotional adaptation.
    final profile = adaptationEngine.compute(context);
    await tts.setRate(profile.ttsRate);
    await tts.setPitch(profile.ttsPitch);
    await tts.setVolume(profile.ttsVolume);

    _emit(state: VoiceTurnState.speaking, lastAssistant: assistant);
    await _pacedSpeak(assistant.content, pacing: profile.pacing);
    _emit(state: VoiceTurnState.idle, lastAssistant: assistant);
    return assistant;
  }

  Future<void> _pacedSpeak(String text, {required double pacing}) async {
    // Pacing: lower pacing -> small delay before and after speech.
    final preDelayMs = (lerp(420, 140, pacing)).round();
    final postDelayMs = (lerp(380, 120, pacing)).round();
    await Future<void>.delayed(Duration(milliseconds: preDelayMs));
    await tts.speak(_trimForTts(text));
    await Future<void>.delayed(Duration(milliseconds: postDelayMs));
  }

  String _trimForTts(String text) {
    var t = text.trim();
    // Keep voice replies comfortable; avoid long monologues.
    const max = 900;
    if (t.length <= max) return t;
    t = '${t.substring(0, max).trimRight()}…';
    return t;
  }

  void _emit({required VoiceTurnState state, ChatMessage? lastAssistant}) {
    _state = state;
    _controller.add(
      VoiceConversationSnapshot(
        state: _state,
        partialTranscript: _partial,
        lastAssistantMessage: lastAssistant,
        timeline: memory.snapshot(),
        safetySeverity: _safety,
      ),
    );
  }

  String _id(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
}

