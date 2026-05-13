import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../errors/app_failure.dart';
import '../logging/app_logger.dart';
import '../../../shared/interfaces/auth_repository.dart';
import '../../../shared/models/auth_user.dart';

/// Firebase-backed auth — shell responsibility only.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  bool get _firebaseReady => Firebase.apps.isNotEmpty;

  AuthUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }
    return AuthUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    if (!_firebaseReady) {
      return Stream<AuthUser?>.value(null);
    }
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _ensureFirebase();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Email sign-in failed', cause: e);
    }
  }

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {
    _ensureFirebase();
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Registration failed', cause: e);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    _ensureFirebase();
    try {
      final googleUser = await _googleSignIn.signIn();
      final tokens = await googleUser?.authentication;
      if (tokens?.accessToken == null && tokens?.idToken == null) {
        throw const AuthFailure('Google sign-in aborted');
      }
      final credential = GoogleAuthProvider.credential(
        accessToken: tokens?.accessToken,
        idToken: tokens?.idToken,
      );
      await _auth.signInWithCredential(credential);
    } catch (e, st) {
      AppLogger.instance.warning('Google sign-in failed', e, st);
      if (e is AuthFailure) rethrow;
      throw AuthFailure('$e');
    }
  }

  @override
  Future<void> signOut() async {
    if (!_firebaseReady) {
      return;
    }
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  void _ensureFirebase() {
    if (!_firebaseReady) {
      throw const AuthFailure(
        'Firebase not initialized — configure Firebase / flutterfire configure.',
      );
    }
  }
}
