/// Public entrypoint for the AI Core module.
///
/// Other modules/systems should import from this file to avoid tight coupling
/// to internal folder structure.
///
/// Required exports (per integration spec):
/// - [AIProvider]
/// - [GroqAIProvider]
/// - [WellnessChatService]
/// - [EmotionalContext]
/// - [ChatMessage]
/// - [RecommendationEngine]
export 'chat/chat_models.dart';
export 'chat/ai_provider.dart';
export 'chat/groq_ai_provider.dart';
export 'services/wellness_chat_service.dart';
export 'recommendations/recommendation_engine.dart';
// NOTE: UI/widgets can be exported later by other agents as needed.


