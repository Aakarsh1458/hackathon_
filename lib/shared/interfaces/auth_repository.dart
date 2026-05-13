import '../models/auth_user.dart';

/// Authentication boundary for the shell — implementations live under [core/services/auth].
abstract class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> registerWithEmail({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();
}
