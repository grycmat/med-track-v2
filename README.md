# Medication Tracker

A Flutter mobile app for tracking medication schedules and adherence.

## Features

- 📊 Daily medication progress tracking
- 💊 Medication schedule management
- 🌙 Light/dark theme support
- 📱 Material 3 design system
- 🎯 Take now reminders

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Architecture

The project follows a clean architecture with a clear separation of concerns. The main components are:

- **`lib/screens`**: Contains the application's screens, such as the `DashboardScreen` and the `AddMedicationScreen`.
- **`lib/widgets`**: Contains reusable UI components that are used across multiple screens.
- **`lib/models`**: Contains the data models for the application.
- **`lib/viewmodels`**: Contains the view models for the application, which are used to manage the state of the views.
- **`lib/theme`**: Contains the application's theme and color scheme.
- **`lib/navigation`**: Contains the application's routing logic.

For a more detailed overview of the project, please see the `GEMINI.md` file.