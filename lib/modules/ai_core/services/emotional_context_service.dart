import '../chat/chat_models.dart';

/// Normalizes context for prompt rendering.
class EmotionalContextService {
  const EmotionalContextService();

  EmotionalContext normalize(EmotionalContext context) {
    // Keep safe defaults and never “invent” missing data.
    return EmotionalContext(
      wellnessScore: context.wellnessScore,
      stressIndex: context.stressIndex,
      recoveryProgress: context.recoveryProgress,
      burnoutIndicators: context.burnoutIndicators,
      relapseRisk: context.relapseRisk,
      emotionalTrends: context.emotionalTrends,
      journalingHints: context.journalingHints,
    );
  }
}

