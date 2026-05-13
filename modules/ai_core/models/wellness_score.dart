import 'time_series_point.dart';

/// Not a diagnosis. This is a set of wellness indicators computed from signals.
class WellnessScore {
  /// 0..100 (higher = better indicator)
  final double emotionalWellness;

  /// 0..100 (higher = more stress indicator)
  final double stress;

  /// 0..100 (higher = higher burnout-risk indicator)
  final double burnoutRisk;

  /// 0..100 (higher = more stable indicator)
  final double emotionalStability;

  /// How sure the engine is that the inputs were sufficient (0..1).
  final double confidence;

  /// Short, non-clinical summary for UI.
  final String summary;

  /// Optional trend points for dashboard widgets.
  final List<TimeSeriesPoint> emotionalTrend;
  final List<TimeSeriesPoint> stressTrend;

  const WellnessScore({
    required this.emotionalWellness,
    required this.stress,
    required this.burnoutRisk,
    required this.emotionalStability,
    required this.confidence,
    required this.summary,
    this.emotionalTrend = const [],
    this.stressTrend = const [],
  });
}

