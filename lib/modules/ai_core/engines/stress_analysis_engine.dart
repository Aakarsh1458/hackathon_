import '../models/stress_analysis.dart';
import '../models/time_series_point.dart';
import '../services/signal_sources.dart';
import '../utils/math_utils.dart';

class StressAnalysisEngine {
  const StressAnalysisEngine();

  StressAnalysis compute({
    required List<ActivitySignal> activities,
    List<WearableSignal> wearables = const [],
  }) {
    final activityLevel = mean(activities.map((a) => a.activityLevel));
    final activityVar = stdDev(activities.map((a) => a.activityLevel));
    final lateNightRate =
        safeDiv(activities.where((a) => a.isLateNight).length.toDouble(),
            activities.length.toDouble(),
            fallback: 0);
    final socialConn = mean(activities.map((a) => a.socialConnection));

    final wearableStress = mean(wearables.map((w) => w.stressProxy));
    final wearableSleep = mean(wearables.map((w) => w.sleepQuality));

    final strain = clamp100(
      100 *
          clamp01(
            0.35 * clamp01(activityVar) +
                0.30 * clamp01(lateNightRate) +
                0.20 * clamp01(wearableStress) +
                0.15 * clamp01(1 - socialConn),
          ),
    );

    final stress = clamp100(
      100 *
          clamp01(
            0.45 * clamp01(wearableStress) +
                0.25 * clamp01(lateNightRate) +
                0.15 * clamp01(activityVar) +
                0.15 * clamp01(1 - wearableSleep),
          ),
    );

    final recovery = clamp100(
      100 *
          clamp01(
            0.45 * clamp01(wearableSleep) +
                0.30 * clamp01(socialConn) +
                0.25 * clamp01(activityLevel),
          ),
    );

    final confidence = clamp01(
      (activities.length > 8 ? 0.6 : 0.35) + (wearables.isNotEmpty ? 0.4 : 0.15),
    );

    final summary = _summary(stress, strain, recovery);

    return StressAnalysis(
      stressScore: stress,
      strainScore: strain,
      recoveryScore: recovery,
      confidence: confidence,
      summary: summary,
      stressTrend: _trend(activities, wearables),
    );
  }

  String _summary(double stress, double strain, double recovery) {
    final parts = <String>[];
    if (stress >= 70) parts.add('Stress indicators look elevated');
    if (strain >= 70) parts.add('Strain patterns appear higher');
    if (recovery >= 70) parts.add('Recovery indicators look supportive');
    if (parts.isEmpty) parts.add('Stress indicators look manageable');
    return parts.join(' • ');
  }

  List<TimeSeriesPoint> _trend(
    List<ActivitySignal> activities,
    List<WearableSignal> wearables,
  ) {
    final points = <TimeSeriesPoint>[];
    for (final a in activities) {
      final late = a.isLateNight ? 1.0 : 0.0;
      points.add(TimeSeriesPoint(
        timestamp: a.timestamp,
        value: clamp100(100 * clamp01(0.45 * late + 0.25 * (1 - a.socialConnection) + 0.30 * (a.activityLevel))),
      ));
    }
    for (final w in wearables) {
      points.add(TimeSeriesPoint(
        timestamp: w.timestamp,
        value: clamp100(100 * clamp01(0.65 * w.stressProxy + 0.35 * (1 - w.sleepQuality))),
      ));
    }
    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return points;
  }
}

