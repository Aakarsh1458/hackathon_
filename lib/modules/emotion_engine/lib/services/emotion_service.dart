import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/emotion_data.dart';
import '../models/mood_entry.dart';
import '../models/signal_state.dart';
import 'emotion_estimation_service.dart';
import 'emotion_persistence_service.dart';
import 'face_detection_service.dart';
import 'signal_aggregation_service.dart';

/// Orchestrates camera capture, ML Kit analysis, journaling, and persistence.
///
/// Use with `ChangeNotifier` listeners, `ListenableBuilder`, or wrap in
/// `ChangeNotifierProvider` / `riverpod` `ChangeNotifierProvider`.
class EmotionService extends ChangeNotifier {
  EmotionService({
    FaceDetectionService? faceDetection,
    EmotionEstimationService? estimation,
    EmotionPersistenceService? persistence,
    SignalAggregationService? aggregation,
  })  : _faceDetection = faceDetection ?? FaceDetectionService(),
        _estimation = estimation ?? const EmotionEstimationService(),
        _persistence = persistence ?? EmotionPersistenceService(),
        _aggregation = aggregation ?? const SignalAggregationService() {
    _rebuildState();
  }

  final FaceDetectionService _faceDetection;
  final EmotionEstimationService _estimation;
  final EmotionPersistenceService _persistence;
  final SignalAggregationService _aggregation;

  // Demo-safe build: camera is disabled unless host app adds dependencies.
  Object? _controller;
  bool _processing = false;
  int _frameTick = 0;
  String? _lastError;
  EmotionData? _live;
  final List<EmotionData> _recentFace = [];
  DeviceOrientation _orientation = DeviceOrientation.portraitUp;

  SignalState _state = SignalState(updatedAt: DateTime.now());

  SignalState get signalState => _state;
  Object? get cameraController => _controller;
  bool get isAnalyzing => _processing;

  void updateOrientation(DeviceOrientation orientation) {
    _orientation = orientation;
  }

  /// Host app should pass `getApplicationDocumentsDirectory` (or scoped dir).
  Future<void> bootstrapPersistence({
    required Future<Directory> Function() rootDirectory,
  }) async {
    await _persistence.initialize(rootDirectory);
    _rebuildState();
  }

  Future<void> ensureCamera({bool preferFront = true}) async {
    _lastError =
        'Camera/ML features are disabled in this demo build (missing dependencies).';
    _rebuildState();
  }

  /// Starts image stream processing. Requires initialized camera.
  ///
  /// TODO(integration): Request `camera` permission in the app shell before calling.
  Future<void> startLiveAnalysis({int processEveryNthFrame = 2}) async {
    _lastError =
        'Live camera analysis is unavailable (missing camera/mlkit dependencies).';
    _rebuildState();
  }

  Future<void> stopLiveAnalysis() async {
    _processing = false;
    _rebuildState();
  }

  Future<void> disposeCamera() async {
    await stopLiveAnalysis();
    _controller = null;
    _rebuildState();
  }

  // Frame processing intentionally omitted in demo-safe build.

  Future<void> saveJournal(
    String body, {
    bool linkCurrentSignal = true,
  }) async {
    final text = body.trim();
    if (text.isEmpty) return;
    final entry = MoodEntry.fromTextWithSignal(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      body: text,
      signal: linkCurrentSignal ? _live : null,
    );
    await _persistence.addMoodEntry(entry);
    _rebuildState();
  }

  List<MoodEntry> get journalEntries => _persistence.entries;

  void _rebuildState() {
    _state = _aggregation.build(
      liveFace: _live,
      recentFace: List<EmotionData>.from(_recentFace),
      journal: _persistence.entries,
      cameraActive: _processing,
      lastError: _lastError,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _processing = false;
    unawaited(_persistence.flushPendingWrites());
    unawaited(_faceDetection.dispose());
    _controller = null;
    super.dispose();
  }
}
