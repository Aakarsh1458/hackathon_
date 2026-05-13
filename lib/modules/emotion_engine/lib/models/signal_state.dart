import 'emotion_data.dart';
import 'mood_entry.dart';
import 'mood_timeline.dart';

/// Unified emotional signal snapshot for integration with other AI modules.
class SignalState {
  const SignalState({
    this.liveFaceSignal,
    this.recentFaceSignals = const [],
    this.recentJournal = const [],
    this.timeline,
    this.wellnessIndicators = const {},
    required this.updatedAt,
    this.cameraActive = false,
    this.lastError,
  });

  final EmotionData? liveFaceSignal;
  final List<EmotionData> recentFaceSignals;
  final List<MoodEntry> recentJournal;
  final MoodTimeline? timeline;

  /// Normalized indicators in [0,1] — e.g. calmFocus, expressiveEnergy.
  final Map<String, double> wellnessIndicators;
  final DateTime updatedAt;
  final bool cameraActive;
  final String? lastError;

  SignalState copyWith({
    EmotionData? liveFaceSignal,
    List<EmotionData>? recentFaceSignals,
    List<MoodEntry>? recentJournal,
    MoodTimeline? timeline,
    Map<String, double>? wellnessIndicators,
    DateTime? updatedAt,
    bool? cameraActive,
    String? lastError,
  }) {
    return SignalState(
      liveFaceSignal: liveFaceSignal ?? this.liveFaceSignal,
      recentFaceSignals: recentFaceSignals ?? this.recentFaceSignals,
      recentJournal: recentJournal ?? this.recentJournal,
      timeline: timeline ?? this.timeline,
      wellnessIndicators: wellnessIndicators ?? this.wellnessIndicators,
      updatedAt: updatedAt ?? this.updatedAt,
      cameraActive: cameraActive ?? this.cameraActive,
      lastError: lastError ?? this.lastError,
    );
  }
}
