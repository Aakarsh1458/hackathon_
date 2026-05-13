import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_state_provider.dart';
import 'lib/models/emotion_label.dart';
import 'lib/services/emotion_service.dart';

/// Bridges Emotion Engine signals into the shared shell `AppStateNotifier`.
///
/// Keeps modular boundaries: Emotion Engine owns signal generation; the shell
/// owns the cross-module aggregate state.
class EmotionAppStateBridge extends ConsumerStatefulWidget {
  final Widget child;
  final EmotionService service;

  const EmotionAppStateBridge({
    super.key,
    required this.child,
    required this.service,
  });

  @override
  ConsumerState<EmotionAppStateBridge> createState() => _EmotionAppStateBridgeState();
}

class _EmotionAppStateBridgeState extends ConsumerState<EmotionAppStateBridge> {
  @override
  void initState() {
    super.initState();
    widget.service.addListener(_sync);
    _sync();
  }

  @override
  void didUpdateWidget(covariant EmotionAppStateBridge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      oldWidget.service.removeListener(_sync);
      widget.service.addListener(_sync);
      _sync();
    }
  }

  @override
  void dispose() {
    widget.service.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    final state = widget.service.signalState;
    final app = ref.read(appStateProvider);

    // Heuristic stress: prioritize explicit indicators; fallback to label confidence.
    final calmFocus = state.wellnessIndicators['calmFocus'];
    final expressiveEnergy = state.wellnessIndicators['expressiveEnergy'];
    final live = state.liveFaceSignal;

    double stress01 = app.stressScore;
    if (calmFocus != null) {
      stress01 = (1 - calmFocus).clamp(0.0, 1.0);
    } else if (live != null) {
      final stressed = live.confidenceFor(EmotionLabel.stressed);
      final angry = live.confidenceFor(EmotionLabel.angry);
      final sad = live.confidenceFor(EmotionLabel.sad);
      stress01 = (0.55 * stressed + 0.25 * angry + 0.20 * sad).clamp(0.0, 1.0);
    } else if (expressiveEnergy != null) {
      // Treat very low energy as mild fatigue stress (soft signal).
      stress01 = (0.35 + (0.4 * (1 - expressiveEnergy))).clamp(0.0, 1.0);
    }

    app.updateStressScore(stress01);

    final nextState = stress01 >= 0.78
        ? EmotionalState.overloaded
        : (stress01 >= 0.52 ? EmotionalState.elevated : EmotionalState.calm);
    app.updateEmotionalState(nextState);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

