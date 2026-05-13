import 'package:flutter/material.dart';

import '../../shared/interfaces/module_registration_bus.dart';
import '../../shared/interfaces/wellness_module_contract.dart';

class EmotionEngineModuleFacade implements WellnessModuleContract {
  const EmotionEngineModuleFacade();

  @override
  String get moduleId => 'emotion_engine';

  @override
  String get displayName => 'Emotion Engine';

  @override
  Widget buildRoot(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Emotion engine module connected.\nLive signal UI will be enabled with runtime camera setup.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Future<void> onDispose() async {}

  void register() {
    ModuleRegistrationBus.instance.register(this);
  }
}
