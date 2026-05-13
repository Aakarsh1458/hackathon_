import 'package:flutter/material.dart';

import 'module_container_base.dart';

class EmotionModuleContainer extends StatelessWidget {
  const EmotionModuleContainer({
    super.key,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ModuleContainer(
      moduleId: 'emotion_engine',
      fallbackTitle: 'Emotion Engine',
      fallbackDescription:
          'Awaiting module drop-in at `lib/modules/emotion_engine/`.\n'
          'Expose a facade implementing `WellnessModuleContract` and register it.',
      fallbackIcon: Icons.blur_on_rounded,
      isLoading: isLoading,
    );
  }
}
