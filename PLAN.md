# Medication Tracker - Implementation Plan

## Project Requirements

This medication tracking app should provide:
- Create and manage user settings
- Dark/light mode
- Adding drug to schedule
- Medications list (all medications view)
- Schedule preview (calendar-based)
- Local notifications

## Implementation Status

### ✅ Already Implemented (5/9)

#### 1. User Settings Management ✅
**Status**: Complete

**Implementation**:
- Settings screen with username management (`lib/screens/settings/settings.screen.dart`)
- UserPreferences table in database
- UserPreferencesService and SettingsViewModel
- Onboarding flow with WelcomeScreen

**Files**:
- `lib/screens/settings/settings.screen.dart`
- `lib/viewmodels/settings_viewmodel.dart`
- `lib/services/user_preferences_service.dart`
- `lib/database/tables/user_preferences_table.dart`
- `lib/screens/welcome_screen.dart`

---

#### 2. Dark/Light Mode ✅
**Status**: Complete

**Implementation**:
- Full theme system with Material 3 design
- ThemeModeProvider with system/light/dark modes
- Theme preference persisted in UserPreferences table
- AppColors with complete light/dark variants
- Settings screen integration for theme switching

**Files**:
- `lib/theme/app_theme.dart`
- `lib/theme/app_colors.dart`
- `lib/main.dart` (ThemeModeProvider)
- `lib/screens/settings/settings.screen.dart`

---

#### 3. Adding Drug to Schedule ✅
**Status**: Complete

**Implementation**:
- Complete 3-step medication creation wizard:
  - Step 1: Medication details (name, dosage)
  - Step 2: Frequency and times
  - Step 3: Review and save
- AddMedicationViewModel with full state management
- Support for daily/weekly/specific days scheduling
- Multiple times per day support

**Files**:
- `lib/screens/add_medication/add_medication.screen.dart`
- `lib/screens/add_medication/views/medication_details.view.dart`
- `lib/screens/add_medication/views/medication_frequency.view.dart`
- `lib/screens/add_medication/views/medication_review.view.dart`
- `lib/viewmodels/add_medication_viewmodel.dart`
- `lib/services/medication_service.dart`

---

#### 4. Dashboard Schedule Preview ✅
**Status**: Complete

**Implementation**:
- Today's medications list with status (takeNow, upcoming, taken, missed)
- Next dose section showing upcoming medication
- Daily progress indicator
- Quick stats (streak, adherence)
- Real-time updates via Stream subscriptions

**Files**:
- `lib/screens/dashboard.screen.dart`
- `lib/viewmodels/dashboard_viewmodel.dart`
- `lib/services/medication_service.dart`

---

#### 5. Medications List Screen ✅
**Status**: Complete

**Implementation**:
- Full list of all medications (active and inactive)
- Search functionality by medication name and dosage unit
- Filter options (All, Active, Inactive)
- Toggle medication active/inactive status
- Pull-to-refresh support
- Empty state UI
- Bottom navigation integration with 5 items:
  - Today (dashboard)
  - Medications (list view)
  - Schedule (calendar - coming soon)
  - History (logs - coming soon)
  - Settings

**Files**:
- `lib/screens/medications_list/medications_list.screen.dart`
- `lib/viewmodels/medications_list_viewmodel.dart`
- `lib/services/medication_service.dart` (added `watchAllMedications`, `toggleMedicationActive`)
- `lib/database/app_database.dart` (added `watchAllMedications`)
- `lib/navigation/routes.dart` (added `/medications` route)
- `lib/screens/dashboard.screen.dart` (updated bottom nav to 5 items)

**Features**:
- Real-time updates via Stream subscription
- Search with debouncing
- Filter chips for quick filtering
- Material 3 design with dark/light mode support
- Haptic feedback on interactions
- Status badges (Active/Inactive)
- Quick actions (Activate/Deactivate, Edit)

---

### ❌ Not Yet Implemented (4/9)

#### 6. Dedicated Schedule Screen ⏳
**Status**: Not Implemented (placeholder exists)

**Current State**:
- Route exists (`/schedule`) but shows placeholder screen

**Needs**:
- Full calendar view with all scheduled medications
- Week/month view options
- Filtering by medication
- Date navigation
- Visual timeline of daily medications

**Estimated Complexity**: Medium

**Files to Create/Update**:
- `lib/screens/schedule/schedule.screen.dart`
- `lib/viewmodels/schedule_viewmodel.dart`
- `lib/widgets/schedule/` (calendar components)

---

#### 7. History Screen ⏳
**Status**: Not Implemented (placeholder exists)

**Current State**:
- Route exists (`/history`) but shows placeholder screen
- Database has MedicationLogs table with historical data

**Needs**:
- Past medication logs view
- Adherence statistics over time
- Filtering by date range and medication
- Visual charts/graphs for adherence trends
- Export functionality (optional)

**Estimated Complexity**: Medium

**Files to Create/Update**:
- `lib/screens/history/history.screen.dart`
- `lib/viewmodels/history_viewmodel.dart`
- `lib/widgets/history/` (chart components)
- Update `medication_service.dart` with historical queries

---

#### 8. Local Notifications ⏳ **CRITICAL**
**Status**: Not Implemented

**Current State**:
- No notification system exists
- Medications have scheduled times but no reminders

**Needs**:
- Add `flutter_local_notifications` package
- Notification scheduling service
- Background notification scheduling based on medication times
- Notification actions (mark as taken, snooze)
- Permission handling (Android/iOS)
- Sound/vibration settings
- Notification settings in Settings screen
- Reschedule notifications after app restart

**Estimated Complexity**: High

**Files to Create/Update**:
- `lib/services/notification_service.dart`
- `pubspec.yaml` (add dependencies)
- `android/app/src/main/AndroidManifest.xml` (permissions)
- `ios/Runner/Info.plist` (permissions)
- Update `medication_service.dart` to trigger notifications
- Update `lib/screens/settings/settings.screen.dart` (notification preferences)

**Dependencies Needed**:
```yaml
flutter_local_notifications: ^17.0.0
timezone: ^0.9.0
permission_handler: ^11.0.0
```

---

#### 9. Edit Medication Flow ⏳
**Status**: Partially Implemented (backend only)

**Current State**:
- Database method exists (`updateMedication()` in medication_service.dart)
- No UI implementation

**Needs**:
- Edit medication screen/dialog (reuse AddMedicationViewModel pattern)
- Pre-populate existing medication data
- Delete medication functionality (soft delete)
- Navigation from dashboard to edit screen
- Confirmation dialogs for destructive actions

**Estimated Complexity**: Medium

**Files to Create/Update**:
- `lib/screens/edit_medication/edit_medication.screen.dart`
- Reuse `lib/viewmodels/add_medication_viewmodel.dart` or create new EditMedicationViewModel
- Update `lib/screens/dashboard.screen.dart` (add edit action)

---

## Priority Recommendations

### High Priority (Core Functionality)
1. **Local Notifications** - Critical for medication adherence
   - Without notifications, users may forget to take medications
   - Core value proposition of the app

2. **Edit Medication** - Essential for user flexibility
   - Users need to update dosages, times, or discontinue medications
   - Currently can only add but not modify

### Medium Priority (Enhanced UX)
3. **Dedicated Schedule Screen** - Better schedule visualization
   - See medications beyond today
   - Plan ahead for travel or schedule changes

4. **History Screen** - Track adherence over time
   - Motivational feedback
   - Share with healthcare providers

## Technical Debt & Improvements

### Current Issues
- [ ] Custom font "Manrope" defined but not configured in pubspec.yaml
- [ ] Schedule and History routes show placeholders
- [ ] No error handling for database failures
- [ ] No offline/online sync (local-only app)

### Future Enhancements
- [ ] Medication images/icons
- [ ] Refill reminders
- [ ] Doctor appointments integration
- [ ] Export data to PDF
- [ ] Backup/restore functionality
- [ ] Multi-user support (family profiles)
- [ ] Medication interaction warnings

## Getting Started with Remaining Features

### To implement Local Notifications:
1. Add dependencies to `pubspec.yaml`
2. Create `NotificationService` class
3. Initialize in `main.dart`
4. Schedule notifications when medications are created
5. Handle notification taps to mark as taken
6. Add notification settings to Settings screen

### To implement Edit Medication:
1. Create edit screen (clone add medication flow)
2. Add edit button to medication cards on dashboard
3. Pre-populate form with existing data
4. Update medication on save
5. Add delete confirmation dialog

### To implement Schedule Screen:
1. Create schedule screen with calendar widget
2. Create ScheduleViewModel
3. Query medications for selected date range
4. Display in calendar/list view
5. Add date navigation controls

### To implement History Screen:
1. Create history screen with date filters
2. Create HistoryViewModel
3. Query medication logs from database
4. Display adherence statistics
5. Add charts (consider fl_chart package)
