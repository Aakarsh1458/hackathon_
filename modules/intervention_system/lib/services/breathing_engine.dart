import '../models/emotional_context.dart';

class BreathingEngine {
  const BreathingEngine();

  BreathingPattern recommendPattern(EmotionalContext context) {
    if (context.stressLevel > 0.8 || context.emotionalOverload > 0.75) {
      return const BreathingPattern(
        label: 'Calm Reset',
        inhaleSeconds: 4,
        holdSeconds: 4,
        exhaleSeconds: 6,
        cycles: 8,
      );
    }
    if (context.fatigue > 0.7) {
      return const BreathingPattern(
        label: 'Gentle Re-energize',
        inhaleSeconds: 3,
        holdSeconds: 1,
        exhaleSeconds: 4,
        cycles: 6,
      );
    }
    return const BreathingPattern(
      label: 'Balanced Flow',
      inhaleSeconds: 4,
      holdSeconds: 2,
      exhaleSeconds: 4,
      cycles: 5,
    );
  }
}

class BreathingPattern {
  const BreathingPattern({
    required this.label,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.cycles,
  });

  final String label;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int cycles;
}
