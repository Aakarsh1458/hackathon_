import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/interfaces/module_registration_bus.dart';
import '../../shared/interfaces/wellness_module_contract.dart';
import '../../shared/providers/app_state_provider.dart';
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
    return _InterventionBridge(provider: _provider);
  }

  @override
  Future<void> onDispose() async {}

  void register() {
    ModuleRegistrationBus.instance.register(this);
  }
}

class _InterventionBridge extends ConsumerWidget {
  const _InterventionBridge({required this.provider});
  final InterventionProvider provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appStateProvider);
    // Minimal context mapping to keep things reactive without coupling.
    provider.updateContext(
      EmotionalContext(
        stressScore: (app.stressScore * 100).round(),
        emotionalStability: (100 - (app.stressScore * 75)).round().clamp(0, 100),
        overloadRisk: (app.stressScore * 100).round(),
      ),
    );
    return InterventionHubScreen(provider: provider);
  }
}
