import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/service_locator.dart';
import '../interfaces/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return sl<AuthRepository>();
});
