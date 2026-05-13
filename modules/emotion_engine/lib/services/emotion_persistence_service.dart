import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/emotion_data.dart';
import '../models/mood_entry.dart';

/// Local JSON persistence for journal + recent expression signals.
class EmotionPersistenceService {
  EmotionPersistenceService();

  File? _file;
  final List<MoodEntry> _entries = [];
  final List<EmotionData> _faceHistory = [];
  Timer? _saveDebounce;

  List<MoodEntry> get entries => List.unmodifiable(_entries);
  List<EmotionData> get faceHistory => List.unmodifiable(_faceHistory);

  /// Provide a resolver for a writable directory (typically from `path_provider`).
  Future<void> initialize(Future<Directory> Function() rootDirectory) async {
    final root = await rootDirectory();
    _file = File(p.join(root.path, 'emotion_engine', 'emotion_store.json'));
    await _file!.parent.create(recursive: true);
    await _load();
  }

  Future<void> addMoodEntry(MoodEntry entry) async {
    _entries.add(entry);
    _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _save();
  }

  Future<void> appendFaceSignal(EmotionData data, {int maxSignals = 400}) async {
    _faceHistory.add(data);
    while (_faceHistory.length > maxSignals) {
      _faceHistory.removeAt(0);
    }
    _scheduleSave();
  }

  Future<void> clearFaceHistory() async {
    _faceHistory.clear();
    await _save();
  }

  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 1800), () {
      unawaited(_save());
    });
  }

  /// Persists immediately (e.g. before module disposal).
  Future<void> flushPendingWrites() async {
    _saveDebounce?.cancel();
    await _save();
  }

  Future<void> _load() async {
    final f = _file;
    if (f == null || !await f.exists()) return;
    try {
      final raw = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      _entries
        ..clear()
        ..addAll(
          (raw['entries'] as List<dynamic>? ?? [])
              .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>)),
        );
      _faceHistory
        ..clear()
        ..addAll(
          (raw['faceHistory'] as List<dynamic>? ?? [])
              .map((e) => EmotionData.fromJson(e as Map<String, dynamic>))
              .whereType<EmotionData>(),
        );
    } catch (_) {
      // Corrupt file — start fresh but keep file for next save
      _entries.clear();
      _faceHistory.clear();
    }
  }

  Future<void> _save() async {
    final f = _file;
    if (f == null) return;
    final payload = {
      'version': 1,
      'entries': _entries.map((e) => e.toJson()).toList(),
      'faceHistory': _faceHistory.map((e) => e.toJson()).toList(),
    };
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
  }
}
