import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/app_shell_state_provider.dart';
import '../../shared/providers/auth_dependency_providers.dart';
import '../../shared/providers/auth_demo_mode_provider.dart';
import '../../shared/providers/auth_session_provider.dart';
import '../layouts/app_shell_scaffold.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/sections/companion_module_screen.dart';
import '../screens/sections/crisis_support_screen.dart';
import '../screens/sections/insights_module_screen.dart';
import '../screens/sections/journal_module_screen.dart';
import '../screens/sections/progress_module_screen.dart';
import '../screens/sections/settings_screen.dart';
import 'route_paths.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final refresh = GoRouterRefreshNotifier(ref, authRepo.authStateChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(authSessionProvider);
      if (session.isLoading) {
        return null;
      }

      final shellState = ref.read(appShellStateProvider);
      final onboardingComplete = shellState.onboardingComplete;

      final user = session.valueOrNull;
      final loc = state.matchedLocation;
      final onboarding = loc == RoutePaths.onboarding;
      final loggingIn = loc == RoutePaths.login;
      final demoMode = ref.read(authDemoModeProvider);
      final firebaseReady = Firebase.apps.isNotEmpty;

      if (!onboardingComplete && !onboarding) {
        return RoutePaths.onboarding;
      }

      // Demo fallback: keep app bootable even if Firebase/auth are incomplete.
      if (user == null && (!firebaseReady || demoMode)) {
        return null;
      }

      if (user == null && !loggingIn && !onboarding) {
        return RoutePaths.login;
      }
      if (user != null && (loggingIn || onboarding)) {
        return RoutePaths.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.insights,
                builder: (context, state) => const InsightsModuleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.journal,
                builder: (context, state) => const JournalModuleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.companion,
                builder: (context, state) => const CompanionModuleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.progress,
                builder: (context, state) => const ProgressModuleScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.crisis,
        builder: (context, state) => const CrisisSupportScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

/// Bridges auth + shell state to GoRouter refresh — shell-only.
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._ref, Stream<dynamic> authStream) {
    notifyListeners();
    _authSubscription = authStream.listen((_) => notifyListeners());
    _shellSubscription = _ref.listen(appShellStateProvider, (prev, next) {
      if (prev?.onboardingComplete != next.onboardingComplete) {
        notifyListeners();
      }
    });
  }

  final Ref _ref;
  late final StreamSubscription<dynamic> _authSubscription;
  late final ProviderSubscription<AppShellState> _shellSubscription;

  @override
  void dispose() {
    _authSubscription.cancel();
    _shellSubscription.close();
    super.dispose();
  }
}

