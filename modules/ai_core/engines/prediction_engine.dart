import '../models/risk_analysis.dart';
import '../services/signal_sources.dart';

/// Pluggable orchestrator interface for AI-ready analytics.
///
/// Implementations should remain non-diagnostic and explainable.
abstract class PredictionEngine {
  Future<RiskAnalysis> run({
    required DateTime from,
    required DateTime to,
    required EmotionSignalSource emotionSource,
    required JournalSignalSource journalSource,
    required ActivitySignalSource activitySource,
    WearableSignalSource? wearableSource,
  });
}

