import 'package:flutter/foundation.dart';

import '../engines/ai_core_prediction_engine.dart';
import '../engines/prediction_engine.dart';
import '../models/risk_analysis.dart';
import '../services/recommendation_service.dart';
import '../services/signal_sources.dart';

/// Provider/Riverpod-friendly controller. No routing assumptions.
class AiCoreController extends ChangeNotifier {
  final PredictionEngine predictionEngine;
  final RecommendationService recommendationService;

  RiskAnalysis? _latest;
  RiskAnalysis? get latest => _latest;

  bool _loading = false;
  bool get loading => _loading;

  Object? _lastError;
  Object? get lastError => _lastError;

  List<WellnessRecommendation> _latestRecommendations = const [];
  List<WellnessRecommendation> get latestRecommendations => _latestRecommendations;

  AiCoreController({
    PredictionEngine? predictionEngine,
    RecommendationService? recommendationService,
  })  : predictionEngine = predictionEngine ?? const AiCorePredictionEngine(),
        recommendationService = recommendationService ?? const DefaultRecommendationService();

  Future<void> refresh({
    required DateTime from,
    required DateTime to,
    required EmotionSignalSource emotionSource,
    required JournalSignalSource journalSource,
    required ActivitySignalSource activitySource,
    WearableSignalSource? wearableSource,
  }) async {
    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      final analysis = await predictionEngine.run(
        from: from,
        to: to,
        emotionSource: emotionSource,
        journalSource: journalSource,
        activitySource: activitySource,
        wearableSource: wearableSource,
      );
      _latest = analysis;
      _latestRecommendations = recommendationService.recommend(
        wellness: analysis.wellness,
        stress: analysis.stress,
        relapseRisk: analysis.relapseRisk,
      );
    } catch (e) {
      _lastError = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

