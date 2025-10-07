# Med Track v2

This is a Flutter project for a medication tracking application.

## Project Overview

The project is a mobile application designed to help users track their medication schedules. It features a dashboard to view daily progress, a way to manage medication schedules, and supports both light and dark themes. The application is built with Flutter and uses the Material 3 design system.

### Key Technologies

*   **Framework:** Flutter
*   **Language:** Dart
*   **State Management:** `provider`
*   **Design:** Material 3

## Architecture

The project follows a clean architecture with a clear separation of concerns.

*   **`lib/main.dart`**: The entry point of the application. It initializes the app and sets up the theme.
*   **`lib/screens`**: Contains the application's screens, such as the `DashboardScreen` and the `AddMedicationScreen`.
*   **`lib/widgets`**: Contains reusable UI components that are used across multiple screens.
    *   `CustomAppBar`: A custom app bar with a greeting, user avatar, and theme toggle button.
    *   `MedicationCard`: A card that displays information about a medication, including its name, dosage, and status.
    *   `ProgressCard`: A card that shows the user's daily medication progress.
*   **`lib/models`**: Contains the data models for the application.
    *   `Medication`: Represents a medication with its name, dosage, time, and status.
    *   `MedicationStatus`: An enum that represents the status of a medication (e.g., `takeNow`, `upcoming`, `taken`, `missed`).
*   **`lib/viewmodels`**: Contains the view models for the application, which are used to manage the state of the views.
    *   `AddMedicationViewModel`: Manages the state of the "Add Medication" screen.
*   **`lib/theme`**: Contains the application's theme and color scheme.
*   **`lib/navigation`**: Contains the application's routing logic.
    *   `AppRoutes`: Defines the routes for the application and generates the appropriate `MaterialPageRoute` for each route.
*   **`lib/data`**: Contains the application's data sources.
    *   `dummy_data.dart`: Contains dummy data for the application.

## State Management

The project uses the `provider` package for state management. The `AddMedicationViewModel` is a `ChangeNotifier` that manages the state of the "Add Medication" screen. The `DashboardScreen` manages its own state using `setState`.

## Building and Running

To get the application running, follow these steps:

1.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Run the app:**
    ```bash
    flutter run
    ```

3.  **Run tests:**
    ```bash
    flutter test
    ```

4.  **Analyze code:**
    ```bash
    flutter analyze
    ```