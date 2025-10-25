# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called "Medication Tracker" (med_track_v2) - a mobile app for tracking medication schedules and adherence. The app features a functional UI with database persistence using Drift (SQLite).

**SDK Version**: Dart ^3.9.2
**Flutter Version**: Latest stable

## Development Commands

### Core Flutter Commands
- `flutter run` - Run the app in debug mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter test` - Run all tests
- `flutter analyze` - Run static analysis and linting
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter clean` - Clean build artifacts

### Drift (Database) Commands
- `dart run build_runner build` - Generate Drift database code (app_database.g.dart)
- `dart run build_runner build --delete-conflicting-outputs` - Force regenerate database code
- `dart run build_runner watch` - Watch for changes and regenerate automatically

Run build_runner after modifying database table files to regenerate the database classes.

## Architecture Overview

The app follows a layered Flutter architecture with Provider-based state management, Drift for local persistence, and Material 3 design principles.

### Key Directories
- `lib/main.dart` - App entry point with dependency injection, theme management, and onboarding flow
- `lib/theme/` - Centralized theming system (AppTheme, AppColors)
- `lib/widgets/` - Reusable UI components
  - `lib/widgets/fab/` - Floating Action Button components
  - `lib/widgets/add_medication/` - Add medication form widgets
  - `lib/widgets/bottom_navigation/` - Bottom navigation components
- `lib/screens/` - Screen-level components
  - `lib/screens/dashboard.screen.dart` - Main dashboard with medications list
  - `lib/screens/add_medication/` - Multi-step medication creation flow
  - `lib/screens/welcome_screen.dart` - Onboarding screen
  - `lib/screens/settings/` - Settings screen
- `lib/models/` - Data models (Medication, MedicationData, FABAction, StatItem)
- `lib/viewmodels/` - State management using ChangeNotifier pattern
  - `dashboard_viewmodel.dart` - Dashboard state
  - `add_medication_viewmodel.dart` - Add medication form state
  - `user_preferences_viewmodel.dart` - User preferences state
  - `settings_viewmodel.dart` - Settings screen state
- `lib/database/` - Drift database layer
  - `app_database.dart` - Main database class with query methods
  - `tables/` - Table definitions (Medications, MedicationTimes, MedicationLogs, UserPreferences)
- `lib/services/` - Service layer
  - `medication_service.dart` - Business logic for medication operations
  - `user_preferences_service.dart` - User preferences operations
- `lib/navigation/` - Routing configuration (AppRoutes)

### Database Architecture (Drift)

The app uses **Drift** (formerly Moor) for local SQLite persistence:

**Schema Version**: 2

**Tables**:
1. **Medications** - Stores medication details
   - Fields: id, name, dosageAmount, dosageUnit, frequency, selectedDays (Set<Day>), createdAt, isActive
   - selectedDays uses custom TypeConverter (SelectedDaysConverter) to serialize Set<Day> to JSON

2. **MedicationTimes** - Stores scheduled times for each medication (one-to-many)
   - Fields: id, medicationId (FK), hour, minute
   - Foreign key references Medications.id

3. **MedicationLogs** - Tracks medication adherence (many-to-many)
   - Fields: id, medicationId (FK), medicationTimeId (FK), logDate, status, takenAt
   - Status values: 'taken', 'missed', 'skipped'

4. **UserPreferences** - Stores user settings and onboarding status
   - Fields: id, username, hasCompletedOnboarding, themeMode
   - Added in schema version 2

**Key Database Methods** (app_database.dart):
- CRUD operations for all tables
- `watchActiveMedications()` - Stream of active medications
- `watchLogsForDate()` - Stream of logs for specific date
- `getLogForMedicationTimeAndDate()` - Check if medication was taken
- `countTakenLogsForDateRange()` - Calculate adherence statistics

**Code Generation**: Drift uses build_runner to generate database code. The generated file `app_database.g.dart` must not be edited manually.

### State Management

Uses **Provider** pattern with ChangeNotifier:

**DashboardViewModel** (`lib/viewmodels/dashboard_viewmodel.dart`):
- Manages dashboard state (medications list, next dose, statistics)
- Methods: `loadDashboardData()`, `markMedicationTaken()`, `startWatchingMedications()`
- Uses Stream subscription to watch medication changes in real-time

**AddMedicationViewModel** (`lib/viewmodels/add_medication_viewmodel.dart`):
- Manages multi-step medication form state
- Holds: medicationName, dosageAmount, dosageUnit, frequency, selectedDays, times
- Methods: setters for all fields, `toggleDay()`, `addTime()`, `removeTime()`, `saveMedication()`, `resetForm()`
- Shared across all three views in add medication flow via ChangeNotifierProvider

**UserPreferencesViewModel**:
- Manages username and onboarding state
- Methods: `loadUsername()`, `saveUsername()`, `completeOnboarding()`

**Theme Management**:
- Handled via ThemeModeProvider InheritedWidget in main.dart
- Supports ThemeMode.system, ThemeMode.light, ThemeMode.dark
- Theme preference persisted in UserPreferences table

### Services Layer

**MedicationService** (`lib/services/medication_service.dart`):
- Core business logic for medication operations
- Key methods:
  - `addMedication()` - Creates medication and associated times in transaction
  - `getTodaysMedications()` - Returns List<MedicationData> for today with calculated status
  - `getNextDoseMedication()` - Returns next medication to take
  - `markMedicationTaken()` - Creates/updates medication log
  - `updateMedication()` - Updates medication and replaces all times
  - `deleteMedication()` - Soft deletes medication (sets isActive = false)
  - `getDashboardStats()` - Returns List<StatItem> with streak and adherence
  - `calculateStreak()` - Calculates consecutive days with 100% adherence
  - `calculateWeeklyAdherence()` - Calculates 7-day adherence percentage
  - `watchTodaysMedications()` - Stream of today's medications
- Status determination: Automatically calculates status (takeNow, upcoming, taken, missed) based on time and logs
- Uses transactions for data consistency

**UserPreferencesService**:
- Manages user preferences CRUD operations
- Methods: `hasCompletedOnboarding()`, `completeOnboarding()`, `getUsername()`, `saveUsername()`, `getThemeMode()`, `saveThemeMode()`

### Dependency Injection

Dependencies are injected at app startup in `main()`:
```dart
final database = AppDatabase();
final medicationService = MedicationService(database);
final userPreferencesService = UserPreferencesService(database);
```

Provided via MultiProvider:
- AppDatabase (Provider.value)
- MedicationService (Provider.value)
- UserPreferencesService (Provider.value)
- UserPreferencesViewModel (ChangeNotifierProvider)

Accessed in widgets using:
- `context.read<T>()` - One-time access (e.g., in event handlers)
- `context.watch<T>()` - Rebuilds on changes

### Navigation Architecture

**Named routes** defined in `AppRoutes` class (`lib/navigation/routes.dart`):
- Routes: `/` (dashboard), `/add-medication`, `/schedule`, `/history`, `/settings`
- Most routes currently show placeholder screens (except dashboard and settings)

**Direct navigation** used for:
- Add medication flow (MaterialPageRoute push)
- Settings screen (MaterialPageRoute push)

**PageView** for multi-step flows:
- Uses PageController with `NeverScrollableScrollPhysics()` to prevent swipe
- Manual page control via next/back buttons

### Theming System

Comprehensive Material 3 theming with full light/dark mode support:
- **AppColors** - Complete color palette with light/dark variants
- **AppTheme** - Material 3 ThemeData configurations
- Font family: **Manrope** (note: currently using default, custom font not configured in pubspec.yaml)
- Custom TextTheme with 8 text styles
- Primary color: Purple gradient variants

### Core Models

**Medication** (Drift table entity):
- Generated by Drift from Medications table
- Fields: id, name, dosageAmount, dosageUnit, frequency, selectedDays, createdAt, isActive

**MedicationData** (`lib/models/medication.dart`):
- UI-friendly model with computed fields
- Extends basic medication data with: status, dueInfo, icon, timeId
- Used in UI to display medications with their current status

**Enums**:
- `Frequency` - daily, weekly, specificDays (in add_medication_viewmodel.dart)
- `Day` - sunday through saturday with shortName extension
- `MedicationStatus` - takeNow, upcoming, taken, missed

### Onboarding Flow

**WelcomeScreen** (`lib/screens/welcome_screen.dart`):
- First-run experience to collect username
- Uses WelcomeViewModel to manage state
- Saves username and sets hasCompletedOnboarding flag
- App checks onboarding status on startup and routes accordingly

**AppWrapper** (_AppWrapperState in main.dart):
- Checks onboarding status on app startup
- Routes to WelcomeScreen if not completed
- Routes to DashboardScreen if completed

### Main Screens

**DashboardScreen** (`lib/screens/dashboard.screen.dart`):
- Features: Sliver app bar with greeting, daily progress, next dose section, today's schedule, quick stats
- Uses DashboardViewModel with Provider
- Real-time updates via Stream subscription
- Bottom navigation with 4 tabs (Medications, Schedule, History, Settings)

**AddMedicationScreen** (`lib/screens/add_medication/add_medication.screen.dart`):
Multi-step wizard (3 steps):
1. MedicationDetailsView - Name and dosage
2. MedicationFrequencyView - Frequency and times
3. MedicationReviewView - Review and save

Uses AddMedicationViewModel shared across all views.

**SettingsScreen** (`lib/screens/settings/settings.screen.dart`):
- Theme mode selection (system, light, dark)
- Username display and edit
- Uses SettingsViewModel

### Utility Extensions

Defined in `lib/main.dart`:
- **StringExtension**: `.capitalize`
- **DateTimeExtension**: `.timeOfDayString`, `.dayName`, `.isToday`, `.isTomorrow`

### App Configuration

- **Orientation**: Portrait only
- **Status bar**: Transparent with dark icons on light mode
- **Text scaling**: Clamped between 0.8x and 1.2x
- **Material Design**: Version 3
- **Debug banner**: Disabled

## Development Workflow

### Adding a New Medication Field

1. Update `Medications` table in `lib/database/tables/medications_table.dart`
2. Increment `schemaVersion` in `app_database.dart`
3. Add migration logic in `onUpgrade` method
4. Run `dart run build_runner build` to regenerate code
5. Update `MedicationService.addMedication()` to include new field
6. Update `AddMedicationViewModel` if field needs UI input
7. Update UI components to display/edit the new field

### Adding a New Screen

1. Create screen file in `lib/screens/`
2. Add route constant in `lib/navigation/routes.dart`
3. Add route case in `AppRoutes.generateRoute()`
4. Create ViewModel in `lib/viewmodels/` if needed
5. Provide ViewModel in screen's build method or parent
6. Update navigation calls to use new route

### Common Pitfalls

- **Forgetting to run build_runner**: Changes to Drift tables require regeneration
- **Missing Provider**: Ensure ViewModels are provided before accessing with `context.read()`
- **Stream subscriptions**: Always cancel subscriptions in ViewModel.dispose()
- **Transaction usage**: Use `database.transaction()` for multi-table operations to ensure atomicity

## Notes for Development

- All file paths use absolute imports (`package:med_track_v2/...`)
- Widget files use `.widget.dart` suffix
- Screen files use `.screen.dart` suffix
- View files (sub-screens) use `.view.dart` suffix
- ViewModel files use `_viewmodel.dart` suffix
- Consistent use of const constructors for performance
- Database operations are async - always await or handle Futures/Streams
- Soft delete pattern used for medications (isActive flag)
