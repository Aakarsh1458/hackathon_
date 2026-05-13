import 'package:flutter/material.dart';

import '../../widgets/app_gradient_background.dart';
import '../../widgets/wellness_preview_video.dart';
import '../../widgets/module_containers/companion_container.dart';

/// Companion module mounted full-width under the shell.
class CompanionModuleScreen extends StatelessWidget {
  const CompanionModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Companion',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Presence and prompts from the companion module.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 14),
                    const WellnessPreviewVideo(compact: true),
                    const SizedBox(height: 18),
                    const CompanionContainer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
