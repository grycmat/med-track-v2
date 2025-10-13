import 'package:drift/drift.dart';
import 'package:med_track_v2/database/tables/medications_table.dart';

class MedicationTimes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicationId => integer().references(Medications, #id)();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
}
