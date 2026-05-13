import 'package:flutter/material.dart';

import '../../lib/shared/interfaces/module_registration_bus.dart';
import '../../lib/shared/interfaces/wellness_module_contract.dart';

import 'chat/groq_ai_provider.dart';
import 'chat/groq_config.dart';
import 'chat/ai_provider.dart';
import 'prompt/wellness_prompt_builder.dart';
import 'recommendations/recommendation_engine.dart';
import 'safety/crisis_guard.dart';
import 'services/emotional_context_service.dart';
import 'services/wellness_chat_service.dart';
import 'ui/wellness_chat_widget.dart';

/// Module facade for `ai_core`.
///
/// IMPORTANT: Shell integration will be handled by other agents. This facade
/// provides a safe root widget that the shell can mount later.
class AICoreModuleFacade implements WellnessModuleContract {
  const AICoreModuleFacade({
    this.config,
  });

  final GroqConfig? config;

  @override
  String get moduleId => 'ai_core';

  @override
  String get displayName => 'AI Core';

  @override
  Widget buildRoot(BuildContext context) {
    final cfg = config;
    final aiProvider = GroqAIProvider(config: cfg);
    final chatService = WellnessChatService(
      aiProvider: aiProvider,
      emotionalContextService: const EmotionalContextService(),
      promptBuilder: const WellnessPromptBuilder(),
      recommendationEngine: RecommendationEngine(),
      crisisEscalation: const CrisisEscalation(),
      modelName: cfg?.modelName ?? '',
    );

    return WellnessChatWidget(
      chatService: chatService,
      context: EmotionalContext.empty,
    );
  }

  /// Helper for composition roots.
  ///
  /// Other agents can call this after importing this facade.
  void register() {
    ModuleRegistrationBus.instance.register(this);
  }
}

// Auto-register when the facade is imported.
// Other agents can safely import this file during composition.
final bool _aiCoreAutoRegistered = (() {
  AICoreModuleFacade().register();
  return true;
})();

