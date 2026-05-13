import 'package:flutter/foundation.dart';

/// Role-aligned message used across the AI core.
class ChatMessage {
  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    String? id,
  })  : id = id ?? UniqueKey().toString(),
        timestamp = timestamp ?? DateTime.now();

  /// Typical values: `system`, `user`, `assistant`.
  final String role;

  final String content;

  final DateTime timestamp;

  /// Unique per-message id for UI keys.
  final String id;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}

/// Emotional state container supplied by other modules.
///
/// This module never performs emotion detection; it only consumes context.
class EmotionalContext {
  const EmotionalContext({
    this.wellnessScore,
    this.stressIndex,
    this.recoveryProgress,
    this.burnoutIndicators,
    this.relapseRisk,
    this.emotionalTrends,
    this.journalingHints,
  });

  /// 0..100
  final int? wellnessScore;

  /// 0..100 (higher = more stress)
  final int? stressIndex;

  /// 0..1
  final double? recoveryProgress;

  /// Free-form or normalized burnout indicator score.
  final int? burnoutIndicators;

  /// 0..1 (higher = higher relapse risk).
  final double? relapseRisk;

  /// High-level trend labels (already computed by modules).
  final List<String>? emotionalTrends;

  /// Optional journaling hints derived from other modules.
  final String? journalingHints;

  static const empty = EmotionalContext();
}

/// Structured wellness suggestion (for UI).
class WellnessRecommendation {
  const WellnessRecommendation({
    required this.title,
    required this.body,
    this.severity = 0,
    this.category,
  });

  final String title;
  final String body;

  /// 0 (gentle) .. 2 (higher urgency)
  final int severity;

  final String? category;
}

/// Response from the chat service.
class ChatResponse {
  const ChatResponse({
    required this.assistantMessage,
    required this.recommendations,
  });

  final ChatMessage assistantMessage;
  final List<WellnessRecommendation> recommendations;
}

/// Used by streaming APIs (delta tokens).
class ChatMessageChunk {
  const ChatMessageChunk({
    required this.textDelta,
    required this.isFinal,
    this.assistantMessage,
  });

  final String textDelta;
  final bool isFinal;

  /// Present only when `isFinal == true`.
  final ChatMessage? assistantMessage;
}

