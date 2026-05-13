import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Temporary demo fallback flag.
///
/// - When true, the router should allow access to demo surfaces even if auth fails.
/// - This does NOT remove or replace Firebase auth. It only prevents the shell
///   from becoming unusable during integration.
final authDemoModeProvider = StateProvider<bool>((ref) => false);

