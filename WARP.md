# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**Medication Tracker (med_track_v2)** - A Flutter mobile app for tracking medication schedules and adherence. Uses Drift (SQLite) for local persistence, Provider for state management, and Material 3 design system.

**SDK**: Dart ^3.9.2  
**Database**: Drift with schema version 2

## Essential Commands

### Development
```powershell
# Install dependencies
flutter pub get

# Run app in debug mode
flutter run

# Analyze code for issues
flutter analyze

# Run all tests
flutter test

# Clean build artifacts
flutter clean
```

### Database Code Generation (Critical)
```powershell
# Generate Drift database code after table changes
dart run build_runner build

# Force regenerate (use if conflicts occur)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for automatic regeneration
dart run build_runner watch
```

**Important**: Always run `dart run build_runner build` after modifying any files in `lib/database/tables/`. The generated file `lib/database/app_database.g.dart` is required for the app to compile.

### Build Commands
```powershell
# Build Android APK
flutter build apk

# Build iOS app (macOS only)
flutter build ios
```

## Architecture Overview

### Layered Architecture Pattern
```
Presentation Layer (Screens, Widgets, ViewModels)
    ↓ uses
Business Logic Layer (Services)
    ↓ uses
Data Layer (Drift Database, Models)
```

### Dependency Injection Flow
All dependencies are created in `main()` and provided via `MultiProvider`:
- `AppDatabase` → Singleton database instance
- `MedicationService(database)` → Business logic for medications
- `UserPreferencesService(database)` → User settings operations
- ViewModels → Created per screen with `ChangeNotifierProvider`

Access in widgets:
- `context.read<T>()` → One-time access (callbacks, event handlers)
- `context.watch<T>()` → Reactive access (rebuilds on changes)

### Directory Structure
```
lib/
├── main.dart                    # Entry point, DI setup, theme provider
├── database/
│   ├── app_database.dart        # Drift database with queries
│   └── tables/                  # Table definitions (*.dart)
├── services/
│   ├── medication_service.dart  # Core business logic
│   └── user_preferences_service.dart
├── viewmodels/                  # ChangeNotifier state management
│   ├── dashboard_viewmodel.dart
│   ├── add_medication_viewmodel.dart
│   └── settings_viewmodel.dart
├── screens/                     # Top-level screens (*.screen.dart)
│   ├── dashboard.screen.dart
│   ├── add_medication/          # Multi-step flow
│   └── settings/
├── widgets/                     # Reusable UI components (*.widget.dart)
│   ├── fab/
│   ├── add_medication/
│   └── bottom_navigation/
├── models/                      # Data models
├── theme/                       # AppTheme, AppColors (Material 3)
└── navigation/                  # AppRoutes with named routes
```

## Critical Database Patterns

### Drift Database (lib/database/)

**Schema Version**: 2 (increment when tables change)

**Tables**:
1. **Medications** - Core medication data with `isActive` (soft delete), `selectedDays` (Set<Day> via custom TypeConverter)
2. **MedicationTimes** - One-to-many times per medication
3. **MedicationLogs** - Adherence tracking (status: 'taken', 'missed', 'skipped')
4. **UserPreferences** - User settings, onboarding status, theme mode

**When modifying tables**:
1. Update table definition in `lib/database/tables/[name]_table.dart`
2. Increment `schemaVersion` in `app_database.dart`
3. Add migration logic in `onUpgrade()` method
4. **Run `dart run build_runner build`** (critical step)
5. Update service methods to handle new fields
6. Update ViewModels and UI as needed

**Query patterns**:
- Use `watch()` instead of `get()` for real-time streams → Stream<List<T>>
- Wrap multi-table operations in `database.transaction()` for atomicity
- Use `where()` clauses for filtering, chain with `get()` or `watch()`

### State Management with Provider

**ViewModel pattern**:
```dart
class ExampleViewModel extends ChangeNotifier {
  final ExampleService _service;
  bool _isLoading = false;
  String? _error;
  
  // Always inject dependencies via constructor
  ExampleViewModel(this._service);
  
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();  // Update UI immediately
    
    try {
      await _service.fetchData();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();  // Update UI after completion
    }
  }
  
  @override
  void dispose() {
    // Cancel all subscriptions here
    super.dispose();
  }
}
```

**Stream subscriptions** (dashboard pattern):
```dart
StreamSubscription? _subscription;

void startWatching() {
  _subscription = _service.watchData().listen((data) {
    // Update state
    notifyListeners();
  });
}

@override
void dispose() {
  _subscription?.cancel();  // Critical to prevent memory leaks
  super.dispose();
}
```

## File Naming Conventions

- **Screens**: `[name].screen.dart` (top-level with app bar/navigation)
- **Views**: `[name].view.dart` (sub-screens in multi-step flows)
- **Widgets**: `[name].widget.dart` (reusable components)
- **ViewModels**: `[name]_viewmodel.dart` (state management)
- **Services**: `[name]_service.dart` (business logic)
- **Models**: `[name].dart` (singular)

**Always use absolute imports**: `package:med_track_v2/...`

## Service Layer Patterns

**MedicationService** is the core business logic layer:
- `addMedication()` - Creates medication + times in single transaction
- `getTodaysMedications()` - Returns List<MedicationData> with calculated status
- `getNextDoseMedication()` - Determines next medication due
- `markMedicationTaken()` - Creates/updates log entry
- `getDashboardStats()` - Calculates streak and adherence
- `watchTodaysMedications()` - Stream for real-time updates

**Status calculation logic**: Medications are assigned status (takeNow, upcoming, taken, missed) based on current time, scheduled times, and log entries. This logic lives in the service layer, not UI.

## Theming and UI

**Material 3 compliance**:
- Use `Theme.of(context).textTheme.[style]` for text (headlineLarge, bodyLarge, etc.)
- Use `Theme.of(context).colorScheme.[color]` for colors (primary, surface, onSurface, etc.)
- Avoid hardcoded colors/sizes
- Button style: `ElevatedButton.styleFrom()` with elevation 0, rounded borders (24px)
- Card elevation: 4 with subtle shadows, 16px radius, 16px padding

**Theme management**:
- Handled via `ThemeModeProvider` InheritedWidget in main.dart
- Supports system/light/dark modes
- Persisted in UserPreferences table

**Text scaling**: Clamped between 0.8x - 1.2x  
**Orientation**: Portrait only

## Multi-Step Flow Pattern

**Example**: Add Medication screen uses `PageView` with:
- `PageController` for programmatic page control
- `NeverScrollableScrollPhysics()` to prevent swipe navigation
- Shared `AddMedicationViewModel` across all 3 views
- Manual next/back buttons control navigation

## Onboarding Flow

**First launch**: `AppWrapper` in main.dart checks `hasCompletedOnboarding`:
- If false → Navigate to `WelcomeScreen` (collects username)
- If true → Navigate to `DashboardScreen`

After username entry, `UserPreferencesService.completeOnboarding()` sets flag.

## Testing Approach

Check README or codebase for test framework. Standard Flutter patterns:
- **Unit tests**: Mock services, test ViewModels in isolation
- **Widget tests**: Wrap with providers, use `pumpAndSettle()` for async
- Use `find.text()`, `find.byType()` for assertions

Run with: `flutter test`

## Common Pitfalls

1. **Forgetting build_runner**: Database table changes require regeneration
2. **Missing Provider**: Ensure ViewModels are provided before `context.read<T>()`
3. **Stream leaks**: Always cancel subscriptions in `dispose()`
4. **Transaction omission**: Multi-table operations need `database.transaction()`
5. **Hardcoded theme values**: Always use `Theme.of(context)` for consistency

## Code Quality

**Linting**: Uses `package:flutter_lints/flutter.yaml`
- Run `flutter analyze` before committing
- Prefer const constructors for performance
- Use trailing commas for multi-line parameters
- Single quotes for strings

**Performance**:
- Use `const` for static widgets
- Use `ListView.builder` for long lists
- Extract expensive calculations outside build methods
