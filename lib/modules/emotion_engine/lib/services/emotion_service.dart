import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../models/emotion_data.dart';
import '../models/mood_entry.dart';
import '../models/signal_state.dart';
import '../utils/camera_input_image_utils.dart';
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
    Uuid? uuid,
  })  : _faceDetection = faceDetection ?? FaceDetectionService(),
        _estimation = estimation ?? const EmotionEstimationService(),
        _persistence = persistence ?? EmotionPersistenceService(),
        _aggregation = aggregation ?? const SignalAggregationService(),
        _uuid = uuid ?? const Uuid() {
    _rebuildState();
  }

  final FaceDetectionService _faceDetection;
  final EmotionEstimationService _estimation;
  final EmotionPersistenceService _persistence;
  final SignalAggregationService _aggregation;
  final Uuid _uuid;

  CameraController? _controller;
  bool _processing = false;
  int _frameTick = 0;
  String? _lastError;
  EmotionData? _live;
  final List<EmotionData> _recentFace = [];
  DeviceOrientation _orientation = DeviceOrientation.portraitUp;

  SignalState _state = SignalState(updatedAt: DateTime.now());

  SignalState get signalState => _state;
  CameraController? get cameraController => _controller;
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
    if (_controller != null) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _lastError = 'No cameras available on this device.';
        _rebuildState();
        return;
      }
      final lens = preferFront
          ? cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => cameras.first,
            )
          : cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => cameras.first,
            );
      _controller = CameraController(
        lens,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _controller!.initialize();
      _lastError = null;
    } catch (e) {
      _lastError = e.toString();
    }
    _rebuildState();
  }

  /// Starts image stream processing. Requires initialized camera.
  ///
  /// TODO(integration): Request `camera` permission in the app shell before calling.
  Future<void> startLiveAnalysis({int processEveryNthFrame = 2}) async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      _lastError = 'Camera not initialized.';
      _rebuildState();
      return;
    }
    if (_processing) return;
    _processing = true;
    _frameTick = 0;
    await c.startImageStream((image) async {
      if (!_processing) return;
      _frameTick++;
      if (_frameTick % processEveryNthFrame != 0) return;
      await _handleFrame(image, c);
    });
    _rebuildState();
  }

  Future<void> stopLiveAnalysis() async {
    _processing = false;
    final c = _controller;
    if (c != null && c.value.isStreamingImages) {
      await c.stopImageStream();
    }
    _rebuildState();
  }

  Future<void> disposeCamera() async {
    await stopLiveAnalysis();
    await _controller?.dispose();
    _controller = null;
    _rebuildState();
  }

  Future<void> _handleFrame(CameraImage image, CameraController controller) async {
    try {
      final rotation = computeInputImageRotation(
        description: controller.description,
        deviceOrientation: _orientation,
      );
      final input = inputImageFromCameraImage(image: image, rotation: rotation);
      if (input == null) return;

      final faces = await _faceDetection.detect(input);
      if (faces.isEmpty) {
        _live = null;
        _rebuildState();
        return;
      }
      final primary = faces.first;
      final estimated = _estimation.estimate(
        primary,
        image.width,
        image.height,
      );
      _live = estimated;
      _recentFace.add(estimated);
      while (_recentFace.length > 96) {
        _recentFace.removeAt(0);
      }
      await _persistence.appendFaceSignal(estimated);
      _rebuildState();
    } catch (e) {
      _lastError = e.toString();
      _rebuildState();
    }
  }

  Future<void> saveJournal(
    String body, {
    bool linkCurrentSignal = true,
  }) async {
    final text = body.trim();
    if (text.isEmpty) return;
    final entry = MoodEntry.fromTextWithSignal(
      id: _uuid.v4(),
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
    final c = _controller;
    _controller = null;
    if (c != null) {
      unawaited(() async {
        if (c.value.isStreamingImages) {
          await c.stopImageStream();
        }
        await c.dispose();
      }());
    }
    super.dispose();
  }
}
