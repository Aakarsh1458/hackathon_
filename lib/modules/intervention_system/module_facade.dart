import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/interfaces/module_registration_bus.dart';
import '../../shared/interfaces/wellness_module_contract.dart';
import '../../shared/providers/app_state_provider.dart';
import 'models/emotional_context.dart';
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
    final s = app.stressScore;
    final next = EmotionalContext(
      stressLevel: s,
      emotionalOverload: s,
      emotionalStability: (1.0 - s * 0.75).clamp(0.0, 1.0),
      fatigue: (0.2 + s * 0.55 + (1.0 - app.recoveryProgress) * 0.25)
          .clamp(0.0, 1.0),
      wellnessScore: (1.0 - s * 0.6).clamp(0.0, 1.0),
    );
    // Never call [ChangeNotifier.notifyListeners] (or other providers) synchronously from build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.updateContext(next);
    });
    return InterventionHubScreen(provider: provider);
  }
}
