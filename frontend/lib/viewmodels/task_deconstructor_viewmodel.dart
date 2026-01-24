import 'package:flutter/foundation.dart';
import 'audio_input_viewmodel.dart';
import 'photo_input_viewmodel.dart';
import '../services/storage_service.dart';

enum InputMethod { text, audio, photo }

class TaskDeconstructorViewModel extends ChangeNotifier {
  final AudioInputViewModel audioViewModel = AudioInputViewModel(
    StorageService.keyTaskAudio,
  );
  final PhotoInputViewModel photoViewModel = PhotoInputViewModel(
    StorageService.keyTaskImage,
  );

  InputMethod _selectedInputMethod = InputMethod.text;
  String _taskText = '';

  InputMethod get selectedInputMethod => _selectedInputMethod;
  String get taskText => _taskText;

  void setInputMethod(InputMethod method) {
    _selectedInputMethod = method;
    notifyListeners();
  }

  void updateTaskText(String text) {
    _taskText = text;
    // Note: Text persistence could be added here similar to audio/photo
  }

  @override
  void dispose() {
    audioViewModel.dispose();
    photoViewModel.dispose();
    super.dispose();
  }
}
