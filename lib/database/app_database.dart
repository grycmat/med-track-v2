import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:med_track_v2/database/tables/medications_table.dart';
import 'package:med_track_v2/database/tables/medication_times_table.dart';
import 'package:med_track_v2/database/tables/medication_logs_table.dart';
import 'package:med_track_v2/database/tables/user_preferences_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Medications, MedicationTimes, MedicationLogs, UserPreferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(userPreferences);
        }
      },
    );
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'med_track.db'));
      return NativeDatabase(file);
    });
  }

  Future<List<Medication>> getAllActiveMedications() async {
    return (select(medications)
          ..where((tbl) => tbl.isActive.equals(true)))
        .get();
  }

  Future<Medication> getMedicationById(int id) async {
    return (select(medications)..where((tbl) => tbl.id.equals(id)))
        .getSingle();
  }

  Future<int> insertMedication(MedicationsCompanion medication) async {
    return into(medications).insert(medication);
  }

  Future<bool> updateMedication(MedicationsCompanion medication) async {
    return update(medications).replace(medication);
  }

  Future<int> deleteMedication(int id) async {
    return (delete(medications)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> softDeleteMedication(int id) async {
    return (update(medications)..where((tbl) => tbl.id.equals(id)))
        .write(const MedicationsCompanion(isActive: Value(false)));
  }

  Future<List<MedicationTime>> getTimesForMedication(int medicationId) async {
    return (select(medicationTimes)
          ..where((tbl) => tbl.medicationId.equals(medicationId)))
        .get();
  }

  Future<int> insertMedicationTime(MedicationTimesCompanion time) async {
    return into(medicationTimes).insert(time);
  }

  Future<int> deleteMedicationTime(int id) async {
    return (delete(medicationTimes)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> deleteTimesForMedication(int medicationId) async {
    return (delete(medicationTimes)
          ..where((tbl) => tbl.medicationId.equals(medicationId)))
        .go();
  }

  Future<List<MedicationLog>> getLogsForMedication(
      int medicationId, DateTime startDate, DateTime endDate) async {
    return (select(medicationLogs)
          ..where((tbl) =>
              tbl.medicationId.equals(medicationId) &
              tbl.logDate.isBiggerOrEqualValue(startDate) &
              tbl.logDate.isSmallerOrEqualValue(endDate)))
        .get();
  }

  Future<List<MedicationLog>> getLogsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(medicationLogs)
          ..where((tbl) =>
              tbl.logDate.isBiggerOrEqualValue(startOfDay) &
              tbl.logDate.isSmallerThanValue(endOfDay)))
        .get();
  }

  Future<MedicationLog?> getLogForMedicationTimeAndDate(
      int medicationId, int medicationTimeId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final query = select(medicationLogs)
      ..where((tbl) =>
          tbl.medicationId.equals(medicationId) &
          tbl.medicationTimeId.equals(medicationTimeId) &
          tbl.logDate.isBiggerOrEqualValue(startOfDay) &
          tbl.logDate.isSmallerThanValue(endOfDay));
    final results = await query.get();
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertMedicationLog(MedicationLogsCompanion log) async {
    return into(medicationLogs).insert(log);
  }

  Future<bool> updateMedicationLog(MedicationLogsCompanion log) async {
    return update(medicationLogs).replace(log);
  }

  Future<int> deleteMedicationLog(int id) async {
    return (delete(medicationLogs)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> countTakenLogsForDateRange(
      DateTime startDate, DateTime endDate) async {
    final query = selectOnly(medicationLogs)
      ..addColumns([medicationLogs.id.count()])
      ..where(medicationLogs.status.equals('taken') &
          medicationLogs.logDate.isBiggerOrEqualValue(startDate) &
          medicationLogs.logDate.isSmallerOrEqualValue(endDate));
    final result = await query.getSingle();
    return result.read(medicationLogs.id.count()) ?? 0;
  }

  Future<int> countTotalScheduledForDateRange(
      DateTime startDate, DateTime endDate) async {
    final medications = await getAllActiveMedications();
    int totalCount = 0;

    for (final med in medications) {
      final times = await getTimesForMedication(med.id);
      final daysInRange = endDate.difference(startDate).inDays + 1;
      totalCount += times.length * daysInRange;
    }

    return totalCount;
  }

  Stream<List<Medication>> watchActiveMedications() {
    return (select(medications)
          ..where((tbl) => tbl.isActive.equals(true)))
        .watch();
  }

  Stream<List<MedicationLog>> watchLogsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(medicationLogs)
          ..where((tbl) =>
              tbl.logDate.isBiggerOrEqualValue(startOfDay) &
              tbl.logDate.isSmallerThanValue(endOfDay)))
        .watch();
  }

  Future<List<UserPreference>> getAllUserPreferences() async {
    return select(userPreferences).get();
  }

  Future<UserPreference?> getUserPreference() async {
    final results = await select(userPreferences).get();
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertUserPreferences(UserPreferencesCompanion preferences) async {
    return into(userPreferences).insert(preferences);
  }

  Future<bool> updateUserPreferences(UserPreferencesCompanion preferences) async {
    return update(userPreferences).replace(preferences);
  }

  Future<int> deleteUserPreferences(int id) async {
    return (delete(userPreferences)..where((tbl) => tbl.id.equals(id))).go();
  }

  Stream<UserPreference?> watchUserPreferences() {
    return select(userPreferences).watchSingleOrNull();
  }
}
