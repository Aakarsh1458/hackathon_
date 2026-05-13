import 'time_series_point.dart';

/// Stress indicators derived from behavior/emotion signals (non-diagnostic).
class StressAnalysis {
  /// 0..100 (higher = more stress indicator)
  final double stressScore;

  /// 0..100 (higher = higher workload/strain indicator)
  final double strainScore;

  /// 0..100 (higher = more recovery indicator)
  final double recoveryScore;

  final double confidence;

  final String summary;

  final List<TimeSeriesPoint> stressTrend;

  const StressAnalysis({
    required this.stressScore,
    required this.strainScore,
    required this.recoveryScore,
    required this.confidence,
    required this.summary,
    this.stressTrend = const [],
  });
}

