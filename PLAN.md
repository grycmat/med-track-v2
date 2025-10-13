# Drift Database Integration Plan for med_track_v2

## Overview

This plan outlines the implementation of local database persistence using the Drift library for the medication tracking app. The implementation maintains the existing clean architecture (Provider pattern, separation of concerns) while adding robust data persistence optimized for solo development.


---

## Architecture Approach

### Core Principles

- **Direct database access** - All database operations in AppDatabase class (no DAO abstraction layer)
- **Single unified service** - MedicationService handles all business logic including statistics
- **Inline converters** - Type converters defined within table files
- **Direct UI model mapping** - Service layer returns UI models directly
- **Minimal file count** - 8 new files total

### Data Flow

```
UI (Screens/Widgets)
    ↕
ViewModels (ChangeNotifier)
    ↕
MedicationService (Business Logic)
    ↕
AppDatabase (Direct Drift Queries)
```

---

## Database Schema Design

### medications table
```sql
- id (INTEGER, PRIMARY KEY, AUTOINCREMENT)
- name (TEXT, NOT NULL)
- dosage_amount (TEXT, NOT NULL)
- dosage_unit (TEXT, NOT NULL)
- frequency (TEXT, NOT NULL) - enum: "daily", "weekly", "specificDays"
- selected_days (TEXT, NULLABLE) - JSON array of Day enum values
- created_at (DATETIME, NOT NULL)
- is_active (BOOLEAN, NOT NULL, DEFAULT true)
```

### medication_times table
```sql
- id (INTEGER, PRIMARY KEY, AUTOINCREMENT)
- medication_id (INTEGER, NOT NULL, FOREIGN KEY → medications.id)
- hour (INTEGER, NOT NULL) - 0-23
- minute (INTEGER, NOT NULL) - 0-59
```

### medication_logs table
```sql
- id (INTEGER, PRIMARY KEY, AUTOINCREMENT)
- medication_id (INTEGER, NOT NULL, FOREIGN KEY → medications.id)
- medication_time_id (INTEGER, NOT NULL, FOREIGN KEY → medication_times.id)
- log_date (DATE, NOT NULL)
- status (TEXT, NOT NULL) - "taken", "missed", "skipped"
- taken_at (DATETIME, NULLABLE)
```

### Schema Rationale

- **Separate times table**: One-to-many relationship for medications with multiple daily times
- **medication_time_id in logs**: Direct reference to specific time slots (no hour/minute matching needed)
- **JSON for selected_days**: Simple serialization for Set<Day>
- **Soft deletion via is_active**: Preserve history while hiding inactive medications
- **Minimal timestamps**: Only created_at for medications, only taken_at for logs

---

## File Structure

### New Files to Create

**Database Layer** (`lib/database/`):
```
lib/database/
├── app_database.dart              # Main database with all CRUD operations
└── tables/
    ├── medications_table.dart     # Medications table with inline converters
    ├── medication_times_table.dart
    └── medication_logs_table.dart
```

**Services Layer** (`lib/services/`):
```
lib/services/
└── medication_service.dart        # Unified service (medications + statistics)
```

### Files to Modify

**ViewModels**:
- `lib/viewmodels/add_medication_viewmodel.dart` - Add save method and loading state
- NEW `lib/viewmodels/dashboard_viewmodel.dart` - Replace dummy data with real data

**Screens**:
- `lib/screens/dashboard.screen.dart` - Use DashboardViewModel
- `lib/screens/add_medication/medication_review.view.dart` - Call save method

**Main**:
- `lib/main.dart` - Initialize database and services

---

## Implementation Steps

### Phase 1: Database Schema (1.5 hours)

**Step 1.1**: Create `lib/database/tables/medications_table.dart`

```dart
import 'package:drift/drift.dart';
import 'package:med_track_v2/models/medication.dart';
import 'dart:convert';

// Inline converters
class FrequencyConverter extends TypeConverter<Frequency, String> {
  const FrequencyConverter();

  @override
  Frequency fromSql(String fromDb) {
    return Frequency.values.firstWhere((e) => e.name == fromDb);
  }

  @override
  String toSql(Frequency value) {
    return value.name;
  }
}

class DayListConverter extends TypeConverter<List<Day>, String> {
  const DayListConverter();

  @override
  List<Day> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(fromDb);
    return decoded.map((e) => Day.values.firstWhere((d) => d.name == e)).toList();
  }

  @override
  String toSql(List<Day> value) {
    return jsonEncode(value.map((e) => e.name).toList());
  }
}

@DataClassName('MedicationEntity')
class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get dosageAmount => text()();
  TextColumn get dosageUnit => text()();
  TextColumn get frequency => text().map(const FrequencyConverter())();
  TextColumn get selectedDays => text().map(const DayListConverter()).nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
```

**Step 1.2**: Create `lib/database/tables/medication_times_table.dart`

```dart
import 'package:drift/drift.dart';
import 'medications_table.dart';

@DataClassName('MedicationTimeEntity')
class MedicationTimes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id, onDelete: KeyAction.cascade)();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
}
```

**Step 1.3**: Create `lib/database/tables/medication_logs_table.dart`

```dart
import 'package:drift/drift.dart';
import 'medications_table.dart';
import 'medication_times_table.dart';

@DataClassName('MedicationLogEntity')
class MedicationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id, onDelete: KeyAction.cascade)();
  IntColumn get medicationTimeId => integer().references(MedicationTimes, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get status => text()();
  DateTimeColumn get takenAt => dateTime().nullable()();
}
```

**Step 1.4**: Create `lib/database/app_database.dart`

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import 'tables/medications_table.dart';
import 'tables/medication_times_table.dart';
import 'tables/medication_logs_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Medications, MedicationTimes, MedicationLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'med_track_db');
  }

  // ===== MEDICATION CRUD =====

  Future<int> insertMedicationWithTimes({
    required String name,
    required String dosageAmount,
    required String dosageUnit,
    required Frequency frequency,
    List<Day>? selectedDays,
    required List<TimeOfDay> times,
  }) async {
    return await transaction(() async {
      final medicationId = await into(medications).insert(
        MedicationsCompanion.insert(
          name: name,
          dosageAmount: dosageAmount,
          dosageUnit: dosageUnit,
          frequency: frequency,
          selectedDays: Value(selectedDays ?? []),
          createdAt: DateTime.now(),
        ),
      );

      for (final time in times) {
        await into(medicationTimes).insert(
          MedicationTimesCompanion.insert(
            medicationId: medicationId,
            hour: time.hour,
            minute: time.minute,
          ),
        );
      }

      return medicationId;
    });
  }

  Stream<List<MedicationEntity>> watchAllActiveMedications() {
    return (select(medications)..where((m) => m.isActive.equals(true))).watch();
  }

  Future<List<MedicationTimeEntity>> getTimesForMedication(int medicationId) {
    return (select(medicationTimes)..where((t) => t.medicationId.equals(medicationId))).get();
  }

  Future<void> softDeleteMedication(int medicationId) async {
    await (update(medications)..where((m) => m.id.equals(medicationId)))
        .write(const MedicationsCompanion(isActive: Value(false)));
  }

  // ===== LOG OPERATIONS =====

  Future<int> insertLog({
    required int medicationId,
    required int medicationTimeId,
    required DateTime logDate,
    required String status,
    DateTime? takenAt,
  }) async {
    return await into(medicationLogs).insert(
      MedicationLogsCompanion.insert(
        medicationId: medicationId,
        medicationTimeId: medicationTimeId,
        logDate: logDate,
        status: status,
        takenAt: Value(takenAt),
      ),
    );
  }

  Future<MedicationLogEntity?> getLogForTimeAndDate(int medicationTimeId, DateTime date) async {
    final query = select(medicationLogs)
      ..where((l) => l.medicationTimeId.equals(medicationTimeId) & l.logDate.equals(date));
    return await query.getSingleOrNull();
  }

  Future<List<MedicationLogEntity>> getLogsInDateRange(DateTime start, DateTime end) {
    final query = select(medicationLogs)
      ..where((l) => l.logDate.isBiggerOrEqualValue(start) & l.logDate.isSmallerOrEqualValue(end));
    return query.get();
  }

  Stream<List<MedicationLogEntity>> watchLogsForDate(DateTime date) {
    return (select(medicationLogs)..where((l) => l.logDate.equals(date))).watch();
  }
}
```

**Step 1.5**: Generate Drift code

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### Phase 2: Service Layer (1.5 hours)

**Step 2.1**: Create `lib/services/medication_service.dart`

```dart
import 'package:flutter/material.dart';
import 'package:med_track_v2/database/app_database.dart';
import 'package:med_track_v2/models/medication.dart';

class MedicationService {
  final AppDatabase _db;

  MedicationService(this._db);

  // ===== ADD MEDICATION =====

  Future<int> addMedication({
    required String name,
    required String dosageAmount,
    required String dosageUnit,
    required Frequency frequency,
    List<Day>? selectedDays,
    required List<TimeOfDay> times,
  }) async {
    try {
      return await _db.insertMedicationWithTimes(
        name: name,
        dosageAmount: dosageAmount,
        dosageUnit: dosageUnit,
        frequency: frequency,
        selectedDays: selectedDays,
        times: times,
      );
    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }

  // ===== WATCH MEDICATIONS =====

  Stream<List<MedicationData>> watchTodaysMedications() async* {
    await for (final medications in _db.watchAllActiveMedications()) {
      final List<MedicationData> medicationDataList = [];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      for (final med in medications) {
        if (!_shouldShowToday(med, now)) continue;

        final times = await _db.getTimesForMedication(med.id);

        for (final time in times) {
          final log = await _db.getLogForTimeAndDate(time.id, today);
          final status = _calculateStatus(time, log, now);

          medicationDataList.add(
            MedicationData(
              medication: Medication(
                id: med.id.toString(),
                name: med.name,
                dosage: '${med.dosageAmount} ${med.dosageUnit}',
                time: TimeOfDay(hour: time.hour, minute: time.minute),
                status: status,
              ),
              dueInfo: _getDueInfo(time, now),
            ),
          );
        }
      }

      medicationDataList.sort((a, b) {
        final aMinutes = a.medication.time.hour * 60 + a.medication.time.minute;
        final bMinutes = b.medication.time.hour * 60 + b.medication.time.minute;
        return aMinutes.compareTo(bMinutes);
      });

      yield medicationDataList;
    }
  }

  // ===== MARK AS TAKEN/MISSED =====

  Future<void> markAsTaken(int medicationId, int medicationTimeId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _db.insertLog(
      medicationId: medicationId,
      medicationTimeId: medicationTimeId,
      logDate: today,
      status: 'taken',
      takenAt: now,
    );
  }

  Future<void> markAsMissed(int medicationId, int medicationTimeId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _db.insertLog(
      medicationId: medicationId,
      medicationTimeId: medicationTimeId,
      logDate: today,
      status: 'missed',
      takenAt: null,
    );
  }

  // ===== STATISTICS =====

  Future<double> calculateWeeklyAdherence() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final logs = await _db.getLogsInDateRange(weekAgo, now);

    if (logs.isEmpty) return 0.0;

    final taken = logs.where((l) => l.status == 'taken').length;
    final total = logs.length;

    return (taken / total) * 100;
  }

  Future<int> getCurrentStreak() async {
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final checkDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final nextDate = checkDate.add(const Duration(days: 1));

      final logs = await _db.getLogsInDateRange(checkDate, nextDate);

      if (logs.isEmpty) break;

      final taken = logs.where((l) => l.status == 'taken').length;
      if (taken == logs.length) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<List<StatItem>> getDashboardStats() async {
    final adherence = await calculateWeeklyAdherence();
    final streak = await getCurrentStreak();

    return [
      StatItem(
        icon: Icons.show_chart,
        value: '${adherence.toStringAsFixed(0)}%',
        label: 'Weekly Adherence',
        color: Colors.blue,
        animationDelay: 0.0,
      ),
      StatItem(
        icon: Icons.local_fire_department,
        value: '$streak',
        label: 'Day Streak',
        color: Colors.orange,
        animationDelay: 0.1,
      ),
    ];
  }

  // ===== PRIVATE HELPERS =====

  bool _shouldShowToday(MedicationEntity med, DateTime now) {
    switch (med.frequency) {
      case Frequency.daily:
        return true;
      case Frequency.specificDays:
        final today = Day.values[now.weekday - 1];
        return med.selectedDays?.contains(today) ?? false;
      case Frequency.weekly:
        return true;
    }
  }

  MedicationStatus _calculateStatus(MedicationTimeEntity time, MedicationLogEntity? log, DateTime now) {
    if (log != null) {
      return log.status == 'taken' ? MedicationStatus.taken : MedicationStatus.missed;
    }

    final scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final difference = scheduledTime.difference(now).inMinutes;

    if (difference <= 0 && difference >= -30) {
      return MedicationStatus.takeNow;
    } else if (difference > 0) {
      return MedicationStatus.upcoming;
    } else {
      return MedicationStatus.missed;
    }
  }

  String _getDueInfo(MedicationTimeEntity time, DateTime now) {
    final scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final difference = scheduledTime.difference(now);

    if (difference.inMinutes <= 0) return 'Now';
    if (difference.inHours < 1) return 'in ${difference.inMinutes}m';
    return 'in ${difference.inHours}h';
  }
}
```

---

### Phase 3: ViewModel Updates (1 hour)

**Step 3.1**: Update `lib/viewmodels/add_medication_viewmodel.dart`

Add to existing class:

```dart
final MedicationService _medicationService;

AddMedicationViewModel(this._medicationService);

bool _isSaving = false;
bool get isSaving => _isSaving;

Future<bool> saveMedication() async {
  if (_medicationName.isEmpty || _dosageAmount.isEmpty || _times.isEmpty) {
    return false;
  }

  _isSaving = true;
  notifyListeners();

  try {
    await _medicationService.addMedication(
      name: _medicationName,
      dosageAmount: _dosageAmount,
      dosageUnit: _dosageUnit,
      frequency: _frequency,
      selectedDays: _frequency == Frequency.specificDays ? _selectedDays.toList() : null,
      times: _times,
    );

    _isSaving = false;
    notifyListeners();
    return true;
  } catch (e) {
    _isSaving = false;
    notifyListeners();
    return false;
  }
}
```

**Step 3.2**: Create `lib/viewmodels/dashboard_viewmodel.dart`

```dart
import 'package:flutter/material.dart';
import 'package:med_track_v2/models/medication.dart';
import 'package:med_track_v2/services/medication_service.dart';
import 'dart:async';

class DashboardViewModel extends ChangeNotifier {
  final MedicationService _medicationService;

  List<MedicationData> _medications = [];
  List<StatItem> _stats = [];
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription? _medicationSubscription;

  DashboardViewModel(this._medicationService) {
    _init();
  }

  List<MedicationData> get medications => _medications;
  List<StatItem> get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MedicationData? get nextDose {
    final upcoming = _medications.where((m) => m.medication.status == MedicationStatus.upcoming).toList();
    return upcoming.isEmpty ? null : upcoming.first;
  }

  List<MedicationData> get todaysSchedule => _medications;

  Future<void> _init() async {
    _medicationSubscription = _medicationService.watchTodaysMedications().listen(
      (medications) {
        _medications = medications;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    await _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      _stats = await _medicationService.getDashboardStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsTaken(int medicationId, int medicationTimeId) async {
    try {
      await _medicationService.markAsTaken(medicationId, medicationTimeId);
      await _loadStats();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await _loadStats();
  }

  @override
  void dispose() {
    _medicationSubscription?.cancel();
    super.dispose();
  }
}
```

---

### Phase 4: UI Integration (1.5 hours)

**Step 4.1**: Update `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final medicationService = MedicationService(database);

  runApp(MedTrackV2App(
    medicationService: medicationService,
    database: database,
  ));
}

class MedTrackV2App extends StatefulWidget {
  final MedicationService medicationService;
  final AppDatabase database;

  const MedTrackV2App({
    super.key,
    required this.medicationService,
    required this.database,
  });

  @override
  State<MedTrackV2App> createState() => _MedTrackV2AppState();
}

class _MedTrackV2AppState extends State<MedTrackV2App> {
  // ... existing theme code ...

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: widget.database),
        Provider<MedicationService>.value(value: widget.medicationService),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(widget.medicationService),
        ),
      ],
      child: MaterialApp(
        // ... existing MaterialApp config ...
      ),
    );
  }
}
```

**Step 4.2**: Update `lib/screens/dashboard.screen.dart`

Replace dummy data with ViewModel:

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text('Error: ${viewModel.errorMessage}'));
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: CustomScrollView(
        // Use viewModel.medications, viewModel.stats, viewModel.nextDose
        // Update "Take" button to call viewModel.markAsTaken(medicationId, timeId)
      ),
    );
  }
}
```

**Step 4.3**: Update `lib/screens/add_medication/medication_review.view.dart`

Replace button handler (line ~132):

```dart
GradientButton(
  text: viewModel.isSaving ? 'Saving...' : 'Add Medication',
  onPressed: viewModel.isSaving ? null : () async {
    final success = await viewModel.saveMedication();
    if (success && context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication added successfully!')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add medication')),
      );
    }
  },
)
```

**Step 4.4**: Update AddMedicationScreen navigation

Wherever navigating to AddMedicationScreen:

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ChangeNotifierProvider(
      create: (context) => AddMedicationViewModel(
        context.read<MedicationService>(),
      ),
      child: const AddMedicationScreen(),
    ),
  ),
);
```

---

### Phase 5: Testing (1.5 hours)

**Manual Testing Checklist:**
- [ ] Add medication with daily frequency
- [ ] Add medication with specific days
- [ ] Add medication with multiple times
- [ ] Mark medication as taken
- [ ] Verify dashboard updates immediately
- [ ] Verify statistics calculate correctly
- [ ] Restart app - data persists
- [ ] Test empty state (no medications)
- [ ] Test theme switching with real data

**Database Inspection:**
- Use Drift Inspector or SQLite browser
- Verify foreign key relationships
- Check data integrity

**Code Quality:**
- Remove dummy data files
- Run `flutter analyze`
- Fix any linting issues

---

## Timeline Summary

- **Phase 1** (Schema): 1.5 hours
- **Phase 2** (Service): 1.5 hours
- **Phase 3** (ViewModels): 1 hour
- **Phase 4** (UI): 1.5 hours
- **Phase 5** (Testing): 1.5 hours

**Total: 5-7 hours**

---

## Success Criteria

- [ ] Add medication → restart app → medication persists
- [ ] Dashboard loads in <500ms
- [ ] No frame drops when marking medications
- [ ] Statistics calculate correctly
- [ ] Flutter analyze passes
- [ ] Clean architecture maintained (Database → Service → ViewModel → UI)

---

## Future Enhancements

1. Add edit/delete functionality
2. Implement history screen
3. Add local notifications
4. Implement data export
5. Add search/filter capabilities
6. Consider splitting service when it exceeds 500 lines
