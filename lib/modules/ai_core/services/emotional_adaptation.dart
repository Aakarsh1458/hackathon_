import '../models/emotional_context.dart';
import '../models/risk_tier.dart';
import '../utils/math_utils.dart';

class AdaptationProfile {
  /// 0..1 faster->slower response pacing (lower is calmer/slower).
  final double pacing;

  /// 0..1 shorter->longer response length target.
  final double verbosity;

  /// 0..1 how grounding-forward the assistant should be.
  final double groundingIntensity;

  /// Voice tuning defaults for TTS.
  final double ttsRate; // 0..1
  final double ttsPitch; // 0..2
  final double ttsVolume; // 0..1

  const AdaptationProfile({
    required this.pacing,
    required this.verbosity,
    required this.groundingIntensity,
    required this.ttsRate,
    required this.ttsPitch,
    required this.ttsVolume,
  });
}

class EmotionalAdaptationEngine {
  const EmotionalAdaptationEngine();

  AdaptationProfile compute(EmotionalContext ctx) {
    final stress = clamp01(ctx.stressScore / 100);
    final burnout = clamp01(ctx.burnoutRiskScore / 100);
    final stabilityLow = clamp01(1 - (ctx.emotionalStabilityScore / 100));
    final relapseTier = ctx.relapseRiskTier ?? RiskTier.low;

    final relapseBoost = switch (relapseTier) {
      RiskTier.low => 0.0,
      RiskTier.medium => 0.15,
      RiskTier.high => 0.30,
    };

    // More stress/instability -> slower pacing + shorter responses + stronger grounding.
    final grounding = clamp01(0.45 * stress + 0.35 * stabilityLow + 0.20 * burnout + relapseBoost);
    final pacing = clamp01(1 - (0.55 * stress + 0.25 * stabilityLow + 0.20 * burnout));
    final verbosity = clamp01(0.55 * (1 - stress) + 0.25 * (1 - burnout) + 0.20 * (1 - stabilityLow));

    // TTS: slower and slightly lower pitch for calmness when stress is high.
    final ttsRate = clamp01(lerp(0.52, 0.42, stress));
    final ttsPitch = lerp(1.05, 0.95, clamp01(stress + stabilityLow * 0.5));
    final ttsVolume = 0.95;

    return AdaptationProfile(
      pacing: pacing,
      verbosity: verbosity,
      groundingIntensity: grounding,
      ttsRate: ttsRate,
      ttsPitch: ttsPitch,
      ttsVolume: ttsVolume,
    );
  }
}

