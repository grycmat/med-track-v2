import 'package:flutter/material.dart';
import 'package:med_track_v2/services/user_preferences_service.dart';

class WelcomeViewModel extends ChangeNotifier {
  final UserPreferencesService _userPreferencesService;

  String _username = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isSaving = false;

  WelcomeViewModel(this._userPreferencesService);

  String get username => _username;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isValidUsername => _username.trim().isNotEmpty;

  void setUsername(String value) {
    _username = value;
    _errorMessage = '';
    notifyListeners();
  }

  Future<bool> saveUsername() async {
    if (_username.trim().isEmpty) {
      _errorMessage = 'Please enter your name';
      notifyListeners();
      return false;
    }

    if (_username.trim().length < 2) {
      _errorMessage = 'Name must be at least 2 characters';
      notifyListeners();
      return false;
    }

    if (_username.trim().length > 50) {
      _errorMessage = 'Name must be less than 50 characters';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _userPreferencesService.saveUsername(_username.trim());
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save username. Please try again.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadExistingUsername() async {
    _isLoading = true;
    notifyListeners();

    try {
      final existingUsername = await _userPreferencesService.getUsername();
      if (existingUsername != null) {
        _username = existingUsername;
      }
    } catch (e) {
      _errorMessage = 'Failed to load preferences';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
