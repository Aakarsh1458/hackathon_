import '../models/risk_analysis.dart';
import '../services/signal_sources.dart';
import 'prediction_engine.dart';
import 'relapse_risk_engine.dart';
import 'stress_analysis_engine.dart';
import 'trigger_pattern_engine.dart';
import 'wellness_scoring_engine.dart';

/// Default local orchestration pipeline. AI-ready and integration friendly.
class AiCorePredictionEngine implements PredictionEngine {
  final WellnessScoringEngine wellnessEngine;
  final StressAnalysisEngine stressEngine;
  final RelapseRiskEngine relapseEngine;
  final TriggerPatternEngine patternEngine;

  const AiCorePredictionEngine({
    this.wellnessEngine = const WellnessScoringEngine(),
    this.stressEngine = const StressAnalysisEngine(),
    this.relapseEngine = const RelapseRiskEngine(),
    this.patternEngine = const TriggerPatternEngine(),
  });

  @override
  Future<RiskAnalysis> run({
    required DateTime from,
    required DateTime to,
    required EmotionSignalSource emotionSource,
    required JournalSignalSource journalSource,
    required ActivitySignalSource activitySource,
    WearableSignalSource? wearableSource,
  }) async {
    final emotions = await emotionSource.fetchSignals(from: from, to: to);
    final journals = await journalSource.fetchJournalSignals(from: from, to: to);
    final activities = await activitySource.fetchActivitySignals(from: from, to: to);
    final wearables = wearableSource == null
        ? const <WearableSignal>[]
        : await wearableSource.fetchWearableSignals(from: from, to: to);

    final wellness = wellnessEngine.compute(
      emotions: emotions,
      journals: journals,
      activities: activities,
      wearables: wearables,
    );

    final stress = stressEngine.compute(
      activities: activities,
      wearables: wearables,
    );

    final relapseRisk = relapseEngine.estimate(
      emotions: emotions,
      activities: activities,
      journals: journals,
    );

    final patterns = patternEngine.detectPatterns(
      emotions: emotions,
      activities: activities,
      journals: journals,
    );

    final insights = <String>[
      wellness.summary,
      stress.summary,
      relapseRisk.summary,
      if (patterns.isNotEmpty) 'Patterns detected: ${patterns.take(3).map((p) => p.title).join(', ')}',
    ];

    return RiskAnalysis(
      wellness: wellness,
      stress: stress,
      relapseRisk: relapseRisk,
      patterns: patterns,
      recoveryInsights: insights,
    );
  }
}

