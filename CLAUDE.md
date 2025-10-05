# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called "Medication Tracker" (med_track_v2) - a mobile app for tracking medication schedules and adherence.

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

The app follows a modular Flutter architecture with clear separation of concerns:

### Key Directories
- `lib/main.dart` - App entry point with MaterialApp setup and ThemeController
- `lib/theme/` - Centralized theming system with AppTheme and AppColors
- `lib/widgets/` - Reusable UI components including cards, navigation, and FAB
- `lib/widgets/add_medication/` - Specialized widgets for add medication flow
- `lib/screens/` - Screen-level components
- `lib/screens/add_medication/` - Multi-step add medication flow (details, frequency, review)
- `lib/models/` - Data models and enums
- `lib/viewmodels/` - State management using ChangeNotifier pattern
- `lib/navigation/` - Centralized routing configuration
- `lib/data/` - Dummy/mock data for development

### State Management
Uses **Provider** pattern with ChangeNotifier:
- `AddMedicationViewModel` - Manages multi-step medication creation form state
-ViewModel holds medication details, dosage, frequency settings, selected days, and times
- Each screen in the add medication flow shares the same ViewModel instance via ChangeNotifierProvider

### Navigation Architecture
- `AppRoutes` class defines all route constants and route generation logic
- Uses named routes with `AppRoutes.generateRoute()`
- PageView with PageController for multi-step flows (add medication)
- NeverScrollableScrollPhysics to prevent swipe navigation between steps

### Theming System
The app uses a comprehensive theming system:
- **AppColors**: Centralized color palette with light/dark mode support
- **AppTheme**: Complete Material 3 theme configurations for both light and dark modes
- **ThemeController**: State management for theme switching (system/light/dark)

Primary color: `#D18AF5` (purple) with gradient variants for both light and dark modes

### Widget Architecture
Custom widgets organized by feature:
- **Core widgets**: ProgressCard, StatsCard, MedicationCard, CustomAppBar, CustomBottomNavBar
- **FAB system**: ExpandableFAB with animated action buttons using Transform animations
- **Add medication widgets**: CustomTextField, FrequencySelector, DayOfWeekPicker, TimeOfDayWidget, ReviewItem, GradientButton
- **MedicationStatus enum**: `takeNow`, `upcoming`, `taken`, `missed`

### Add Medication Flow
Multi-step wizard with three views:
1. **MedicationDetailsView** - Name and dosage input
2. **MedicationFrequencyView** - Frequency selection (daily/weekly/specific days) and time scheduling
3. **MedicationReviewView** - Review and confirm all details

All views share a PageController for navigation and access the same AddMedicationViewModel.

## Development Notes

- Uses Material 3 design system with custom gradient theming
- Font family: Manrope (configured in theme)
- Supports both light and dark themes with system preference detection
- Custom status bar styling configured for transparent overlay
- Uses flutter_lints for code quality enforcement
- Dependencies: provider (state management), intl (internationalization)
- Currently uses dummy data in `lib/data/dummy_data.dart` for development