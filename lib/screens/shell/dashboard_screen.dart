import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/app_gradient_background.dart';
import '../../shared/providers/auth_dependency_providers.dart';
import '../../shared/providers/theme_mode_provider.dart';

/// Placeholder landing — reserved slots for modules; no feature logic here.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final layout = screenClassOf(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: layout == ScreenClass.expanded ? 960 : 640,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Home',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reserved module slots — teams integrate via '
                      '[WellnessModuleContract] without modifying this screen.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 20),
                    _ModulePlaceholderCard(
                      title: 'Emotion engine',
                      subtitle: 'Folder: lib/modules/emotion_engine/',
                      icon: Icons.blur_on_rounded,
                    ),
                    const SizedBox(height: 12),
                    _ModulePlaceholderCard(
                      title: 'AI core',
                      subtitle: 'Folder: lib/modules/ai_core/',
                      icon: Icons.hub_outlined,
                    ),
                    const SizedBox(height: 12),
                    _ModulePlaceholderCard(
                      title: 'Companion system',
                      subtitle: 'Folder: lib/modules/companion_system/',
                      icon: Icons.favorite_outline,
                    ),
                    const SizedBox(height: 12),
                    _ModulePlaceholderCard(
                      title: 'Intervention system',
                      subtitle: 'Folder: lib/modules/intervention_system/',
                      icon: Icons.shield_outlined,
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
}

class _ModulePlaceholderCard extends StatelessWidget {
  const _ModulePlaceholderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withOpacity(0.45),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: scheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
