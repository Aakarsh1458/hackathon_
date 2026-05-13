import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import 'auth_dependency_providers.dart';

/// Shell auth session — modules observe user id only; never embed module state here.
final authSessionProvider = StreamProvider<AuthUser?>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  return auth.authStateChanges();
});
