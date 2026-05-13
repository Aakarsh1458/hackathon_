import 'package:flutter/material.dart';

import '../../shared/interfaces/module_registration_bus.dart';
import '../../shared/interfaces/wellness_module_contract.dart';
import 'ai_core_panel.dart';

/// Module facade for `ai_core`.
///
/// IMPORTANT: Shell integration will be handled by other agents. This facade
/// provides a safe root widget that the shell can mount later.
class AICoreModuleFacade implements WellnessModuleContract {
  const AICoreModuleFacade();

  @override
  String get moduleId => 'ai_core';

  @override
  String get displayName => 'AI Core';

  @override
  Widget buildRoot(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14),
      child: AICorePanel(),
    );
  }

  @override
  Future<void> onDispose() async {}

  void register() {
    ModuleRegistrationBus.instance.register(this);
  }
}

