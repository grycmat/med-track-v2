import 'package:flutter/material.dart';

class AddMedicationViewModel extends ChangeNotifier {
  String? _medicationName;
  String? _dosage;
  Frequency _frequency = Frequency.daily;
  final Set<Day> _selectedDays = {};
  final List<TimeOfDay> _times = [];

  String? get medicationName => _medicationName;
  String? get dosage => _dosage;
  Frequency get frequency => _frequency;
  Set<Day> get selectedDays => _selectedDays;
  List<TimeOfDay> get times => _times;

  void setMedicationName(String name) {
    _medicationName = name;
    notifyListeners();
  }

  void setDosage(String dosage) {
    _dosage = dosage;
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