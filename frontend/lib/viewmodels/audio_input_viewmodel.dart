import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/permission_service.dart';
import '../services/storage_service.dart';

class AudioInputViewModel extends ChangeNotifier {
  final PermissionService _permissionService = PermissionService();
  final StorageService _storageService = StorageService();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  String? _audioFilePath;
  final String _persistenceKey;

  bool get isRecording => _isRecording;
  String? get audioFilePath => _audioFilePath;

  AudioInputViewModel(this._persistenceKey) {
    _loadPersistedAudio();
  }

  Future<void> _loadPersistedAudio() async {
    final path = await _storageService.getString(_persistenceKey);
    if (path != null && File(path).existsSync()) {
      _audioFilePath = path;
      notifyListeners();
    }
  }

  Future<void> startRecording() async {
    if (await _permissionService.requestMicrophonePermission()) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${directory.path}/audio_$timestamp.m4a';

        if (await _audioRecorder.hasPermission()) {
          await _audioRecorder.start(const RecordConfig(), path: path);
          _isRecording = true;
          _audioFilePath = null; // Reset previous recording
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error starting recording: $e');
      }
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      _audioFilePath = path;
      if (path != null) {
        await _storageService.saveString(_persistenceKey, path);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecording() async {
    if (_audioFilePath != null) {
      try {
        final file = File(_audioFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting file: $e');
      }
      _audioFilePath = null;
      await _storageService.clear(_persistenceKey);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}
