import 'package:flutter/material.dart';

import '../../../shared/interfaces/module_registration_bus.dart';
import '../../../shared/interfaces/wellness_module_contract.dart';

class ModuleContainer extends StatelessWidget {
  const ModuleContainer({
    super.key,
    required this.moduleId,
    required this.fallbackTitle,
    required this.fallbackDescription,
    required this.fallbackIcon,
    this.isLoading = false,
  });

  final String moduleId;
  final String fallbackTitle;
  final String fallbackDescription;
  final IconData fallbackIcon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _ModuleLoading(title: fallbackTitle);
    }

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
    } catch (_) {
      return _ModuleFallback(
        title: '${module.displayName} unavailable',
        description:
            'The module facade loaded, but its UI failed to build. Check module logs.',
        icon: Icons.warning_amber_rounded,
      );
    }
  }
}

class _ModuleLoading extends StatelessWidget {
  const _ModuleLoading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: scheme.surfaceContainerHighest.withOpacity(0.28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Loading $title...'),
          ],
        ),
      ),
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
