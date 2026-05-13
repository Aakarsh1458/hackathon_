library ai_core;

// NOTE: This is the public export surface for the AI Core module.
// Keep exports narrow to avoid naming conflicts with other module contracts.

// Existing exports (kept for backwards compatibility).
export 'models/behavioral_pattern.dart';
export 'models/risk_analysis.dart';
export 'models/relapse_risk.dart';
export 'models/stress_analysis.dart';
export 'models/wellness_score.dart';
export 'engines/prediction_engine.dart';
export 'services/recommendation_service.dart';

// Chatbot integration surface (required).
export 'chat/ai_provider.dart' show AIProvider;
export 'chat/groq_ai_provider.dart' show GroqAIProvider;
export 'services/wellness_chat_service.dart' show WellnessChatService;
export 'chat/chat_models.dart' show EmotionalContext, ChatMessage;
export 'recommendations/recommendation_engine.dart' show RecommendationEngine;

