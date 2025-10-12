# Drift Database Integration Plan for med_track_v2

## Overview

This plan outlines the implementation of local database persistence using the Drift library for the medication tracking app. The implementation maintains the existing clean architecture (Provider pattern, separation of concerns) while adding robust data persistence.

**Estimated Timeline:** 10-16 hours (2-3 work days)

## Key Architecture Decisions

### 1. Database Schema Design

#### Primary Tables

**medications table:**
```
- id (INTEGER, PRIMARY KEY, AUTOINCREMENT)
- name (TEXT, NOT NULL)
- dosage_amount (TEXT, NOT NULL) - e.g., "500"
- dosage_unit (TEXT, NOT NULL) - e.g., "mg", "ml", "tablets"
- frequency (TEXT, NOT NULL) - serialized enum: "daily", "weekly", "specificDays"
- selected_days (TEXT, NULLABLE) - JSON array: ["monday", "wednesday", "friday"]
- created_at (DATETIME, NOT NULL)
- updated_at (DATETIME, NOT NULL)
- is_active (BOOLEAN, NOT NULL, DEFAULT true) - for soft deletion
```

**medication_times table:**
```
- id (INTEGER, PRIMARY KEY, AUTOINCREMENT)
- medication_id (INTEGER, NOT NULL, FOREIGN KEY)
- hour (INTEGER, NOT NULL) - 0-23
- minute (INTEGER, NOT NULL) - 0-59
- created_at (DATETIME, NOT NULL)
```

**medication_logs table:** (for tracking taken/missed status)
```
- id (INTEGER, PRIMARY KEY, AUTOINCREMENT)
- medication_id (INTEGER, NOT NULL, FOREIGN KEY)
- scheduled_date (DATE, NOT NULL) - date when medication should be taken
- scheduled_time (TIME, NOT NULL) - time when medication should be taken
- status (TEXT, NOT NULL) - "taken", "missed", "skipped"
- taken_at (DATETIME, NULLABLE) - actual time when marked as taken
- created_at (DATETIME, NOT NULL)
- updated_at (DATETIME, NOT NULL)
```

#### Rationale for Schema Design:
- **Separate times table**: Medications can have multiple reminder times (one-to-many relationship)
- **JSON for selected_days**: Simple serialization for the Set<Day>, easy to query and deserialize
- **medication_logs**: Separates static medication data from daily tracking, enables history and statistics
- **Timestamps**: Track creation/updates for audit and sync purposes
- **is_active**: Soft deletion allows keeping history without showing inactive medications

### 2. Architecture & File Structure

#### New Files to Create (18 files):

**Database Layer** (`lib/database/`):
```
lib/database/
├── app_database.dart              # Main database definition with @DriftDatabase annotation
├── tables/
│   ├── medications_table.dart     # Medications table definition
│   ├── medication_times_table.dart # Times table definition
│   └── medication_logs_table.dart  # Logs table definition
├── daos/
│   ├── medications_dao.dart       # CRUD operations for medications + times
│   └── medication_logs_dao.dart   # CRUD operations for logs
└── converters/
    ├── frequency_converter.dart   # TypeConverter for Frequency enum
    └── day_list_converter.dart    # TypeConverter for List<Day> (from JSON)
```

**Services Layer** (`lib/services/`):
```
lib/services/
├── medication_service.dart        # Business logic layer between viewmodels and database
└── statistics_service.dart        # Calculates adherence %, streaks from logs
```

**Updated Models** (`lib/models/`):
```
lib/models/
├── medication.dart                # Keep existing, add factory constructors for Drift entities
├── medication_with_times.dart     # NEW: Composite model (medication + times)
└── medication_log.dart            # NEW: Model for log entries
```

#### Files to Modify:

**ViewModels**:
- `lib/viewmodels/add_medication_viewmodel.dart` - Add save method that calls service
- NEW `lib/viewmodels/dashboard_viewmodel.dart` - Replace dummy data with service calls

**Screens**:
- `lib/screens/dashboard.screen.dart` - Refactor to use DashboardViewModel with Provider
- `lib/screens/add_medication/medication_review.view.dart` - Call viewmodel save method (line 132)

**Main**:
- `lib/main.dart` - Initialize database, provide services and database instance

**Dependencies**:
- `pubspec.yaml` - Add drift dependencies

### 3. Data Flow Architecture

#### Adding a Medication (Complete Flow):

```
User clicks "Add Medication" in MedicationReviewView
    ↓
1. MedicationReviewView calls: viewModel.saveMedication(context)
    ↓
2. AddMedicationViewModel:
   - Validates all fields
   - Calls: medicationService.addMedication(...)
   - Shows loading state
    ↓
3. MedicationService.addMedication():
   - Creates MedicationsCompanion (Drift insert object)
   - Calls: medicationsDao.insertMedicationWithTimes(...)
   - Handles errors with try-catch
   - Returns created Medication ID
    ↓
4. MedicationsDao.insertMedicationWithTimes():
   - Starts database transaction
   - Inserts into medications table (returns ID)
   - Inserts multiple rows into medication_times table
   - Commits transaction
   - Returns medication ID
    ↓
5. AddMedicationViewModel:
   - Receives success/failure
   - If success: Navigator.pop() + optional SnackBar
   - If failure: Shows error dialog
    ↓
6. Dashboard automatically updates (Provider/ChangeNotifier)
```

#### Loading Dashboard Data:

```
DashboardScreen builds
    ↓
1. Provider<DashboardViewModel> initialized (in main.dart)
    ↓
2. DashboardViewModel constructor:
   - Calls: _loadMedications() in initState
    ↓
3. DashboardViewModel._loadMedications():
   - Sets loading state
   - Calls: medicationService.getAllActiveMedications()
   - Calls: statisticsService.getStatistics()
   - notifyListeners()
    ↓
4. MedicationService.getAllActiveMedications():
   - Calls: medicationsDao.watchAllActiveMedicationsWithTimes()
   - Returns Stream<List<MedicationWithTimes>>
    ↓
5. DashboardViewModel:
   - Listens to stream
   - Transforms Drift entities to UI models
   - Calculates status (takeNow, upcoming, taken, missed) from logs
   - notifyListeners()
    ↓
6. DashboardScreen rebuilds with real data
```

#### Marking Medication as Taken:

```
User taps "Take" button on MedicationCard
    ↓
1. DashboardScreen calls: viewModel.markAsTaken(medicationId, scheduledTime)
    ↓
2. DashboardViewModel:
   - Calls: medicationService.markAsTaken(...)
   - Optimistically updates local state
   - notifyListeners()
    ↓
3. MedicationService.markAsTaken():
   - Calls: medicationLogsDao.insertLog(...)
   - Creates log entry with status="taken", taken_at=now
    ↓
4. Stream updates automatically via Drift's watchAllActiveMedications()
    ↓
5. UI reflects change immediately
```

### 4. Model Adjustments

#### Strategy: Hybrid Approach

**Keep existing models** for UI layer (clean, simple, no Drift dependencies):
- `Medication` - UI model (current structure)
- `MedicationData` - UI model with computed fields
- `MedicationStatus`, `Frequency`, `Day` enums - unchanged

**Create new models** for service/database layer:
- `MedicationWithTimes` - Combines medication + list of times
- `MedicationLog` - Represents log entry

**Drift-generated classes** stay in database layer:
- `MedicationEntity` (from Medications table)
- `MedicationTimeEntity` (from MedicationTimes table)
- `MedicationLogEntity` (from MedicationLogs table)

#### Mapping Strategy:

**Service layer acts as mapper**:
```
Database Layer (Drift entities)
    ↕ MedicationService maps between
UI Layer (Existing models)
```

**Example mappings**:

1. **AddMedicationViewModel → Database:**
   - ViewModel holds: String name, String dosageAmount, String dosageUnit, Frequency frequency, Set<Day> selectedDays, List<TimeOfDay> times
   - Service creates: MedicationsCompanion + List<MedicationTimesCompanion>
   - Converters serialize: Frequency enum → String, Set<Day> → JSON array

2. **Database → DashboardScreen:**
   - DAO returns: MedicationEntity + List<MedicationTimeEntity> + List<MedicationLogEntity>
   - Service creates: MedicationWithTimes (intermediate model)
   - Service transforms to: List<MedicationData> with computed status and dueInfo
   - ViewModel exposes: List<MedicationData> for UI

#### Why This Approach:
- **Clean separation**: UI models stay simple, no Drift dependencies
- **Flexibility**: Can change database without touching UI
- **Type safety**: Drift generates type-safe queries
- **Testability**: Can mock services easily
- **Existing code**: Minimal changes to existing widgets/screens

## Implementation Steps (Ordered)

### Phase 1: Setup & Dependencies (30 minutes)

**Step 1.1**: Update `pubspec.yaml` - DONE
```yaml
dependencies:
  drift: ^2.14.0
  drift_flutter: ^0.1.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.8.0

dev_dependencies:
  drift_dev: ^2.14.0
  build_runner: ^2.4.0
```

**Step 1.2**: Run dependency installation - DONE
```bash
flutter pub get
```

### Phase 2: Database Schema Definition (1-2 hours)

**Step 2.1**: Create converters
- `lib/database/converters/frequency_converter.dart`
  - Extends `TypeConverter<Frequency, String>`
  - Maps enum to/from string values

- `lib/database/converters/day_list_converter.dart`
  - Extends `TypeConverter<List<Day>, String>`
  - Uses `jsonEncode`/`jsonDecode` to serialize Set<Day> as JSON array

**Step 2.2**: Create table definitions
- `lib/database/tables/medications_table.dart`
  - Define `Medications` class extending `Table`
  - Use `@UseRowClass(MedicationEntity)` annotation
  - Apply `@TypeConverterAnnotation` for frequency and days

- `lib/database/tables/medication_times_table.dart`
  - Define `MedicationTimes` class extending `Table`
  - Foreign key: `integer().references(Medications, #id).named('medication_id')()`

- `lib/database/tables/medication_logs_table.dart`
  - Define `MedicationLogs` class extending `Table`
  - Foreign key to Medications table
  - Use `datetime()` for timestamps

**Step 2.3**: Create main database file
- `lib/database/app_database.dart`
  - Annotate with `@DriftDatabase(tables: [Medications, MedicationTimes, MedicationLogs])`
  - Extend `_$AppDatabase`
  - Implement `schemaVersion` (start at 1)
  - Implement `migration` strategy (MigrationStrategy)
  - Add `oncreate` callback for initial setup

**Step 2.4**: Generate Drift code
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Phase 3: Data Access Layer (2-3 hours)

**Step 3.1**: Create `lib/database/daos/medications_dao.dart`
- Annotate with `@DriftAccessor(tables: [Medications, MedicationTimes])`
- Methods to implement:
  - `Future<int> insertMedicationWithTimes(...)` - transaction
  - `Stream<List<MedicationWithTimesData>> watchAllActiveMedications()`
  - `Future<MedicationWithTimesData?> getMedicationById(int id)`
  - `Future<bool> updateMedication(...)`
  - `Future<int> deleteMedication(int id)` - soft delete (set is_active=false)
  - `Future<void> insertMedicationTime(...)` - for individual times
  - `Future<void> deleteMedicationTimes(int medicationId)` - for updates

**Step 3.2**: Create `lib/database/daos/medication_logs_dao.dart`
- Annotate with `@DriftAccessor(tables: [MedicationLogs])`
- Methods to implement:
  - `Future<int> insertLog(...)`
  - `Future<MedicationLogEntity?> getLogForMedicationAndTime(int medicationId, DateTime scheduledDate, TimeOfDay scheduledTime)`
  - `Stream<List<MedicationLogEntity>> watchLogsForDate(DateTime date)`
  - `Future<List<MedicationLogEntity>> getLogsInDateRange(DateTime start, DateTime end)`
  - `Future<int> updateLogStatus(...)`

**Step 3.3**: Add DAOs to `app_database.dart`
- Add getters for each DAO
- Annotate `@DriftDatabase(tables: [...], daos: [MedicationsDao, MedicationLogsDao])`
- Regenerate: `dart run build_runner build`

### Phase 4: Service Layer (2-3 hours)

**Step 4.1**: Create `lib/models/medication_with_times.dart`
- Simple data class holding:
  - Medication entity data
  - List<TimeOfDay> times
  - Factory constructor from Drift entities
  - Method to convert to UI `MedicationData` model

**Step 4.2**: Create `lib/models/medication_log.dart`
- Simple data class for log entries
- Factory constructor from Drift entity
- Methods for serialization if needed

**Step 4.3**: Create `lib/services/medication_service.dart`
- Constructor receives `AppDatabase` instance
- Methods to implement:
  - `Future<int> addMedication(String name, String dosageAmount, String dosageUnit, Frequency frequency, Set<Day> selectedDays, List<TimeOfDay> times)`
    - Validates inputs
    - Calls DAO methods
    - Returns medication ID
  - `Stream<List<MedicationWithTimes>> watchAllActiveMedications()`
    - Returns stream from DAO
    - Maps to intermediate model
  - `Future<List<MedicationData>> getMedicationsForToday()`
    - Gets medications from DAO
    - Gets logs for today
    - Computes status for each medication
    - Returns list of MedicationData
  - `Future<void> markAsTaken(int medicationId, DateTime scheduledDate, TimeOfDay scheduledTime)`
    - Creates log entry with status="taken"
  - `Future<void> markAsMissed(int medicationId, DateTime scheduledDate, TimeOfDay scheduledTime)`
    - Creates log entry with status="missed"
  - Error handling with try-catch throughout

**Step 4.4**: Create `lib/services/statistics_service.dart`
- Constructor receives `AppDatabase` instance
- Methods to implement:
  - `Future<double> calculateWeeklyAdherence()`
    - Queries logs for last 7 days
    - Calculates (taken / (taken + missed)) * 100
  - `Future<int> getCurrentStreak()`
    - Queries logs to find consecutive days with 100% adherence
  - `Future<List<StatItem>> getDashboardStats()`
    - Calls above methods
    - Returns list of StatItem models for UI

### Phase 5: ViewModel Updates (1-2 hours)

**Step 5.1**: Update `lib/viewmodels/add_medication_viewmodel.dart`
- Add `MedicationService` as constructor parameter
- Add method: `Future<bool> saveMedication()`
  - Validates all fields
  - Calls `medicationService.addMedication(...)`
  - Handles errors
  - Returns success/failure
- Add loading state: `bool _isSaving = false`
- Add error state: `String? _errorMessage`

**Step 5.2**: Create `lib/viewmodels/dashboard_viewmodel.dart`
- Extends `ChangeNotifier`
- Constructor receives `MedicationService` and `StatisticsService`
- State properties:
  - `List<MedicationData> _medications = []`
  - `List<StatItem> _stats = []`
  - `bool _isLoading = true`
  - `String? _errorMessage`
- Methods:
  - `Future<void> loadData()` - calls services, updates state
  - `Future<void> markAsTaken(int medicationId, DateTime scheduledDate, TimeOfDay scheduledTime)`
  - `Future<void> markAsMissed(...)`
  - `Future<void> refresh()` - pull-to-refresh
- Computed properties:
  - `MedicationData? get nextDose` - filters upcoming medications
  - `List<MedicationData> get todaysSchedule` - all for today
- Initialize in constructor with `loadData()`

### Phase 6: Screen Updates (1-2 hours)

**Step 6.1**: Update `lib/screens/add_medication/medication_review.view.dart`
- Modify "Add Medication" button onPressed (line 132):
  ```dart
  // OLD: Navigator.of(context).pop();

  // NEW:
  final success = await viewModel.saveMedication();
  if (success && context.mounted) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Medication added successfully')),
    );
  } else if (!success && context.mounted) {
    // Show error dialog
  }
  ```
- Add loading overlay while saving
- Handle viewModel error states

**Step 6.2**: Refactor `lib/screens/dashboard.screen.dart`
- Remove dummy data
- Wrap with `ChangeNotifierProvider<DashboardViewModel>`
- Replace setState with `context.watch<DashboardViewModel>()`
- Update all data references to use viewModel getters
- Update "Take" button to call `viewModel.markAsTaken(...)`
- Add pull-to-refresh: `RefreshIndicator(onRefresh: viewModel.refresh)`
- Add loading state handling
- Add error state handling with retry button
- Add empty state (when no medications)

### Phase 7: App Initialization (30 minutes)

**Step 7.1**: Update `lib/main.dart`
- Add database initialization in main():
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize database
    final database = AppDatabase();

    // Initialize services
    final medicationService = MedicationService(database);
    final statisticsService = StatisticsService(database);

    runApp(MedTrackV2App(
      medicationService: medicationService,
      statisticsService: statisticsService,
      database: database,
    ));
  }
  ```

**Step 7.2**: Update `MedTrackV2App` widget
- Add constructor parameters for services
- Wrap MaterialApp with `MultiProvider`:
  ```dart
  MultiProvider(
    providers: [
      Provider<AppDatabase>.value(value: database),
      Provider<MedicationService>.value(value: medicationService),
      Provider<StatisticsService>.value(value: statisticsService),
      ChangeNotifierProvider(
        create: (context) => DashboardViewModel(
          medicationService: context.read<MedicationService>(),
          statisticsService: context.read<StatisticsService>(),
        ),
      ),
    ],
    child: MaterialApp(...),
  )
  ```

**Step 7.3**: Update AddMedicationScreen provider setup
- Inject `MedicationService` into `AddMedicationViewModel`
- Update ChangeNotifierProvider in navigation

### Phase 8: Testing & Refinement (2-3 hours)

**Step 8.1**: Manual testing checklist
- [ ] Add medication with daily frequency
- [ ] Add medication with specific days
- [ ] Add medication with multiple times
- [ ] Mark medication as taken
- [ ] Verify dashboard updates immediately
- [ ] Verify statistics calculate correctly
- [ ] Test app restart (data persists)
- [ ] Test empty state (no medications)
- [ ] Test error handling (invalid inputs)
- [ ] Test theme switching with real data

**Step 8.2**: Database inspection
- Use Drift's debug tools or SQLite browser
- Verify data structure matches schema
- Check foreign key relationships
- Verify timestamps are correct

**Step 8.3**: Performance validation
- Ensure no frame drops on dashboard
- Check if streams update efficiently
- Profile database queries (should be <16ms)

**Step 8.4**: Clean up
- Remove dummy data files (or comment out)
- Remove unused imports
- Run `flutter analyze`
- Fix any linting issues

## Key Considerations & Best Practices

### Migration from Dummy Data

**Approach 1: Clean Start** (Recommended for prototype)
- Simply remove dummy data references
- Fresh database on first run
- Let users add medications manually

**Approach 2: Seed Initial Data**
- Create migration helper in `app_database.dart`
- On first run (schemaVersion check), insert dummy medications
- Useful for testing and demos

### Error Handling Strategy

**Database Layer (DAOs):**
- Let Drift exceptions propagate up
- Log errors for debugging

**Service Layer:**
- Wrap all DAO calls in try-catch
- Convert exceptions to user-friendly messages
- Return `Result<T>` type or use nullable returns with error properties

**ViewModel Layer:**
- Catch service errors
- Set error state properties
- Expose errors to UI via getters

**UI Layer:**
- Show SnackBars for temporary errors
- Show dialogs for critical errors with retry
- Show error widgets for loading failures

### State Management Patterns

**For Dashboard:**
- Use `StreamProvider` + `DashboardViewModel` hybrid
- Stream updates from database automatically refresh UI
- ViewModel handles actions (markAsTaken, refresh)

**For Add Medication:**
- Keep `ChangeNotifierProvider` pattern
- Single-shot operations (add medication)
- Dispose properly to prevent memory leaks

### Performance Optimizations

**Database:**
- Add indexes on frequently queried columns (medication_id in logs, scheduled_date)
- Use `EXPLAIN QUERY PLAN` to optimize slow queries
- Consider pagination for history screen (future)

**UI:**
- Use `const` constructors everywhere possible
- Implement `shouldRebuild` in Provider selectors
- Use `ListView.builder` for medication lists
- Cache computed properties in viewmodels

**Streams:**
- Use single stream subscription in viewmodels
- Dispose streams properly in dispose()
- Consider debouncing rapid updates

### Testing Strategy (Future)

**Unit Tests:**
- Test converters (Frequency, Day serialization)
- Test service logic (statistics calculations)
- Test ViewModel methods

**Integration Tests:**
- Test DAO methods with in-memory database
- Test complete flows (add → retrieve → update)

**Widget Tests:**
- Test dashboard with mock services
- Test add medication flow with mock viewmodel

### Database Maintenance

**Schema Versioning:**
- Increment `schemaVersion` for any schema changes
- Implement `onUpgrade` in MigrationStrategy
- Document migrations in comments

**Backup & Export:**
- Future feature: Export database to JSON
- Use Drift's `Export` functionality
- Store backups in app documents directory

### Code Organization Best Practices

**Naming Conventions:**
- Drift entities: `MedicationEntity`, `MedicationTimeEntity`
- UI models: `Medication`, `MedicationData`
- Intermediate models: `MedicationWithTimes`
- Services: `MedicationService` (noun), methods are verbs
- DAOs: `MedicationsDao` (plural)

**Import Organization:**
- Drift imports in database files only
- Services import database types but not Drift
- ViewModels import services only
- UI imports models and viewmodels only

**File Size Guidelines:**
- Keep DAOs under 300 lines (split if needed)
- Keep services under 400 lines
- Extract complex queries to private methods

## Potential Challenges & Solutions

### Challenge 1: Status Calculation Complexity
**Problem**: Determining if medication is "takeNow", "upcoming", "taken", or "missed" requires joining medications, times, and logs.

**Solution**:
- Create helper method in `MedicationService`: `_calculateStatus(medication, time, logs)`
- Cache today's logs in memory (refresh on date change)
- Use simple time comparison logic
- Consider "take window" (e.g., 30 minutes before/after scheduled time)

### Challenge 2: Multiple Times Per Day
**Problem**: One medication can have 3+ times, each with different status.

**Solution**:
- Service returns separate `MedicationData` for each time
- UI groups by medication name if needed
- Status is per-time, not per-medication
- Dashboard shows "next dose" as earliest upcoming time

### Challenge 3: Weekly Frequency Handling
**Problem**: Weekly medications (e.g., "every Monday") need special scheduling logic.

**Solution**:
- Service checks current day against `selectedDays` set
- Only show medication if today is in selectedDays
- Logs still track by date (not day-of-week)
- Statistics account for different frequencies

### Challenge 4: Timezone Issues
**Problem**: DateTime serialization can lose timezone information.

**Solution**:
- Store all times in UTC
- Convert to local time in UI layer
- Use DateTime.now().toUtc() for timestamps
- TimeOfDay is timezone-agnostic (just hour/minute)

### Challenge 5: Database Migration After Release
**Problem**: Adding new features requires schema changes without losing user data.

**Solution**:
- Always increment schemaVersion
- Test migrations thoroughly
- Implement `onUpgrade` callback in MigrationStrategy
- Keep migrations code even after deployed
- Document migration steps in comments

## Success Metrics

After implementation is complete, verify:

- [ ] **Functionality**: Add medication → restart app → medication still there
- [ ] **Performance**: Dashboard loads in <500ms with 20+ medications
- [ ] **UI Responsiveness**: No frame drops when marking medications as taken
- [ ] **Data Integrity**: Foreign keys enforced, no orphaned records
- [ ] **Error Handling**: Graceful handling of all failure scenarios
- [ ] **Code Quality**: Flutter analyze passes with no errors
- [ ] **Architecture**: Clean separation between database, services, viewmodels, UI
- [ ] **State Management**: Provider pattern maintained, no setState in business logic
- [ ] **Testability**: Services can be mocked easily for testing

## Estimated Timeline

- **Phase 1** (Setup): 30 minutes
- **Phase 2** (Schema): 1-2 hours
- **Phase 3** (DAOs): 2-3 hours
- **Phase 4** (Services): 2-3 hours
- **Phase 5** (ViewModels): 1-2 hours
- **Phase 6** (Screens): 1-2 hours
- **Phase 7** (Initialization): 30 minutes
- **Phase 8** (Testing): 2-3 hours

**Total: 10-16 hours** (approximately 2-3 work days)

## Next Steps After Implementation

Once Drift integration is complete:

1. **Add Edit Functionality**: Update medication details
2. **Add Delete with Confirmation**: Soft delete with undo option
3. **Implement History Screen**: Show logs with filtering
4. **Add Statistics Dashboard**: Charts for adherence over time
5. **Implement Local Notifications**: Remind users at scheduled times
6. **Add Backup/Restore**: Export/import database as JSON
7. **Implement Search/Filter**: Find medications quickly
8. **Add Medication Photos**: Store images using path in database
9. **Implement Recurring Schedules**: More complex frequency patterns
10. **Add Cloud Sync**: Optional backup to user's cloud storage

---

## Final Notes

This plan maintains the existing architecture while adding robust persistence. The key principles:

1. **Clean Architecture**: Database → Services → ViewModels → UI (one-way dependencies)
2. **Provider Pattern**: Maintained throughout
3. **Separation of Concerns**: Each layer has a single responsibility
4. **Type Safety**: Drift provides compile-time query validation
5. **Performance**: Streams enable reactive UI updates
6. **Testability**: Services can be mocked for unit tests
7. **Maintainability**: Clear file structure and naming conventions
8. **Scalability**: Ready for future features (notifications, cloud sync, etc.)

The implementation should proceed phase by phase, testing each phase before moving to the next. The database layer should be tested independently before connecting to the UI.
