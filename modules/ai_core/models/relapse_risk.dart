import 'risk_tier.dart';

/// Not a diagnosis. This is a risk estimation indicator to support recovery.
class RelapseRisk {
  final RiskTier tier;

  /// 0..1 likelihood-like indicator (NOT medical certainty).
  final double score;

  /// 0..1 confidence in the estimation (input completeness + signal agreement).
  final double confidence;

  /// Human-friendly, recovery-focused insights.
  final String summary;

  /// Key contributing factors for UI and explainability.
  final List<String> factors;

  const RelapseRisk({
    required this.tier,
    required this.score,
    required this.confidence,
    required this.summary,
    this.factors = const [],
  });
}

