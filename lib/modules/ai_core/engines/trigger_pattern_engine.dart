import '../models/behavioral_pattern.dart';
import '../models/emotional_signal.dart';
import '../services/signal_sources.dart';
import '../utils/math_utils.dart';
import '../utils/time_buckets.dart';

class TriggerPatternEngine {
  const TriggerPatternEngine();

  List<BehavioralPattern> detectPatterns({
    required List<EmotionalSignal> emotions,
    required List<ActivitySignal> activities,
    required List<JournalEntrySignal> journals,
    List<TimeBucket> vulnerableBuckets = kDefaultVulnerableBuckets,
  }) {
    final patterns = <BehavioralPattern>[];

    final negativeSpikeStrength = _negativeSpikeStrength(emotions);
    if (negativeSpikeStrength >= 0.35) {
      patterns.add(BehavioralPattern(
        id: 'negative_spike_cycle',
        title: 'Negative spike cycle',
        description:
            'Higher-frequency negative emotional spikes appear in the recent window.',
        strength: negativeSpikeStrength,
        tags: const ['negative_spike_cycle', 'emotion_trend'],
      ));
    }

    final lateNightStrength = _lateNightStrength(activities, vulnerableBuckets);
    if (lateNightStrength >= 0.30) {
      final window = _mostCommonVulnerableWindow(activities, vulnerableBuckets);
      patterns.add(BehavioralPattern(
        id: 'late_night_vulnerable_window',
        title: 'Vulnerable time window',
        description:
            'A meaningful share of activity occurs in late-night windows, which can correlate with lower resilience for many people.',
        strength: lateNightStrength,
        tags: const ['late_night_activity', 'vulnerable_window'],
        vulnerableWindowLabel: window,
      ));
    }

    final isolationStrength = _isolationStrength(activities);
    if (isolationStrength >= 0.55) {
      patterns.add(BehavioralPattern(
        id: 'isolation_pattern',
        title: 'Lower connection indicators',
        description:
            'Connection indicators (social touchpoints) look lower than usual.',
        strength: isolationStrength,
        tags: const ['isolation', 'connection'],
      ));
    }

    final journalingDrop = _journalingDrop(journals);
    if (journalingDrop >= 0.35) {
      patterns.add(BehavioralPattern(
        id: 'journaling_consistency_drop',
        title: 'Journaling consistency shift',
        description:
            'Journaling cadence looks less consistent in the recent half of the window.',
        strength: journalingDrop,
        tags: const ['journaling', 'consistency_shift'],
      ));
    }

    return patterns..sort((a, b) => b.strength.compareTo(a.strength));
  }

  double _negativeSpikeStrength(List<EmotionalSignal> emotions) {
    if (emotions.isEmpty) return 0;
    final spikes = emotions.where((e) => e.valence <= -0.6 && e.intensity >= 0.6).length;
    return clamp01(safeDiv(spikes.toDouble(), emotions.length.toDouble(), fallback: 0));
  }

  double _lateNightStrength(List<ActivitySignal> activities, List<TimeBucket> buckets) {
    if (activities.isEmpty) return 0;
    final count = activities.where((a) => buckets.any((b) => b.contains(a.timestamp))).length;
    return clamp01(safeDiv(count.toDouble(), activities.length.toDouble(), fallback: 0));
  }

  String? _mostCommonVulnerableWindow(List<ActivitySignal> activities, List<TimeBucket> buckets) {
    if (activities.isEmpty) return null;
    final counts = <String, int>{};
    for (final a in activities) {
      final b = buckets.where((x) => x.contains(a.timestamp)).toList(growable: false);
      if (b.isEmpty) continue;
      counts[b.first.label] = (counts[b.first.label] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    final best = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return best.key;
  }

  double _isolationStrength(List<ActivitySignal> activities) {
    if (activities.isEmpty) return 0;
    final socialConn = mean(activities.map((a) => a.socialConnection));
    return clamp01(1 - socialConn);
  }

  double _journalingDrop(List<JournalEntrySignal> journals) {
    if (journals.length < 4) return 0;
    final sorted = journals.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final half = (sorted.length / 2).floor();
    final first = mean(sorted.take(half).map((j) => j.consistency));
    final second = mean(sorted.skip(half).map((j) => j.consistency));
    final drop = (first - second);
    return clamp01(drop);
  }
}

