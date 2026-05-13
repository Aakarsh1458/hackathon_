import '../models/emotional_signal.dart';
import '../models/relapse_risk.dart';
import '../models/risk_tier.dart';
import '../services/signal_sources.dart';
import '../utils/math_utils.dart';

class RelapseRiskEngine {
  const RelapseRiskEngine();

  RelapseRisk estimate({
    required List<EmotionalSignal> emotions,
    required List<ActivitySignal> activities,
    required List<JournalEntrySignal> journals,
  }) {
    final v = emotions.map((e) => e.valence).toList(growable: false);
    final intensity = emotions.map((e) => e.intensity).toList(growable: false);

    final vMean = mean(v); // -1..1
    final vStd = stdDev(v);
    final intensityMean = mean(intensity);

    final lateNightRate =
        safeDiv(activities.where((a) => a.isLateNight).length.toDouble(),
            activities.length.toDouble(),
            fallback: 0);
    final socialConn = mean(activities.map((a) => a.socialConnection));
    final activityVar = stdDev(activities.map((a) => a.activityLevel));

    final journalingConsistency = mean(journals.map((j) => j.consistency));
    final negativeSpikeRate = _negativeSpikeRate(emotions);
    final deterioration = _trendDeterioration(emotions);

    // Risk components (0..1)
    final instability = clamp01(0.55 * clamp01(vStd) + 0.45 * clamp01(intensityMean));
    final isolation = clamp01(1 - socialConn);
    final lateNight = clamp01(lateNightRate);
    final inconsistency = clamp01(0.55 * clamp01(activityVar) + 0.45 * clamp01(1 - journalingConsistency));
    final negativePressure = clamp01((-vMean) * 0.7 + 0.3 * negativeSpikeRate);
    final trendRisk = clamp01(deterioration);

    final score = clamp01(
      0.22 * instability +
          0.18 * negativePressure +
          0.17 * isolation +
          0.15 * lateNight +
          0.15 * inconsistency +
          0.13 * trendRisk,
    );

    final tier = score >= 0.72
        ? RiskTier.high
        : (score >= 0.42 ? RiskTier.medium : RiskTier.low);

    final confidence = _confidence(
      emotionsCount: emotions.length,
      activitiesCount: activities.length,
      journalsCount: journals.length,
    );

    final factors = <String>[
      if (instability >= 0.6) 'Emotional variability increased',
      if (negativeSpikeRate >= 0.35) 'Negative spikes appear more frequent',
      if (isolation >= 0.6) 'Connection indicators look lower',
      if (lateNight >= 0.35) 'Late-night activity is more present',
      if (inconsistency >= 0.6) 'Behavior consistency looks uneven',
      if (trendRisk >= 0.55) 'Recent emotional trend looks more difficult',
    ];

    final summary = _summary(tier, confidence, factors);

    return RelapseRisk(
      tier: tier,
      score: score,
      confidence: confidence,
      summary: summary,
      factors: factors,
    );
  }

  double _confidence({
    required int emotionsCount,
    required int activitiesCount,
    required int journalsCount,
  }) {
    final c =
        (emotionsCount > 10 ? 0.45 : 0.22) +
        (activitiesCount > 10 ? 0.35 : 0.18) +
        (journalsCount > 3 ? 0.20 : 0.10);
    return clamp01(c);
  }

  double _negativeSpikeRate(List<EmotionalSignal> emotions) {
    if (emotions.isEmpty) return 0;
    final spikes = emotions.where((e) => e.valence <= -0.6 && e.intensity >= 0.6).length;
    return clamp01(safeDiv(spikes.toDouble(), emotions.length.toDouble(), fallback: 0));
  }

  double _trendDeterioration(List<EmotionalSignal> emotions) {
    if (emotions.length < 6) return 0;
    final sorted = emotions.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final half = (sorted.length / 2).floor();
    final firstMean = mean(sorted.take(half).map((e) => e.valence));
    final secondMean = mean(sorted.skip(half).map((e) => e.valence));
    // Deterioration if valence drops in the second half.
    final drop = (firstMean - secondMean); // positive => worse
    return clamp01(drop); // rough map into 0..1
  }

  String _summary(RiskTier tier, double confidence, List<String> factors) {
    final tierLabel = switch (tier) {
      RiskTier.low => 'Low',
      RiskTier.medium => 'Medium',
      RiskTier.high => 'High',
    };
    final confPct = (confidence * 100).round();
    final factorSnippet = factors.isEmpty ? 'Signals look relatively steady' : factors.take(2).join(' • ');
    return '$tierLabel relapse-risk indicator • $confPct% confidence • $factorSnippet';
  }
}

