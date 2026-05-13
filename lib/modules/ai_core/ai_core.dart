library ai_core;

// NOTE: Public export surface for the AI Core module.
// Keep exports narrow to avoid naming conflicts with other module contracts.
export 'module_facade.dart';

// Core analytics exports.
export 'models/behavioral_pattern.dart';
export 'models/chat_message.dart';
export 'models/emotional_context.dart';
export 'models/risk_analysis.dart';
export 'models/relapse_risk.dart';
export 'models/stress_analysis.dart';
export 'models/wellness_score.dart';
export 'engines/prediction_engine.dart';
export 'services/recommendation_service.dart';

// Conversational / voice exports (required).
export 'services/recommendation_engine.dart';
export 'services/groq_ai_provider.dart';
export 'services/http_groq_ai_provider.dart';
export 'services/wellness_chat_service.dart';
export 'services/voice_conversation_service.dart';
export 'services/voice_io.dart';
export 'services/adaptive_wellness_chat_service.dart';

