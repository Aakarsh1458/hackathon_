import 'package:flutter/material.dart';

import 'module_container_base.dart';

class CompanionContainer extends StatelessWidget {
  const CompanionContainer({
    super.key,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ModuleContainer(
      moduleId: 'companion_system',
      fallbackTitle: 'Companion',
      fallbackDescription:
          'Awaiting module drop-in at `lib/modules/companion_system/`.\n'
          'Expose a facade implementing `WellnessModuleContract` and register it.',
      fallbackIcon: Icons.favorite_outline,
      isLoading: isLoading,
    );
  }
}
