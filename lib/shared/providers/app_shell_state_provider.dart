import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal cross-cutting shell flags — extend for sync signals without pulling module logic.
///
/// TODO: Wire to Firestore / backend when emotional wellness sync is defined by product.
class AppShellState {
  const AppShellState({
    this.onboardingComplete = false,
    this.lastSyncedAt,
    this.remoteConfigReady = false,
  });

  final bool onboardingComplete;
  final DateTime? lastSyncedAt;
  final bool remoteConfigReady;

  AppShellState copyWith({
    bool? onboardingComplete,
    DateTime? lastSyncedAt,
    bool? remoteConfigReady,
  }) {
    return AppShellState(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      remoteConfigReady: remoteConfigReady ?? this.remoteConfigReady,
    );
  }
}

class AppShellStateNotifier extends StateNotifier<AppShellState> {
  AppShellStateNotifier() : super(const AppShellState());

  void completeOnboarding() {
    state = state.copyWith(onboardingComplete: true);
  }

  /// Placeholder for future sync pulse — modules consume via Riverpod override if needed.
  void markSynced(DateTime at) {
    state = state.copyWith(lastSyncedAt: at);
  }

  void setRemoteConfigReady(bool value) {
    state = state.copyWith(remoteConfigReady: value);
  }
}

final appShellStateProvider =
    StateNotifierProvider<AppShellStateNotifier, AppShellState>((ref) {
  return AppShellStateNotifier();
});
