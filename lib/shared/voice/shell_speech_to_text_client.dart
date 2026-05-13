import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../modules/ai_core/services/voice_io.dart';

/// Host wiring for `speech_to_text` implementing [SpeechToTextClient].
class ShellSpeechToTextClient implements SpeechToTextClient {
  ShellSpeechToTextClient() : _speech = stt.SpeechToText();

  final stt.SpeechToText _speech;
  ListeningState _state = ListeningState.idle;
  bool _ready = false;

  @override
  ListeningState get state => _state;

  Future<void> _ensureReady() async {
    if (_ready) return;
    _ready = await _speech.initialize(
      onStatus: (_) {},
      onError: (_) {},
    );
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureReady();
    return _ready;
  }

  @override
  Future<void> startListening({
    required void Function(SpeechTranscriptChunk chunk) onResult,
    void Function(Object error)? onError,
    Duration? listenFor,
  }) async {
    await _ensureReady();
    if (!_ready) {
      onError?.call(StateError('Speech recognition unavailable on this device.'));
      return;
    }

    _state = ListeningState.listening;

    await _speech.listen(
      onResult: (stt.SpeechRecognitionResult r) {
        onResult(
          SpeechTranscriptChunk(
            text: r.recognizedWords,
            isFinal: r.finalResult,
            confidence: 0.78,
          ),
        );
      },
      listenFor: listenFor ?? const Duration(seconds: 45),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,
    );
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
    _state = ListeningState.idle;
  }

  @override
  Future<void> cancelListening() async {
    await _speech.cancel();
    _state = ListeningState.idle;
  }
}
