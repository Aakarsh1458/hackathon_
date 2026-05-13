import '../models/adaptive_theme.dart';
import '../models/crisis_mode.dart';
import '../models/emotional_context.dart';
import '../models/emotional_environment.dart';
import '../models/grounding_system.dart';
import '../models/guardian_mode.dart';
import 'breathing_engine.dart';
import 'dopamine_recovery_service.dart';

class InterventionService {
  InterventionService({
    BreathingEngine? breathingEngine,
    DopamineRecoveryService? dopamineRecoveryService,
  })  : _breathingEngine = breathingEngine ?? const BreathingEngine(),
        _dopamineRecoveryService =
            dopamineRecoveryService ?? const DopamineRecoveryService();

  final BreathingEngine _breathingEngine;
  final DopamineRecoveryService _dopamineRecoveryService;

  EmotionalEnvironment buildEnvironment(EmotionalContext context) {
    final theme = AdaptiveTheme.fromContext(context);
    return EmotionalEnvironment(
      theme: theme,
      motionPacingSeconds: context.stressLevel > 0.75 ? 2.2 : 1.4,
      overlayOpacity: context.emotionalOverload > 0.65 ? 0.28 : 0.14,
      lowStimulationMode: context.emotionalOverload > 0.7 || context.fatigue > 0.75,
      ambientGlow: context.emotionalStability > 0.7 ? 0.6 : 0.35,
    );
  }

  CrisisMode evaluateCrisisMode(EmotionalContext context) {
    if (!context.isCrisisLikely) {
      return CrisisMode.inactive;
    }
    return const CrisisMode(
      enabled: true,
      minimalUi: true,
      largeActions: true,
      distractionReduction: true,
      quickActions: <String>[
        'Start breathing reset',
        'Open grounding card',
        'Contact trusted support',
      ],
    );
  }

  GroundingSystem buildGroundingPlan(EmotionalContext context) {
    final cycles = context.stressLevel > 0.75 ? 8 : 5;
    return GroundingSystem(
      breathingCycles: cycles,
      focusTimerSeconds: context.fatigue > 0.65 ? 120 : 180,
      mindfulCardPrompts: const <String>[
        'Name 5 things you can see.',
        'Take a slow sip of water.',
        'Place both feet on the ground and breathe.',
      ],
    );
  }

  GuardianMode buildGuardianMode(EmotionalContext context) {
    final active = context.emotionalOverload > 0.6 || context.stressLevel > 0.7;
    return GuardianMode(
      enabled: active,
      pauseSeconds: active ? 20 : 0,
      gentlePrompt: active
          ? 'Pause for a brief reset. You are safe, and this feeling can pass.'
          : 'Keep your momentum with one mindful micro-action.',
      dopamineReplacements: const <String>[
        'Hydration reset',
        '1-minute breathing loop',
        'Short reflection check-in',
        '2-minute walk reminder',
      ],
    );
  }

  BreathingPattern breathingPattern(EmotionalContext context) {
    return _breathingEngine.recommendPattern(context);
  }

  List<String> recommendedInterventions(EmotionalContext context) {
    final interventions = <String>[
      'Guided breathing session',
      'Mindful grounding card',
      'Hydration reminder',
    ];
    if (context.fatigue > 0.65) {
      interventions.add('Low-energy reset flow');
    }
    if (context.emotionalStability > 0.7 && context.stressLevel < 0.45) {
      interventions.add('Momentum micro-goal');
    }
    return interventions;
  }

  List<String> dopamineReplacementSuggestions(EmotionalContext context) {
    return _dopamineRecoveryService.microActions(context);
  }
}
