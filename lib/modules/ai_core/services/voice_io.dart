/// Abstractions so the module compiles without adding new global dependencies.
///
/// Host app should implement these using:
/// - speech_to_text (STT)
/// - flutter_tts (TTS)
///
/// IMPORTANT: Do not add package imports here; keep integration-safe.

enum ListeningState { idle, requestingPermission, listening, processing, error }
enum SpeakingState { idle, speaking, paused, error }

class SpeechTranscriptChunk {
  final String text;
  final bool isFinal;
  final double confidence; // 0..1

  const SpeechTranscriptChunk({
    required this.text,
    required this.isFinal,
    required this.confidence,
  });
}

abstract class SpeechToTextClient {
  ListeningState get state;

  Future<bool> requestPermission();

  Future<void> startListening({
    required void Function(SpeechTranscriptChunk chunk) onResult,
    void Function(Object error)? onError,
    Duration? listenFor,
  });

  Future<void> stopListening();

  Future<void> cancelListening();
}

abstract class TextToSpeechClient {
  SpeakingState get state;

  Future<void> speak(String text);
  Future<void> stop();

  Future<void> setRate(double rate); // 0..1
  Future<void> setPitch(double pitch); // 0..2
  Future<void> setVolume(double volume); // 0..1
}

