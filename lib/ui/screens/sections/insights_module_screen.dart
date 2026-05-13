import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modules/emotion_engine/emotion_app_state_bridge.dart';
import '../../../modules/emotion_engine/lib/screens/emotion_dashboard_screen.dart';
import '../../../shared/providers/emotion_engine_service_provider.dart';

/// Full “signal studio” surface — emotional insights + live tooling.
class InsightsModuleScreen extends ConsumerWidget {
  const InsightsModuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(emotionEngineServiceProvider);
    return Scaffold(
      body: EmotionAppStateBridge(
        service: service,
        child: EmotionDashboardScreen(service: service),
      ),
    );
  }
}
