/// Emotion + signal engine module for wellness-oriented facial signals,
/// journaling, and timelines.
///
/// Host application setup (handled outside this module):
/// - Add path dependency: `emotion_engine: path: lib/modules/emotion_engine`
/// - Request `camera` / runtime permissions before starting live analysis
/// - Pass `getApplicationDocumentsDirectory` into [EmotionService.bootstrapPersistence]
///
/// TODO(integration): App shell wires global navigation — use module screens directly.
library emotion_engine;

export 'models/emotion_data.dart';
export 'models/emotion_label.dart';
export 'models/mood_entry.dart';
export 'models/mood_timeline.dart';
export 'models/signal_state.dart';
export 'providers/emotion_engine_scope.dart';
export 'screens/emotion_dashboard_screen.dart';
export 'screens/journal_screen.dart';
export 'screens/live_emotion_screen.dart';
export 'services/emotion_service.dart';
export 'services/voice_journal_placeholder.dart';
export 'widgets/emotion_camera_preview.dart';
export 'widgets/emotion_confidence_strip.dart';
export 'widgets/face_overlay_painter.dart';
export 'widgets/journal_entry_tile.dart';
export 'widgets/mood_summary_card.dart';
export 'widgets/mood_timeline_chart.dart';
