import 'package:flutter/material.dart';

import 'module_container_base.dart';

class AICoreContainer extends StatelessWidget {
  const AICoreContainer({
    super.key,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ModuleContainer(
      moduleId: 'ai_core',
      fallbackTitle: 'AI Core',
      fallbackDescription:
          'Awaiting module drop-in at `lib/modules/ai_core/`.\n'
          'Expose a facade implementing `WellnessModuleContract` and register it.',
      fallbackIcon: Icons.hub_outlined,
      isLoading: isLoading,
    );
  }
}
