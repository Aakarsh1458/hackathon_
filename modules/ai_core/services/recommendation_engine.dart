import '../models/relapse_risk.dart';
import '../models/stress_analysis.dart';
import '../models/wellness_score.dart';
import 'recommendation_service.dart';

/// Export requested: RecommendationEngine.
///
/// Kept compatible with the existing RecommendationService.
abstract class RecommendationEngine {
  List<WellnessRecommendation> recommend({
    required WellnessScore wellness,
    required StressAnalysis stress,
    required RelapseRisk relapseRisk,
  });
}

class RecommendationEngineAdapter implements RecommendationEngine {
  final RecommendationService inner;
  const RecommendationEngineAdapter(this.inner);

  @override
  List<WellnessRecommendation> recommend({
    required WellnessScore wellness,
    required StressAnalysis stress,
    required RelapseRisk relapseRisk,
  }) {
    return inner.recommend(wellness: wellness, stress: stress, relapseRisk: relapseRisk);
  }
}

