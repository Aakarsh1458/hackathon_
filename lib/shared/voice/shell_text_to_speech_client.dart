import 'package:flutter_tts/flutter_tts.dart';

import '../../modules/ai_core/services/voice_io.dart';

/// Host wiring for `flutter_tts` implementing [TextToSpeechClient].
class ShellTextToSpeechClient implements TextToSpeechClient {
  ShellTextToSpeechClient() {
    _tts.setCompletionHandler(() {
      _state = SpeakingState.idle;
    });
    _tts.setCancelHandler(() {
      _state = SpeakingState.idle;
    });
    _tts.setErrorHandler((_) {
      _state = SpeakingState.error;
    });
  }

  final FlutterTts _tts = FlutterTts();
  SpeakingState _state = SpeakingState.idle;

  @override
  SpeakingState get state => _state;

  @override
  Future<void> speak(String text) async {
    _state = SpeakingState.speaking;
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _state = SpeakingState.idle;
  }

  @override
  Future<void> setRate(double rate) => _tts.setSpeechRate(rate.clamp(0.1, 1.0));

  @override
  Future<void> setPitch(double pitch) => _tts.setPitch(pitch.clamp(0.5, 2.0));

  @override
  Future<void> setVolume(double volume) => _tts.setVolume(volume.clamp(0.0, 1.0));
}
