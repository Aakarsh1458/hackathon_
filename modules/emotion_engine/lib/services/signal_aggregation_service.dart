import '../models/emotion_data.dart';
import '../models/emotion_label.dart';
import '../models/mood_entry.dart';
import '../models/mood_timeline.dart';
import '../models/signal_state.dart';

/// Merges facial signals, journaling, and history into a single [SignalState].
class SignalAggregationService {
  const SignalAggregationService();

  SignalState build({
    required EmotionData? liveFace,
    required List<EmotionData> recentFace,
    required List<MoodEntry> journal,
    required bool cameraActive,
    String? lastError,
  }) {
    final timeline = MoodTimeline(
      entries: List<MoodEntry>.from(journal),
      faceSignals: List<EmotionData>.from(recentFace),
      generatedAt: DateTime.now(),
    );

    final indicators = <String, double>{};
    if (liveFace != null) {
      indicators['expressiveEnergy'] = _expressiveEnergy(liveFace);
      indicators['calmFocus'] = _calmFocus(liveFace);
      final v = MoodTimeline.valenceForLabel(liveFace.dominant);
      indicators['positiveAffectSignal'] =
          liveFace.confidenceFor(liveFace.dominant) * ((v + 1) / 2).clamp(0.0, 1.0);
    } else if (recentFace.isNotEmpty) {
      final last = recentFace.last;
      indicators['expressiveEnergy'] = _expressiveEnergy(last);
      indicators['calmFocus'] = _calmFocus(last);
    }

    if (journal.isNotEmpty) {
      final last = journal.first;
      if (last.linkedConfidences != null && last.linkedConfidences!.isNotEmpty) {
        indicators['journalValence'] =
            (MoodTimeline.expectedValence(last.linkedConfidences!) + 1) / 2;
      }
    }

    return SignalState(
      liveFaceSignal: liveFace,
      recentFaceSignals: List<EmotionData>.from(recentFace.reversed.take(24)),
      recentJournal: List<MoodEntry>.from(journal.take(12)),
      timeline: timeline,
      wellnessIndicators: indicators,
      updatedAt: DateTime.now(),
      cameraActive: cameraActive,
      lastError: lastError,
    );
  }

  double _expressiveEnergy(EmotionData d) {
    final spread = d.confidences.values.fold<double>(0, (a, b) => a + (b - 1 / 6).abs());
    return (spread / 3.0).clamp(0.0, 1.0);
  }

  double _calmFocus(EmotionData d) {
    final n = d.confidenceFor(EmotionLabel.neutral);
    final lowArousal = 1.0 - d.confidenceFor(EmotionLabel.surprised);
    return ((n * 0.55) + (lowArousal * 0.45)).clamp(0.0, 1.0);
  }
}
