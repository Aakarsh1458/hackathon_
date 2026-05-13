import '../chat/chat_models.dart';

/// Builds deterministic recommendations for the UI from emotional context.
///
/// This never claims medical certainty or diagnosis.
class RecommendationEngine {
  RecommendationEngine();

  List<WellnessRecommendation> build({
    required EmotionalContext context,
    required bool crisisMode,
  }) {
    if (crisisMode) {
      return const [
        WellnessRecommendation(
          title: 'Reach trusted help now',
          body: 'If you’re in immediate danger, call your local emergency number. Otherwise, consider reaching out to a trusted person nearby.',
          severity: 2,
          category: 'crisis',
        ),
        WellnessRecommendation(
          title: 'Create immediate safety',
          body: 'If possible, move toward a safer environment and reduce access to anything that could be used to harm yourself.',
          severity: 2,
          category: 'safety',
        ),
      ];
    }

    final score = context.wellnessScore ?? 50;
    final stress = context.stressIndex ?? 50;
    final progress = context.recoveryProgress ?? 0.5;
    final relapseRisk = context.relapseRisk ?? 0.35;

    final highStress = stress >= 70;
    final lowProgress = progress <= 0.35;
    final higherRelapseRisk = relapseRisk >= 0.65;

    final recs = <WellnessRecommendation>[];

    if (highStress) {
      recs.add(
        WellnessRecommendation(
          title: 'Grounding reset (2 minutes)',
          body:
              'Try a slow breathing cycle: inhale 4 seconds, exhale 6 seconds for 3 rounds. Then name 3 things you can see, 2 you can feel, 1 you can hear.',
          severity: 1,
          category: 'grounding',
        ),
      );
    } else {
      recs.add(
        WellnessRecommendation(
          title: 'Gentle check-in',
          body:
              'What is one feeling you can acknowledge without judging it? Then choose one tiny action that supports you over the next hour.',
          severity: 0,
          category: 'reflection',
        ),
      );
    }

    if (lowProgress) {
      recs.add(
        WellnessRecommendation(
          title: 'Small recovery step',
          body:
              'Pick one “good enough” step: drink water, stretch for 2 minutes, or write one sentence about what felt heavy today.',
          severity: 1,
          category: 'recovery',
        ),
      );
    }

    if (higherRelapseRisk) {
      recs.add(
        WellnessRecommendation(
          title: 'Support during vulnerable moments',
          body:
              'If you notice you’re heading into a difficult moment, try reaching out to a trusted person or change your environment for 10 minutes.',
          severity: 1,
          category: 'support',
        ),
      );
    }

    // Always include journaling prompt.
    final prompt = score >= 70
        ? 'What helped you feel steadier today, and how can you repeat the smallest part of it tomorrow?'
        : 'If today feels hard, what is one kind thing you’d say to a friend in your exact situation?';

    recs.add(
      WellnessRecommendation(
        title: 'Journaling prompt',
        body: prompt,
        severity: 0,
        category: 'journal',
      ),
    );

    return recs;
  }
}

