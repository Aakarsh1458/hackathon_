import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/demo_user.dart';
import '../services/demo_session_service.dart';

final demoSessionServiceProvider = Provider((ref) => DemoSessionService());

final demoUserProvider = StateProvider<DemoUser?>((ref) => null);

