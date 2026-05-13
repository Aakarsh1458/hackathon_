import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/interfaces/module_registration_bus.dart';
import '../../shared/interfaces/wellness_module_contract.dart';
import 'emotion_app_state_bridge.dart';
import 'lib/screens/emotion_dashboard_screen.dart';
import 'lib/services/emotion_service.dart';

class EmotionEngineModuleFacade implements WellnessModuleContract {
  const EmotionEngineModuleFacade();

  @override
  String get moduleId => 'emotion_engine';

  @override
  String get displayName => 'Emotion Engine';

  @override
  Widget buildRoot(BuildContext context) {
    return const _EmotionModuleRoot();
  }

  @override
  Future<void> onDispose() async {}

  void register() {
    ModuleRegistrationBus.instance.register(this);
  }
}

class _EmotionModuleRoot extends ConsumerStatefulWidget {
  const _EmotionModuleRoot();

  @override
  ConsumerState<_EmotionModuleRoot> createState() => _EmotionModuleRootState();
}

class _EmotionModuleRootState extends ConsumerState<_EmotionModuleRoot> {
  late final EmotionService _service = EmotionService();

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmotionAppStateBridge(
      service: _service,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emotion Engine',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EmotionDashboardScreen(service: _service),
                  ),
                );
              },
              icon: const Icon(Icons.blur_on_rounded),
              label: const Text('Open signal studio'),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _service,
              builder: (context, _) {
                final state = _service.signalState;
                final last = state.liveFaceSignal?.dominant.name ?? 'none';
                final indicator = state.wellnessIndicators.entries.isEmpty
                    ? null
                    : state.wellnessIndicators.entries.first;
                return Text(
                  indicator == null
                      ? 'Live: $last • no indicators yet'
                      : 'Live: $last • ${indicator.key} ${(indicator.value * 100).round()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
