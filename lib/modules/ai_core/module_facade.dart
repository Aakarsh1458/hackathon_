import 'package:flutter/material.dart';

import '../../shared/interfaces/module_registration_bus.dart';
import '../../shared/interfaces/wellness_module_contract.dart';

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
    final cfg = config ?? GroqConfig.fromEnvironment();

    if (cfg.apiKey == null || cfg.apiKey!.isEmpty || cfg.modelName == null || cfg.modelName!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('AI Core'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.api_outlined,
                          size: 44, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Groq AI is not configured for this build.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set environment values (example):\n'
                        '- `GROQ_API_KEY`\n'
                        '- `MODEL_NAME`\n\n'
                        'This module never stores or hardcodes secrets.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final aiProvider = GroqAIProvider(config: cfg);
    final chatService = WellnessChatService(
      aiProvider: aiProvider,
      emotionalContextService: const EmotionalContextService(),
      promptBuilder: const WellnessPromptBuilder(),
      recommendationEngine: RecommendationEngine(),
      crisisEscalation: const CrisisEscalation(),
      modelName: cfg.modelName ?? '',
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

