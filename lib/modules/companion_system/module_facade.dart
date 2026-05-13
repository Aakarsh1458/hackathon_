import 'package:flutter/material.dart';

import '../../shared/interfaces/module_registration_bus.dart';
import '../../shared/interfaces/wellness_module_contract.dart';

class CompanionModuleFacade implements WellnessModuleContract {
  const CompanionModuleFacade();

  @override
  String get moduleId => 'companion_system';

  @override
  String get displayName => 'Companion';

  @override
  Widget buildRoot(BuildContext context) {
    return const _CompanionPlaceholder();
  }

  @override
  Future<void> onDispose() async {}

  void register() {
    ModuleRegistrationBus.instance.register(this);
  }
}

class _CompanionPlaceholder extends StatelessWidget {
  const _CompanionPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Companion system is syncing.\nGentle support reactions will appear here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
