import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_state_provider.dart';
import 'chat/chat_models.dart' as legacy_models;
import 'chat/groq_ai_provider.dart';
import 'prompt/wellness_prompt_builder.dart';
import 'recommendations/recommendation_engine.dart';
import 'safety/crisis_guard.dart';
import 'services/emotional_context_service.dart';
import 'services/wellness_chat_service.dart' as legacy_chat;
import 'ui/wellness_chat_widget.dart';

/// Compact panel for dashboard embedding.
class AICorePanel extends ConsumerWidget {
  const AICorePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appStateProvider);
    final scheme = Theme.of(context).colorScheme;

    final legacyContext = legacy_models.EmotionalContext(
      stressIndex: (app.stressScore * 100).round(),
      wellnessScore: (100 - (app.stressScore * 70)).round().clamp(0, 100),
      recoveryProgress: app.recoveryProgress,
      burnoutIndicators: (app.stressScore * 100).round(),
      relapseRisk: (app.stressScore * 0.85).clamp(0.0, 1.0),
      emotionalTrends: [app.emotionalState.name],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Core',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Stress ${(app.stressScore * 100).round()}/100 • State: ${app.emotionalState.name}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => WellnessChatWidget(
                  chatService: _buildLegacyChatService(),
                  context: legacyContext,
                ),
              ),
            );
          },
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: const Text('Open wellness chat'),
        ),
        const SizedBox(height: 10),
        Text(
          'Tip: Add `GROQ_API_KEY` via `.env` or `--dart-define` for live responses. Otherwise, chat uses safe fallbacks.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  legacy_chat.WellnessChatService _buildLegacyChatService() {
    return legacy_chat.WellnessChatService(
      aiProvider: GroqAIProvider(),
      emotionalContextService: const EmotionalContextService(),
      promptBuilder: const WellnessPromptBuilder(),
      recommendationEngine: RecommendationEngine(),
      crisisEscalation: const CrisisEscalation(),
      modelName: '',
    );
  }
}

