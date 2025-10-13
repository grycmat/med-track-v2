# Drift Database Integration Plan for med_track_v2

## Overview

This plan outlines the implementation of local database persistence using the Drift library for the medication tracking app. 
The implementation maintains the existing clean architecture (Provider pattern, separation of concerns) while adding robust data persistence optimized for solo development.


---

## Architecture Approach

### Core Principles

- **Direct database access** - All database operations in AppDatabase class (no DAO abstraction layer)
- **Single unified service** - MedicationService handles all business logic including statistics
- **Inline converters** - Type converters defined within table files
- **Direct UI model mapping** - Service layer returns UI models directly

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

### Phase 1: Database Schema

**Step 1.1**: Create and implement `lib/database/tables/medications_table.dart`

**Step 1.2**: Create and implement `lib/database/tables/medication_times_table.dart`

**Step 1.3**: Create and implement `lib/database/tables/medication_logs_table.dart`

**Step 1.4**: Create and implement `lib/database/app_database.dart`


**Step 1.5**: Generate Drift code
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Phase 2: Service Layer

**Step 2.1**: Create and implement `lib/services/medication_service.dart`

---

### Phase 3: ViewModel Updates

**Step 3.1**: Update `lib/viewmodels/add_medication_viewmodel.dart`


**Step 3.2**: Create and implement `lib/viewmodels/dashboard_viewmodel.dart`

### Phase 4: UI Integration

**Step 4.1**: Update `lib/main.dart`

**Step 4.2**: Update `lib/screens/dashboard.screen.dart`

**Step 4.3**: Update `lib/screens/add_medication/medication_review.view.dart`

Replace button handler (line ~132):

**Step 4.4**: Update AddMedicationScreen navigation

### Phase 5: Testing

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
