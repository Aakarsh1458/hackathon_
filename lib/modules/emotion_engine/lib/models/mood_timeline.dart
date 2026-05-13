import 'emotion_data.dart';
import 'emotion_label.dart';
import 'mood_entry.dart';

/// Aggregated emotional history for charts and summaries.
class MoodTimeline {
  MoodTimeline({
    required this.entries,
    required this.faceSignals,
    required this.generatedAt,
  });

  final List<MoodEntry> entries;
  final List<EmotionData> faceSignals;
  final DateTime generatedAt;

  /// Simple valence proxy in [-1, 1] for trend visualization (wellness indicator).
  static double valenceForLabel(EmotionLabel label) {
    switch (label) {
      case EmotionLabel.happy:
        return 1.0;
      case EmotionLabel.surprised:
        return 0.35;
      case EmotionLabel.neutral:
        return 0.0;
      case EmotionLabel.stressed:
        return -0.55;
      case EmotionLabel.sad:
        return -0.75;
      case EmotionLabel.angry:
        return -0.65;
    }
  }

  /// Expected valence from confidence distribution.
  static double expectedValence(Map<EmotionLabel, double> confidences) {
    var sum = 0.0;
    var w = 0.0;
    for (final e in EmotionLabel.values) {
      final c = confidences[e] ?? 0.0;
      sum += c * valenceForLabel(e);
      w += c;
    }
    if (w <= 1e-6) return 0.0;
    return (sum / w).clamp(-1.0, 1.0);
  }

  /// Per-day average valence from mixed journal + face signals.
  Map<DateTime, double> dailyTrend() {
    final buckets = <DateTime, List<double>>{};
    void add(DateTime t, double v) {
      final key = DateTime(t.year, t.month, t.day);
      buckets.putIfAbsent(key, () => []).add(v);
    }

    for (final e in entries) {
      if (e.linkedConfidences != null && e.linkedConfidences!.isNotEmpty) {
        add(e.createdAt, expectedValence(e.linkedConfidences!));
      } else if (e.linkedEmotion != null) {
        add(e.createdAt, valenceForLabel(e.linkedEmotion!));
      }
    }
    for (final s in faceSignals) {
      add(s.capturedAt, expectedValence(s.confidences));
    }

    return {
      for (final kv in buckets.entries)
        kv.key: kv.value.isEmpty
            ? 0.0
            : kv.value.reduce((a, b) => a + b) / kv.value.length
    };
  }

  List<({DateTime day, double trend})> sortedDailyTrend() {
    final m = dailyTrend();
    final keys = m.keys.toList()..sort();
    return [for (final k in keys) (day: k, trend: m[k] ?? 0.0)];
  }

  /// Recent summary string for dashboard cards (non-diagnostic).
  String recentSummary({int maxEntries = 5}) {
    final signals = <String>[];
    final combined = <({DateTime t, String line})>[];
    for (final e in entries) {
      combined.add((t: e.createdAt, line: e.body));
    }
    combined.sort((a, b) => b.t.compareTo(a.t));
    for (final c in combined.take(maxEntries)) {
      signals.add(c.line);
    }
    if (signals.isEmpty) return 'No journal entries yet. Signals will appear as you reflect.';
    return signals.join(' · ');
  }
}
