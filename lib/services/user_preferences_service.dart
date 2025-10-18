import 'package:drift/drift.dart';
import 'package:med_track_v2/database/app_database.dart';

class UserPreferencesService {
  final AppDatabase _database;

  UserPreferencesService(this._database);

  Future<UserPreference?> getUserPreferences() async {
    try {
      final preferences = await _database.getAllUserPreferences();
      return preferences.isNotEmpty ? preferences.first : null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUsername() async {
    final preferences = await getUserPreferences();
    return preferences?.username;
  }

  Future<String> getThemeMode() async {
    final preferences = await getUserPreferences();
    return preferences?.themeMode ?? 'system';
  }

  Future<bool> hasCompletedOnboarding() async {
    final username = await getUsername();
    return username != null && username.isNotEmpty;
  }

  Future<void> saveUsername(String username) async {
    if (username.isEmpty) {
      throw ArgumentError('Username cannot be empty');
    }

    final existingPreferences = await getUserPreferences();

    if (existingPreferences != null) {
      await _database.updateUserPreferences(
        UserPreferencesCompanion(
          id: Value(existingPreferences.id),
          username: Value(username),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await _database.insertUserPreferences(
        UserPreferencesCompanion.insert(
          username: username,
        ),
      );
    }
  }

  Future<void> updateThemeMode(String themeMode) async {
    final validThemeModes = ['system', 'light', 'dark'];
    if (!validThemeModes.contains(themeMode)) {
      throw ArgumentError('Invalid theme mode: $themeMode');
    }

    final existingPreferences = await getUserPreferences();

    if (existingPreferences != null) {
      await _database.updateUserPreferences(
        UserPreferencesCompanion(
          id: Value(existingPreferences.id),
          themeMode: Value(themeMode),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> clearUserPreferences() async {
    final existingPreferences = await getUserPreferences();
    if (existingPreferences != null) {
      await _database.deleteUserPreferences(existingPreferences.id);
    }
  }

  Stream<UserPreference?> watchUserPreferences() {
    return _database.watchUserPreferences();
  }
}
