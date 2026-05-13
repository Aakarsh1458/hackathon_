/// Typed failures for shell layers (network, auth). Modules may define their own.
sealed class AppFailure implements Exception {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppFailure: $message';
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.cause});
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.cause});
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message, {super.cause});
}
