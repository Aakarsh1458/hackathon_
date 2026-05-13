import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/emotion_engine/lib/services/emotion_service.dart';

/// Single [EmotionService] for shell tabs + dashboard module card so journal and
/// insights stay in sync.
final emotionEngineServiceProvider =
    ChangeNotifierProvider<EmotionService>((ref) {
  final service = EmotionService();
  ref.onDispose(service.dispose);
  return service;
});
