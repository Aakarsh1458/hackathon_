import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DemoMetrics {
  const DemoMetrics({
    required this.wellnessScore,
    required this.stressIndex,
    required this.recoveryProgress,
    required this.streakDays,
    required this.trend,
  });

  /// 0..100
  final int wellnessScore;

  /// 0..100 (higher = more stress)
  final int stressIndex;

  /// 0..1
  final double recoveryProgress;

  final int streakDays;

  /// 12-point normalized trend (0..1)
  final List<double> trend;
}

final demoMetricsProvider = StateNotifierProvider<DemoMetricsNotifier, DemoMetrics>(
  (ref) => DemoMetricsNotifier(ref),
);

class DemoMetricsNotifier extends StateNotifier<DemoMetrics> {
  DemoMetricsNotifier(this._ref)
      : super(
          DemoMetrics(
            wellnessScore: 72,
            stressIndex: 44,
            recoveryProgress: 0.58,
            streakDays: 6,
            trend: const [0.50, 0.52, 0.49, 0.55, 0.54, 0.60, 0.58, 0.61, 0.66, 0.64, 0.68, 0.72],
          ),
        ) {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
    _ref.onDispose(() => _timer.cancel());
  }

  final Ref _ref;
  late final Timer _timer;
  final _rng = Random();

  void _tick() {
    int clampInt(int v) => v.clamp(0, 100);
    double clamp01(double v) => max(0, min(1, v));

    final nextWellness = clampInt(state.wellnessScore + _rng.nextInt(7) - 3);
    final nextStress = clampInt(state.stressIndex + _rng.nextInt(9) - 4);
    final nextProgress = clamp01(state.recoveryProgress + (_rng.nextDouble() * 0.04 - 0.015));

    final nextTrend = [
      ...state.trend.skip(1),
      clamp01((state.trend.last + (_rng.nextDouble() * 0.10 - 0.04))),
    ];

    state = DemoMetrics(
      wellnessScore: nextWellness,
      stressIndex: nextStress,
      recoveryProgress: nextProgress,
      streakDays: state.streakDays,
      trend: nextTrend,
    );
  }

  void bumpStreak() {
    state = DemoMetrics(
      wellnessScore: state.wellnessScore,
      stressIndex: state.stressIndex,
      recoveryProgress: state.recoveryProgress,
      streakDays: state.streakDays + 1,
      trend: state.trend,
    );
  }
}

