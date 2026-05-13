import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/firebase_bootstrap.dart';
import 'core/di/service_locator.dart';
import 'core/errors/global_error_handler.dart';
import 'core/services/logging/app_logger.dart';
import 'ui/themes/app_theme.dart';
import 'ui/navigation/app_router.dart';
import 'shared/providers/theme_mode_provider.dart';

/// Application entry — infrastructure only.
///
/// Module teams: register facades via [ModuleRegistrationBus] from your composition root (TODO).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GlobalErrorHandler.install();
  await bootstrapFirebase();
  await configureDependencies();

  AppLogger.instance.info('Shell bootstrap complete');

  runZonedGuarded(
    () {
      runApp(
        const ProviderScope(
          child: WellnessShellApp(),
        ),
      );
    },
    (error, stack) {
      AppLogger.instance.error('Uncaught zone error', error, stack);
    },
  );
}

class WellnessShellApp extends ConsumerWidget {
  const WellnessShellApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: router,
    );
  }
}
