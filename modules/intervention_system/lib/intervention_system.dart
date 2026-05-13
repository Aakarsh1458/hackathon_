/// Adaptive intervention and emotional environment module.
///
/// This module responds to emotional context signals from external systems and
/// renders supportive wellness interventions.
///
/// TODO(integration): Host app injects emotional context from Emotion Engine.
/// TODO(integration): Host app injects wellness score from AI Core.
/// TODO(integration): Host app injects companion state from Companion System.
library intervention_system;

export 'animations/adaptive_animation_controller.dart';
export 'models/adaptive_theme.dart';
export 'models/crisis_mode.dart';
export 'models/emotional_environment.dart';
export 'models/grounding_system.dart';
export 'models/guardian_mode.dart';
export 'providers/intervention_provider.dart';
export 'screens/intervention_hub_screen.dart';
export 'services/breathing_engine.dart';
export 'services/intervention_service.dart';
export 'utils/ar_vr_hooks.dart';
export 'widgets/intervention_recommendation_widget.dart';
export 'widgets/wellness_overlay.dart';
