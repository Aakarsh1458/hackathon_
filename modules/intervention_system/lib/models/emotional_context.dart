import 'package:flutter/foundation.dart';

@immutable
class EmotionalContext {
  const EmotionalContext({
    required this.stressLevel,
    required this.emotionalOverload,
    required this.emotionalStability,
    required this.fatigue,
    required this.wellnessScore,
  });

  final double stressLevel;
  final double emotionalOverload;
  final double emotionalStability;
  final double fatigue;
  final double wellnessScore;

  static const EmotionalContext neutral = EmotionalContext(
    stressLevel: 0.4,
    emotionalOverload: 0.25,
    emotionalStability: 0.6,
    fatigue: 0.35,
    wellnessScore: 0.6,
  );

  bool get isCrisisLikely => emotionalOverload > 0.75 || stressLevel > 0.85;
}
