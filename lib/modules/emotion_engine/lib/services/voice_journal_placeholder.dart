import 'dart:async';

/// Placeholder contract for future on-device or cloud voice journaling.
///
/// TODO(integration): Wire to `record`, `speech_to_text`, or platform audio APIs
/// from the app shell. Do not import shell-level packages inside this module.
abstract class VoiceJournalController {
  Future<void> startSession();
  Future<void> stopSession();
  Stream<VoiceJournalChunk> get chunks;
  bool get isRecording;
}

/// Incremental audio or transcript chunk (implementation-specific).
class VoiceJournalChunk {
  const VoiceJournalChunk({
    required this.capturedAt,
    this.transcriptPlaceholder,
    this.durationMs,
  });

  final DateTime capturedAt;
  final String? transcriptPlaceholder;
  final int? durationMs;
}

/// No-op implementation until the host app injects a real recorder.
class PlaceholderVoiceJournalController implements VoiceJournalController {
  final _controller = StreamController<VoiceJournalChunk>.broadcast();
  bool _recording = false;

  @override
  Stream<VoiceJournalChunk> get chunks => _controller.stream;

  @override
  bool get isRecording => _recording;

  @override
  Future<void> startSession() async {
    _recording = true;
    _controller.add(
      VoiceJournalChunk(
        capturedAt: DateTime.now(),
        transcriptPlaceholder:
            'Voice capture is not enabled in the module build. TODO: inject VoiceJournalController.',
      ),
    );
  }

  @override
  Future<void> stopSession() async {
    _recording = false;
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
