import 'risk_tier.dart';

/// Non-diagnostic emotional context used to adapt tone/pacing safely.
class EmotionalContext {
  /// 0..100 indicators.
  final double stressScore;
  final double burnoutRiskScore;
  final double emotionalStabilityScore;

  /// Optional coarse risk tier.
  final RiskTier? relapseRiskTier;

  /// Optional tags such as "overwhelmed", "anxious", "numb".
  final List<String> tags;

  /// 0..1 confidence in the context (signal completeness).
  final double confidence;

  const EmotionalContext({
    required this.stressScore,
    required this.burnoutRiskScore,
    required this.emotionalStabilityScore,
    this.relapseRiskTier,
    this.tags = const [],
    this.confidence = 0.5,
  });

  EmotionalContext copyWith({
    double? stressScore,
    double? burnoutRiskScore,
    double? emotionalStabilityScore,
    RiskTier? relapseRiskTier,
    List<String>? tags,
    double? confidence,
  }) {
    return EmotionalContext(
      stressScore: stressScore ?? this.stressScore,
      burnoutRiskScore: burnoutRiskScore ?? this.burnoutRiskScore,
      emotionalStabilityScore: emotionalStabilityScore ?? this.emotionalStabilityScore,
      relapseRiskTier: relapseRiskTier ?? this.relapseRiskTier,
      tags: tags ?? this.tags,
      confidence: confidence ?? this.confidence,
    );
  }
}

