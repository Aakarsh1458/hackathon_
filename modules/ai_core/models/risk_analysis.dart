import 'behavioral_pattern.dart';
import 'relapse_risk.dart';
import 'stress_analysis.dart';
import 'wellness_score.dart';

/// Top-level analytics output for dashboards and downstream systems.
///
/// Not a diagnosis. Intended for wellness insights and risk estimation only.
class RiskAnalysis {
  final WellnessScore wellness;
  final StressAnalysis stress;
  final RelapseRisk relapseRisk;

  /// Detected recurring patterns and vulnerable windows.
  final List<BehavioralPattern> patterns;

  /// Explainable insights for the user (recovery-focused, non-clinical).
  final List<String> recoveryInsights;

  const RiskAnalysis({
    required this.wellness,
    required this.stress,
    required this.relapseRisk,
    this.patterns = const [],
    this.recoveryInsights = const [],
  });
}

