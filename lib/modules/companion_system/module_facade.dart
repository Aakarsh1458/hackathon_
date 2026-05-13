import 'package:flutter/material.dart';

import '../../shared/interfaces/module_registration_bus.dart';
import '../../shared/interfaces/wellness_module_contract.dart';
import 'companion_panel.dart';

class CompanionModuleFacade implements WellnessModuleContract {
  const CompanionModuleFacade();

  @override
  String get moduleId => 'companion_system';

  @override
  String get displayName => 'Companion';

  @override
  Widget buildRoot(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(14),
      child: CompanionPanel(),
    );
  }

  @override
  Future<void> onDispose() async {}

  void register() {
    ModuleRegistrationBus.instance.register(this);
  }
}

// Placeholder removed: module now renders a safe panel.
