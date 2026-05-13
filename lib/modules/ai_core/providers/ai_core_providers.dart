import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engines/ai_core_prediction_engine.dart';
import '../services/recommendation_service.dart';
import 'ai_core_controller.dart';

/// Local, module-scoped providers. The app shell can choose to use or ignore these.
final aiCorePredictionEngineProvider = Provider((ref) => const AiCorePredictionEngine());

final aiCoreRecommendationServiceProvider =
    Provider<RecommendationService>((ref) => const DefaultRecommendationService());

final aiCoreControllerProvider = ChangeNotifierProvider<AiCoreController>((ref) {
  return AiCoreController(
    predictionEngine: ref.watch(aiCorePredictionEngineProvider),
    recommendationService: ref.watch(aiCoreRecommendationServiceProvider),
  );
});

