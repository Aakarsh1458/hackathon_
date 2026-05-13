import 'package:flutter/material.dart';

import 'module_container_base.dart';

class InterventionContainer extends StatelessWidget {
  const InterventionContainer({
    super.key,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ModuleContainer(
      moduleId: 'intervention_system',
      fallbackTitle: 'Intervention System',
      fallbackDescription:
          'Awaiting module drop-in at `lib/modules/intervention_system/`.\n'
          'Expose a facade implementing `WellnessModuleContract` and register it.',
      fallbackIcon: Icons.shield_outlined,
      isLoading: isLoading,
    );
  }
}
