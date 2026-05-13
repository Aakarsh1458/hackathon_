import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/firebase_bootstrap.dart';
import 'core/di/service_locator.dart';
import 'core/errors/global_error_handler.dart';
import 'core/services/logging/app_logger.dart';
import 'modules/ai_core/module_facade.dart';
import 'modules/companion_system/module_facade.dart';
import 'modules/emotion_engine/module_facade.dart';
import 'modules/intervention_system/module_facade.dart';
import 'ui/themes/app_theme.dart';
import 'ui/navigation/app_router.dart';
import 'shared/providers/app_state_provider.dart';
import 'shared/providers/theme_mode_provider.dart';

/// Application entry — infrastructure only.
///
/// Module teams: register facades via [ModuleRegistrationBus] from your composition root (TODO).
Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await GlobalErrorHandler.install();
      await bootstrapFirebase();
      await configureDependencies();
      _registerModules();

      AppLogger.instance.info('Shell bootstrap complete');

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

void _registerModules() {
  AICoreModuleFacade().register();
  EmotionEngineModuleFacade().register();
  CompanionModuleFacade().register();
  InterventionSystemModuleFacade().register();
}

class WellnessShellApp extends ConsumerWidget {
  const WellnessShellApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final router = ref.watch(goRouterProvider);
    ref.watch(appStateProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: router,
    );
  }
}
