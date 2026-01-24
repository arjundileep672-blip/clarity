import 'package:flutter/foundation.dart';
import 'audio_input_viewmodel.dart';
import 'photo_input_viewmodel.dart';
import '../services/storage_service.dart';

class SensoryReaderViewModel extends ChangeNotifier {
  final AudioInputViewModel audioViewModel = AudioInputViewModel(
    StorageService.keyReaderAudio,
  );
  final PhotoInputViewModel photoViewModel = PhotoInputViewModel(
    StorageService.keyReaderImage,
  );

  String _text = '';

  String get text => _text;

  String get displayText {
    if (_text.trim().isEmpty) {
      if (audioViewModel.audioFilePath != null) {
        return 'Audio note ready for processing...';
      }
      if (photoViewModel.imageFilePath != null) {
        return 'Image ready for processing...';
      }
      return 'Paste text, record audio, or upload a photo to start.';
    }
    return _text;
  }

  void updateText(String newText) {
    _text = newText;
    notifyListeners();
  }

  void readAloud() {
    // Placeholder for TTS service integration
  }

  @override
  void dispose() {
    audioViewModel.dispose();
    photoViewModel.dispose();
    super.dispose();
  }
}
