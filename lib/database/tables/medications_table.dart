import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';

class SelectedDaysConverter extends TypeConverter<Set<Day>, String> {
  const SelectedDaysConverter();

  @override
  Set<Day> fromSql(String fromDb) {
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList.map((item) => Day.values[item as int]).toSet();
  }

  @override
  String toSql(Set<Day> value) {
    final List<int> indexList = value.map((day) => day.index).toList();
    return jsonEncode(indexList);
  }
}

class Medications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get dosageAmount => text()();
  TextColumn get dosageUnit => text()();
  TextColumn get frequency => text()();
  TextColumn get selectedDays =>
      text().map(const SelectedDaysConverter()).nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
