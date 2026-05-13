import 'dart:math';

import '../models/demo_user.dart';

/// Temporary local demo session handling for integration environments.
///
/// This does NOT replace Firebase auth; it provides a safe fallback identity
/// for demo/dashboard access when auth is unavailable.
class DemoSessionService {
  DemoUser? _current;
  DemoUser? get current => _current;

  bool get hasSession => _current != null;

  DemoUser startDemoSession({String displayName = 'Demo User'}) {
    final uid = 'demo-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999999)}';
    _current = DemoUser(uid: uid, displayName: displayName, isDemo: true);
    return _current!;
  }

  void endSession() {
    _current = null;
  }
}

