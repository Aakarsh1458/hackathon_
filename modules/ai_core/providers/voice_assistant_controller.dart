import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/emotional_context.dart';
import '../services/voice_conversation_service.dart';
import '../services/safety_guardrails.dart';

class VoiceAssistantController extends ChangeNotifier {
  final VoiceConversationService service;
  StreamSubscription<VoiceConversationSnapshot>? _sub;

  VoiceConversationSnapshot _snapshot = const VoiceConversationSnapshot(
    state: VoiceTurnState.idle,
    partialTranscript: '',
    timeline: [],
    safetySeverity: SafetySeverity.none,
  );

  VoiceConversationSnapshot get snapshot => _snapshot;
  List<ChatMessage> get timeline => _snapshot.timeline;
  VoiceTurnState get state => _snapshot.state;
  String get partialTranscript => _snapshot.partialTranscript;

  Object? _lastError;
  Object? get lastError => _lastError;

  VoiceAssistantController({required this.service}) {
    _sub = service.stream.listen((s) {
      _snapshot = s;
      notifyListeners();
    }, onError: (e) {
      _lastError = e;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    service.dispose();
    super.dispose();
  }

  Future<void> startListening({
    required EmotionalContext context,
  }) async {
    _lastError = null;
    notifyListeners();
    await service.startListening(context: context);
  }

  Future<void> stopListening() => service.stopListening();
  Future<void> cancel() => service.cancel();

  Future<ChatMessage?> sendTranscript({
    required String transcript,
    required EmotionalContext context,
  }) async {
    _lastError = null;
    notifyListeners();
    return service.handleFinalTranscript(transcript, context: context);
  }
}

