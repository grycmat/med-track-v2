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
- `lib/widgets/` - Reusable UI components including cards and navigation
- `lib/screens/` - Screen-level components
- `lib/models/` - Data models and enums

### Theming System
The app uses a comprehensive theming system:
- **AppColors**: Centralized color palette with light/dark mode support
- **AppTheme**: Complete Material 3 theme configurations for both light and dark modes
- **ThemeController**: State management for theme switching (system/light/dark)

Primary color: `#D18AF5` (purple)

### Widget Architecture
- **ProgressCard**: Displays medication progress with linear progress indicators
- **MedicationCard**: Shows individual medication items with status chips
- **CircularProgressCard**: Weekly progress overview with statistics
- **CustomBottomNavBar**: Custom navigation with blur effects
- **MedicationStatus enum**: `takeNow`, `upcoming`, `taken`, `missed`

### Current State
The app appears to be in early development:
- Main UI components are defined but DashboardScreen is referenced but not implemented
- Core theming and widget foundation is complete
- Ready for feature implementation (screens, data models, state management)

## Development Notes

- Uses Material 3 design system
- Font family: Manrope (configured in theme)
- Supports both light and dark themes with system preference detection
- Custom status bar styling configured for transparent overlay
- Uses flutter_lints for code quality enforcement