import 'package:flutter/material.dart';
import 'package:med_track_v2/services/user_preferences_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final UserPreferencesService _userPreferencesService;
  final Function(ThemeMode) onThemeChanged;

  String _username = '';
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = false;
  bool _isSaving = false;
  String _errorMessage = '';
  String _successMessage = '';

  SettingsViewModel(this._userPreferencesService, this.onThemeChanged);

  String get username => _username;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final loadedUsername = await _userPreferencesService.getUsername();
      final themeModeString = await _userPreferencesService.getThemeMode();

      _username = loadedUsername ?? '';
      _themeMode = _parseThemeMode(themeModeString);
    } catch (e) {
      _errorMessage = 'Failed to load settings';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> updateUsername(String newUsername) async {
    if (newUsername.trim().isEmpty) {
      _errorMessage = 'Username cannot be empty';
      _successMessage = '';
      notifyListeners();
      return;
    }

    if (newUsername.trim().length < 2) {
      _errorMessage = 'Username must be at least 2 characters';
      _successMessage = '';
      notifyListeners();
      return;
    }

    if (newUsername.trim().length > 30) {
      _errorMessage = 'Username must be less than 30 characters';
      _successMessage = '';
      notifyListeners();
      return;
    }

    _isSaving = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      await _userPreferencesService.saveUsername(newUsername.trim());
      _username = newUsername.trim();
      _successMessage = 'Username updated successfully';
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to update username';
      _successMessage = '';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateThemeMode(ThemeMode newThemeMode) async {
    if (_themeMode == newThemeMode) return;

    try {
      await _userPreferencesService.updateThemeMode(_themeModeToString(newThemeMode));
      _themeMode = newThemeMode;
      onThemeChanged(newThemeMode);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update theme mode';
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }
}
