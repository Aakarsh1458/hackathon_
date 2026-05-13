import 'package:flutter/widgets.dart';

/// Plug-in contract for parallel teams dropping code under `lib/modules/<name>/`.
///
/// TODO: Each module owns routing subtree registration — extend this when integrating go_router.
abstract class WellnessModuleContract {
  /// Stable id — align with folder name (e.g. `emotion_engine`).
  String get moduleId;

  /// Human-readable title for shell dashboards / nav placeholders.
  String get displayName;

  /// Root widget when the module is activated — shell navigates without importing internals.
  Widget buildRoot(BuildContext context);

  /// Dispose native resources when module unregistered (optional).
  Future<void> onDispose() async {}
}
