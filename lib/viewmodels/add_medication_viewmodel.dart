import 'package:flutter/material.dart';

class AddMedicationViewModel extends ChangeNotifier {
  String? _medicationName;
  String? _dosageAmount;
  String _dosageUnit = 'pill(s)';
  Frequency _frequency = Frequency.daily;
  final Set<Day> _selectedDays = {};
  final List<TimeOfDay> _times = [];

  String? get medicationName => _medicationName;
  String? get dosageAmount => _dosageAmount;
  String get dosageUnit => _dosageUnit;
  String? get dosage => _dosageAmount != null && _dosageAmount!.isNotEmpty
      ? '$_dosageAmount $_dosageUnit'
      : null;
  Frequency get frequency => _frequency;
  Set<Day> get selectedDays => _selectedDays;
  List<TimeOfDay> get times => _times;

  void setMedicationName(String name) {
    _medicationName = name;
    notifyListeners();
  }

  void setDosageAmount(String amount) {
    _dosageAmount = amount;
    notifyListeners();
  }

  void setDosageUnit(String unit) {
    _dosageUnit = unit;
    notifyListeners();
  }

  void setFrequency(Frequency frequency) {
    _frequency = frequency;
    notifyListeners();
  }

  void toggleDay(Day day) {
    if (_selectedDays.contains(day)) {
      _selectedDays.remove(day);
    } else {
      _selectedDays.add(day);
    }
    notifyListeners();
  }

  void addTime(TimeOfDay time) {
    _times.add(time);
    notifyListeners();
  }

  void removeTime(TimeOfDay time) {
    _times.remove(time);
    notifyListeners();
  }
}

enum Frequency { daily, weekly, specificDays }

enum Day { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

extension DayExtension on Day {
  String get shortName {
    switch (this) {
      case Day.sunday:
        return 'S';
      case Day.monday:
        return 'M';
      case Day.tuesday:
        return 'T';
      case Day.wednesday:
        return 'W';
      case Day.thursday:
        return 'T';
      case Day.friday:
        return 'F';
      case Day.saturday:
        return 'S';
    }
  }
}