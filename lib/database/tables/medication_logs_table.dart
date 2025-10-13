import 'package:drift/drift.dart';
import 'package:med_track_v2/database/tables/medications_table.dart';
import 'package:med_track_v2/database/tables/medication_times_table.dart';

class MedicationLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  IntColumn get medicationTimeId => integer().references(MedicationTimes, #id)();
  DateTimeColumn get logDate => dateTime()();
  TextColumn get status => text()();
  DateTimeColumn get takenAt => dateTime().nullable()();
}
