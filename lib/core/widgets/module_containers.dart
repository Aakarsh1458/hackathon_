import 'package:flutter/material.dart';

import '../../shared/interfaces/module_registration_bus.dart';
import '../../shared/interfaces/wellness_module_contract.dart';

/// Base safe container for modules — never imports `lib/modules/*`.
class ModuleContainer extends StatelessWidget {
  const ModuleContainer({
    super.key,
    required this.moduleId,
    required this.fallbackTitle,
    required this.fallbackDescription,
    required this.fallbackIcon,
  });

  final String moduleId;
  final String fallbackTitle;
  final String fallbackDescription;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final WellnessModuleContract? module = ModuleRegistrationBus.instance[moduleId];

    if (module == null) {
      return _ModuleFallback(
        title: fallbackTitle,
        description: fallbackDescription,
        icon: fallbackIcon,
      );
    }

    try {
      return module.buildRoot(context);
    } catch (e) {
      return _ModuleFallback(
        title: '${module.displayName} unavailable',
        description:
            'The module facade loaded, but its UI failed to build. Check module logs.',
        icon: Icons.warning_amber_rounded,
      );
    }
  }
}

class EmotionModuleContainer extends StatelessWidget {
  const EmotionModuleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleContainer(
      moduleId: 'emotion_engine',
      fallbackTitle: 'Emotion Engine',
      fallbackDescription:
          'Awaiting module drop-in at `lib/modules/emotion_engine/`.\n'
          'Expose a facade implementing `WellnessModuleContract` and register it.',
      fallbackIcon: Icons.blur_on_rounded,
    );
  }
}

class AICoreContainer extends StatelessWidget {
  const AICoreContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleContainer(
      moduleId: 'ai_core',
      fallbackTitle: 'AI Core',
      fallbackDescription:
          'Awaiting module drop-in at `lib/modules/ai_core/`.\n'
          'Expose a facade implementing `WellnessModuleContract` and register it.',
      fallbackIcon: Icons.hub_outlined,
    );
  }
}

class CompanionModuleContainer extends StatelessWidget {
  const CompanionModuleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleContainer(
      moduleId: 'companion_system',
      fallbackTitle: 'Companion',
      fallbackDescription:
          'Awaiting module drop-in at `lib/modules/companion_system/`.\n'
          'Expose a facade implementing `WellnessModuleContract` and register it.',
      fallbackIcon: Icons.favorite_outline,
    );
  }
}

class InterventionModuleContainer extends StatelessWidget {
  const InterventionModuleContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleContainer(
      moduleId: 'intervention_system',
      fallbackTitle: 'Intervention System',
      fallbackDescription:
          'Awaiting module drop-in at `lib/modules/intervention_system/`.\n'
          'Expose a facade implementing `WellnessModuleContract` and register it.',
      fallbackIcon: Icons.shield_outlined,
    );
  }
}

class _ModuleFallback extends StatelessWidget {
  const _ModuleFallback({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: scheme.surfaceContainerHighest.withOpacity(0.35),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
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

