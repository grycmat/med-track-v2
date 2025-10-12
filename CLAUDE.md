# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called "Medication Tracker" (med_track_v2) - a mobile app for tracking medication schedules and adherence. The app is in active development with a functional UI prototype using dummy data.

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

### Testing Commands
- `flutter test test/widget_test.dart` - Run specific test file
- `flutter test --coverage` - Run tests with coverage report

## Architecture Overview

The app follows a modular Flutter architecture with clear separation of concerns and Material 3 design principles.

### Key Directories
- `lib/main.dart` - App entry point with MaterialApp, theme switching, and utility extensions
- `lib/theme/` - Centralized theming system (AppTheme, AppColors)
- `lib/widgets/` - Reusable UI components
  - `lib/widgets/fab/` - Floating Action Button components (FAB, ExpandableFAB, FABActionButton)
  - `lib/widgets/add_medication/` - Add medication flow widgets
- `lib/screens/` - Screen-level components
  - `lib/screens/add_medication/` - Multi-step medication creation flow
- `lib/models/` - Data models and enums (Medication, MedicationData, FABAction, StatisticItem)
- `lib/viewmodels/` - State management using ChangeNotifier pattern
- `lib/navigation/` - Centralized routing configuration (currently minimal, mostly direct navigation)
- `lib/data/` - Dummy/mock data for development (dummyData, dummyStats)
- `lib/services/` - Service layer (currently empty, placeholder for future API/database services)

### State Management
Uses **Provider** pattern with ChangeNotifier:
- **AddMedicationViewModel** (`lib/viewmodels/add_medication_viewmodel.dart`) - Manages multi-step medication creation form
  - Holds: medication name, dosage (amount + unit), frequency (daily/weekly/specificDays), selected days (Set<Day>), and times (List<TimeOfDay>)
  - Methods: setters for all fields, toggleDay(), addTime(), removeTime()
  - Shared across all three views in add medication flow via ChangeNotifierProvider
- **Theme Management** - Handled via stateful widget in main.dart (AppWrapper InheritedWidget + _MedTrackV2AppState)
  - Supports ThemeMode.system, ThemeMode.light, ThemeMode.dark
  - Currently managed at app level, toggled from dashboard

### Navigation Architecture
- **Named routes** defined in `AppRoutes` class (`lib/navigation/routes.dart`)
  - Routes: `/` (dashboard), `/add-medication`, `/schedule`, `/history`, `/settings`
  - Most routes currently show placeholder screens (except dashboard)
- **Direct navigation** used for add medication flow (MaterialPageRoute push)
- **PageView with PageController** for multi-step flows
  - `NeverScrollableScrollPhysics()` prevents swipe navigation
  - Manual page control via next/back buttons

### Theming System
Comprehensive Material 3 theming with full light/dark mode support:
- **AppColors** (`lib/theme/app_colors.dart`) - Complete color palette
  - Light mode: lightBg, lightPrimary, lightHeader, lightText, etc.
  - Dark mode: darkBg, darkPrimary, darkHeader, darkText, etc.
  - Semantic colors: success, warning, error, info, purple
- **AppTheme** (`lib/theme/app_theme.dart`) - Material 3 ThemeData configurations
  - Font family: **Manrope** (must be added to pubspec.yaml if custom fonts needed)
  - Custom TextTheme with 8 text styles (displayLarge to labelMedium)
  - ElevatedButton and Card themes with rounded corners
  - Primary color: Purple gradient variants

### Core Models
- **Medication** - Basic medication model (name, dosage, time, status)
- **MedicationData** - Extended medication with dueInfo and icon fields
- **MedicationStatus enum** - `takeNow`, `upcoming`, `taken`, `missed`
- **Frequency enum** - `daily`, `weekly`, `specificDays`
- **Day enum** - Seven days with shortName extension (S, M, T, W, T, F, S)
- **FABAction** - Model for FAB action buttons (icon, label, onPressed)
- **StatItem** - Statistics display model (icon, value, label, color, animationDelay)

### Widget Architecture

#### Core Widgets
- **CustomAppBar** (`custom_app_bar.widget.dart`) - App bar with greeting, notifications, theme toggle
- **CustomBottomNavigation** (`custom_bottom_navigation.widget.dart`) - Bottom navigation bar
- **ProgressCard** (`progress_card.widget.dart`) - Shows daily medication completion progress
- **StatsCard** (`stats_card.widget.dart`) - Displays statistics (streak, adherence %)
- **MedicationCard** (`medication_card.widget.dart`) - Individual medication display with status
- **SplashScreen** (`splash_screen.widget.dart`) - Splash screen wrapper widget

#### FAB System
- **CustomFloatingActionButton** (`fab/fab.widget.dart`) - Simple FAB for add medication
- **ExpandableFAB** (`fab/expandable_fab.widget.dart`) - Expandable FAB with multiple actions
- **FABActionButton** (`fab/fab_action_button.widget.dart`) - Individual action button with animation

#### Add Medication Widgets
- **CustomTextField** - Custom text input field
- **DosageInput** - Specialized dosage input with unit selector
- **FrequencySelector** - Frequency selection (daily/weekly/specific days)
- **DayOfWeekPicker** - Day selection for specific days frequency
- **TimeOfDayWidget** - Time picker for medication schedule
- **ReviewItem** - Display item in review step
- **GradientButton** - Gradient styled button used across app
- **StepProgressBar** - Progress indicator for multi-step flow

### Main Screens

#### DashboardScreen (`lib/screens/dashboard.screen.dart`)
- **Features**:
  - Greeting based on time of day
  - Daily progress tracking with ProgressCard
  - "Next Dose" section showing upcoming medication
  - "Today's Schedule" showing all medications with status
  - Quick stats (weekly adherence %, day streak)
  - Theme toggle (light/dark mode)
  - Bottom navigation (4 items)
  - FAB for adding medications
- **State**: Uses dummy data, local state management with setState
- **Interactions**: Take medication (marks as taken), theme toggle, navigation

#### AddMedicationScreen (`lib/screens/add_medication/add_medication.screen.dart`)
Multi-step wizard with Provider-based state management:

1. **MedicationDetailsView** - Name and dosage input
   - CustomTextField for medication name
   - DosageInput for amount and unit selection
   - Validates inputs before allowing next step

2. **MedicationFrequencyView** - Frequency and time scheduling
   - FrequencySelector (daily/weekly/specific days)
   - DayOfWeekPicker (shown for specificDays frequency)
   - TimeOfDayWidget for adding multiple reminder times
   - Validates at least one time is selected

3. **MedicationReviewView** - Review and confirm
   - ReviewItem widgets showing all entered data
   - Back button to edit
   - "Add Medication" button to save (currently returns to dashboard)

**Progress**: StepProgressBar shows current step (1/3, 2/3, 3/3)

### Data Layer
**Current State**: Using dummy data only (no persistence)
- **Location**: `lib/data/dummy_data.dart`
- **Data**: 5 sample medications with various statuses, 2 stat items
- **Persistence**: None - data resets on app restart
- **Future**: Ready for implementation of local database (sqflite/hive) or API integration via `lib/services/`

### Utility Extensions (`lib/main.dart`)
- **StringExtension**: `.capitalize` - Capitalizes first letter
- **DateTimeExtension**:
  - `.timeOfDayString` - Formats time as "3:30 PM"
  - `.dayName` - Returns abbreviated day name
  - `.isToday` - Checks if date is today
  - `.isTomorrow` - Checks if date is tomorrow

### App Configuration
- **Orientation**: Portrait only (portraitUp, portraitDown)
- **Status bar**: Transparent with dark icons on light mode
- **Text scaling**: Clamped between 0.8x and 1.2x for accessibility
- **Material Design**: Version 3
- **Debug banner**: Disabled

## Development Status & Next Steps

### Implemented Features
- Complete UI/UX design with light/dark theme
- Dashboard with medication list and statistics
- Multi-step medication creation flow (UI only)
- Theme switching
- Animations and haptic feedback
- Responsive Material 3 design

### Not Yet Implemented
- Data persistence (local database)
- Medication editing/deletion
- Notification system
- Schedule, History, and Settings screens (placeholder only)
- API integration
- User authentication
- Medication reminders/alarms
- Export/import functionality
- Unit tests and widget tests

### Current Limitations
- No data persistence - all data is lost on app restart
- Add medication flow doesn't actually save data
- Bottom navigation routes lead to placeholder screens
- No error handling or validation feedback beyond form validation
- No services layer implementation

## Dependencies

**Production**:
- `cupertino_icons: ^1.0.8` - iOS-style icons
- `intl: ^0.19.0` - Internationalization and date formatting
- `provider: ^6.1.2` - State management

**Development**:
- `flutter_lints: ^5.0.0` - Code quality and linting rules

## Notes for Development

- All file paths use absolute imports (package:med_track_v2/...)
- Widget files use `.widget.dart` suffix for easy identification
- Screen files use `.screen.dart` suffix
- View files (sub-screens) use `.view.dart` suffix
- ViewModel files use `_viewmodel.dart` suffix
- Consistent use of const constructors for performance
- Material 3 design throughout
- Ready for internationalization (intl package included)
- **Services directory exists but is empty** - ready for database/API implementation
- Dummy data can be replaced with real data by implementing services and updating dashboard/viewmodels