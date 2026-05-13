import '../models/emotional_signal.dart';
import '../models/time_series_point.dart';
import '../models/wellness_score.dart';
import '../services/signal_sources.dart';
import '../utils/math_utils.dart';

class WellnessScoringEngine {
  const WellnessScoringEngine();

  WellnessScore compute({
    required List<EmotionalSignal> emotions,
    required List<JournalEntrySignal> journals,
    required List<ActivitySignal> activities,
    List<WearableSignal> wearables = const [],
  }) {
    // Emotional wellness: driven by mean valence (recent), penalized by high volatility.
    final valences = emotions.map((e) => e.valence).toList(growable: false);
    final intensities = emotions.map((e) => e.intensity).toList(growable: false);

    final vMean = mean(valences); // -1..1
    final vStd = stdDev(valences); // ~0..?
    final intensityMean = mean(intensities); // 0..1

    final journalingConsistency = mean(journals.map((j) => j.consistency));
    final journalingDepth = mean(journals.map((j) => j.depth));

    final activityMean = mean(activities.map((a) => a.activityLevel));
    final activityVar = stdDev(activities.map((a) => a.activityLevel));
    final socialConn = mean(activities.map((a) => a.socialConnection));

    final wearableStress = mean(wearables.map((w) => w.stressProxy));
    final wearableSleep = mean(wearables.map((w) => w.sleepQuality));

    // Map mean valence (-1..1) -> (0..100)
    final baseWellness = clamp100((vMean + 1) * 50);

    // Volatility and high intensity reduce stability; consistent journaling helps.
    final stability = clamp100(
      100 *
          clamp01(
            1 -
                (0.55 * clamp01(vStd)) -
                (0.25 * clamp01(intensityMean)) +
                (0.25 * clamp01(journalingConsistency)),
          ),
    );

    // Stress indicator grows with negative valence + volatility + late-night activity + wearable stress.
    final lateNightRate =
        safeDiv(activities.where((a) => a.isLateNight).length.toDouble(),
            activities.length.toDouble(),
            fallback: 0);
    final negPressure = clamp01((-vMean) * 0.7 + vStd * 0.3);
    final stressScore = clamp100(
      100 *
          clamp01(
            0.45 * negPressure +
                0.25 * clamp01(lateNightRate) +
                0.15 * clamp01(activityVar) +
                0.15 * clamp01(wearableStress),
          ),
    );

    // Burnout risk: sustained stress + low recovery behaviors (sleep + low activity regularity).
    final recoveryIndicator = clamp01(0.55 * wearableSleep + 0.25 * socialConn + 0.20 * journalingDepth);
    final burnoutRisk = clamp100(
      100 * clamp01(0.65 * (stressScore / 100) + 0.35 * (1 - recoveryIndicator)),
    );

    // Emotional wellness: base wellness + journaling + connection - stress.
    final emotionalWellness = clamp100(
      baseWellness +
          18 * clamp01(journalingDepth) +
          12 * clamp01(socialConn) -
          0.35 * stressScore,
    );

    final confidence = _confidence(
      emotionsCount: emotions.length,
      journalsCount: journals.length,
      activitiesCount: activities.length,
      hasWearables: wearables.isNotEmpty,
    );

    final summary = _buildSummary(
      emotionalWellness: emotionalWellness,
      stress: stressScore,
      burnoutRisk: burnoutRisk,
      stability: stability,
    );

    return WellnessScore(
      emotionalWellness: emotionalWellness,
      stress: stressScore,
      burnoutRisk: burnoutRisk,
      emotionalStability: stability,
      confidence: confidence,
      summary: summary,
      emotionalTrend: _trendFromEmotions(emotions),
      stressTrend: _stressTrendFromEmotions(emotions),
    );
  }

  double _confidence({
    required int emotionsCount,
    required int journalsCount,
    required int activitiesCount,
    required bool hasWearables,
  }) {
    // Simple completeness + agreement heuristic.
    final inputs =
        (emotionsCount > 8 ? 0.35 : 0.15) +
        (journalsCount > 3 ? 0.25 : 0.10) +
        (activitiesCount > 8 ? 0.25 : 0.10) +
        (hasWearables ? 0.15 : 0.05);
    return clamp01(inputs);
  }

  String _buildSummary({
    required double emotionalWellness,
    required double stress,
    required double burnoutRisk,
    required double stability,
  }) {
    final parts = <String>[];
    if (stress >= 70) parts.add('Elevated stress indicators recently');
    if (burnoutRisk >= 70) parts.add('Burnout-risk indicators trending higher');
    if (stability <= 40) parts.add('Emotional stability looks more variable');
    if (emotionalWellness >= 70) parts.add('Wellness indicators are relatively strong');
    if (parts.isEmpty) parts.add('Wellness indicators look steady');
    return parts.join(' • ');
  }

  List<TimeSeriesPoint> _trendFromEmotions(List<EmotionalSignal> emotions) {
    if (emotions.isEmpty) return const [];
    final sorted = emotions.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return sorted
        .map((e) => TimeSeriesPoint(
              timestamp: e.timestamp,
              value: clamp100((e.valence + 1) * 50),
            ))
        .toList(growable: false);
  }

  List<TimeSeriesPoint> _stressTrendFromEmotions(List<EmotionalSignal> emotions) {
    if (emotions.isEmpty) return const [];
    final sorted = emotions.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    // A simple instantaneous stress proxy based on negative valence * intensity.
    return sorted
        .map((e) => TimeSeriesPoint(
              timestamp: e.timestamp,
              value: clamp100(100 * clamp01((-e.valence) * 0.6 + e.intensity * 0.4)),
            ))
        .toList(growable: false);
  }
}

