import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modules/emotion_engine/emotion_app_state_bridge.dart';
import '../../../modules/emotion_engine/lib/screens/journal_screen.dart';
import '../../../shared/providers/emotion_engine_service_provider.dart';

/// Journal route backed by the shared emotion engine persistence layer.
class JournalModuleScreen extends ConsumerWidget {
  const JournalModuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(emotionEngineServiceProvider);
    return Scaffold(
      body: EmotionAppStateBridge(
        service: service,
        child: JournalScreen(service: service),
      ),
    );
  }
}
