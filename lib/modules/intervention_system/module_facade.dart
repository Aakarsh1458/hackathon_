import 'package:flutter/material.dart';

import '../../shared/interfaces/module_registration_bus.dart';
import '../../shared/interfaces/wellness_module_contract.dart';
import 'providers/intervention_provider.dart';
import 'screens/intervention_hub_screen.dart';

class InterventionSystemModuleFacade implements WellnessModuleContract {
  InterventionSystemModuleFacade({
    InterventionProvider? provider,
  }) : _provider = provider ?? InterventionProvider();

  final InterventionProvider _provider;

  @override
  String get moduleId => 'intervention_system';

  @override
  String get displayName => 'Intervention System';

  @override
  Widget buildRoot(BuildContext context) {
    return InterventionHubScreen(provider: _provider);
  }

  @override
  Future<void> onDispose() async {}

  void register() {
    ModuleRegistrationBus.instance.register(this);
  }
}
