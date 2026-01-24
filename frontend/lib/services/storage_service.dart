import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyTaskAudio = 'task_deconstructor_last_audio_path';
  static const String keyTaskImage = 'task_deconstructor_last_image_path';
  static const String keyReaderAudio = 'sensory_reader_last_audio_path';
  static const String keyReaderImage = 'sensory_reader_last_image_path';

  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
