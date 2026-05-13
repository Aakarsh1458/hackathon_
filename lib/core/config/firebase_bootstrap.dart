import 'package:firebase_core/firebase_core.dart';

import '../services/logging/app_logger.dart';
import 'firebase_options.dart';

/// Initializes Firebase if native config or generated options exist.
///
/// TODO (integration): Run `flutterfire configure` and replace [DefaultFirebaseOptions].
/// Until then, the shell continues so parallel agents can work without Firebase.
Future<void> bootstrapFirebase() async {
  if (Firebase.apps.isNotEmpty) {
    return;
  }
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.instance.info('Firebase initialized');
  } catch (e, st) {
    AppLogger.instance.warning(
      'Firebase init skipped or failed — add platform Firebase config / flutterfire configure.',
      e,
      st,
    );
  }
}
