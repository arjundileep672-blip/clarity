import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reader_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  static const String _settingsKey = 'reader_settings';

  ReaderSettings _settings = const ReaderSettings();
  SharedPreferences? _prefs;

  ReaderSettings get settings => _settings;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final String? settingsJson = _prefs?.getString(_settingsKey);

    if (settingsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(settingsJson);
        _settings = ReaderSettings.fromJson(json);
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading settings: $e');
      }
    }
  }

  Future<void> _saveSettings() async {
    _prefs ??= await SharedPreferences.getInstance();

    try {
      final String settingsJson = jsonEncode(_settings.toJson());
      await _prefs?.setString(_settingsKey, settingsJson);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> toggleOpenDyslexic(bool value) async {
    _settings = _settings.copyWith(useOpenDyslexic: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> toggleBionicReading(bool value) async {
    _settings = _settings.copyWith(useBionicReading: value);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setFontSize(FontSize fontSize) async {
    _settings = _settings.copyWith(fontSize: fontSize);
    notifyListeners();
    await _saveSettings();
  }

  Future<void> setBackgroundColor(BackgroundColor backgroundColor) async {
    _settings = _settings.copyWith(backgroundColor: backgroundColor);
    notifyListeners();
    await _saveSettings();
  }
}
