import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../services/auth/firebase_auth_repository.dart';
import '../../shared/interfaces/auth_repository.dart';

final GetIt sl = GetIt.instance;

/// Registers shell services only — modules register their own DI scopes separately.
Future<void> configureDependencies() async {
  sl.registerLazySingleton<AuthRepository>(
    FirebaseAuthRepository.new,
  );
  sl.registerLazySingleton<ApiClient>(HttpApiClient.new);
}
