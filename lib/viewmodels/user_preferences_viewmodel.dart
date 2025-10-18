import 'package:flutter/material.dart';
import 'package:med_track_v2/services/user_preferences_service.dart';

class UserPreferencesViewModel extends ChangeNotifier {
  final UserPreferencesService _userPreferencesService;

  String _username = '';
  bool _isLoading = false;
  String _errorMessage = '';

  UserPreferencesViewModel(this._userPreferencesService);

  String get username => _username;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get displayName => _username.isEmpty ? 'User' : _username;

  Future<void> loadUsername() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final loadedUsername = await _userPreferencesService.getUsername();
      _username = loadedUsername ?? '';
    } catch (e) {
      _errorMessage = 'Failed to load user preferences';
      _username = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUsername(String newUsername) async {
    if (newUsername.trim().isEmpty) {
      _errorMessage = 'Username cannot be empty';
      notifyListeners();
      return;
    }

    try {
      await _userPreferencesService.saveUsername(newUsername.trim());
      _username = newUsername.trim();
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update username';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
