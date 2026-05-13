import '../models/relapse_risk.dart';
import '../models/stress_analysis.dart';
import '../models/wellness_score.dart';
import '../utils/math_utils.dart';

class WellnessRecommendation {
  final String id;
  final String title;
  final String description;
  final List<String> tags;

  /// 0..1
  final double priority;

  const WellnessRecommendation({
    required this.id,
    required this.title,
    required this.description,
    this.tags = const [],
    required this.priority,
  });
}

/// Public export required by the module contract.
abstract class RecommendationService {
  List<WellnessRecommendation> recommend({
    required WellnessScore wellness,
    required StressAnalysis stress,
    required RelapseRisk relapseRisk,
  });
}

/// Default, local, explainable recommendation logic.
class DefaultRecommendationService implements RecommendationService {
  const DefaultRecommendationService();

  @override
  List<WellnessRecommendation> recommend({
    required WellnessScore wellness,
    required StressAnalysis stress,
    required RelapseRisk relapseRisk,
  }) {
    final recs = <WellnessRecommendation>[];

    final stressLevel = clamp01(stress.stressScore / 100);
    final burnout = clamp01(wellness.burnoutRisk / 100);
    final lowStability = clamp01(1 - (wellness.emotionalStability / 100));
    final relapse = clamp01(relapseRisk.score);

    // Grounding / breathing
    final groundingPriority = clamp01(0.45 * stressLevel + 0.35 * lowStability + 0.20 * relapse);
    if (groundingPriority >= 0.35) {
      recs.add(WellnessRecommendation(
        id: 'grounding_60s',
        title: '60-second grounding',
        description: 'Name 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste.',
        tags: const ['grounding', 'stress'],
        priority: groundingPriority,
      ));
      recs.add(WellnessRecommendation(
        id: 'box_breathing',
        title: 'Box breathing (2 minutes)',
        description: 'Inhale 4 • Hold 4 • Exhale 4 • Hold 4. Repeat gently.',
        tags: const ['breathing', 'regulation'],
        priority: clamp01(groundingPriority - 0.05),
      ));
    }

    // Journaling prompt
    final journalPriority = clamp01(0.35 * relapse + 0.35 * lowStability + 0.30 * burnout);
    if (journalPriority >= 0.30) {
      recs.add(WellnessRecommendation(
        id: 'journal_prompt',
        title: 'Quick journal check-in',
        description: 'What’s the hardest moment today, and what would help 5%?',
        tags: const ['journaling', 'reflection'],
        priority: journalPriority,
      ));
    }

    // Hydration / micro-breaks
    final microRecoveryPriority = clamp01(0.55 * stressLevel + 0.45 * burnout);
    if (microRecoveryPriority >= 0.35) {
      recs.add(WellnessRecommendation(
        id: 'hydration',
        title: 'Hydration reminder',
        description: 'Drink a glass of water, then take 5 slow breaths.',
        tags: const ['hydration', 'micro_recovery'],
        priority: clamp01(microRecoveryPriority - 0.05),
      ));
      recs.add(WellnessRecommendation(
        id: 'focus_reset',
        title: 'Focus recovery (3 minutes)',
        description: 'Stand, stretch shoulders/neck, and do a short walk if possible.',
        tags: const ['focus', 'movement'],
        priority: microRecoveryPriority,
      ));
    }

    // Sleep recovery suggestion when late-night + stress patterns appear (inferred from stress).
    final sleepPriority = clamp01(0.50 * stressLevel + 0.25 * relapse + 0.25 * burnout);
    if (sleepPriority >= 0.45) {
      recs.add(WellnessRecommendation(
        id: 'sleep_recovery',
        title: 'Sleep recovery',
        description: 'If you can, aim for a calmer wind-down: dim lights, reduce scrolling, and try a 5-minute breathing reset.',
        tags: const ['sleep', 'routine'],
        priority: sleepPriority,
      ));
    }

    recs.sort((a, b) => b.priority.compareTo(a.priority));
    return recs.take(6).toList(growable: false);
  }
}

