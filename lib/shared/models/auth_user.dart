/// Shell identity model — no module-specific profile fields.
class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;
}
