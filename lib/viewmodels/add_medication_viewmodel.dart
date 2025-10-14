import 'package:flutter/material.dart';
import 'package:med_track_v2/services/medication_service.dart';

class AddMedicationViewModel extends ChangeNotifier {
  final MedicationService _medicationService;

  String? _medicationName;
  String? _dosageAmount;
  String _dosageUnit = 'pill(s)';
  Frequency _frequency = Frequency.daily;
  final Set<Day> _selectedDays = {};
  final List<TimeOfDay> _times = [];
  bool _isLoading = false;

  AddMedicationViewModel(this._medicationService);

  String? get medicationName => _medicationName;
  String? get dosageAmount => _dosageAmount;
  String get dosageUnit => _dosageUnit;
  String? get dosage => _dosageAmount != null && _dosageAmount!.isNotEmpty
      ? '$_dosageAmount $_dosageUnit'
      : null;
  Frequency get frequency => _frequency;
  Set<Day> get selectedDays => _selectedDays;
  List<TimeOfDay> get times => _times;
  bool get isLoading => _isLoading;

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

  Future<bool> saveMedication() async {
    if (!_validateMedicationData()) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _medicationService.addMedication(
        name: _medicationName!,
        dosageAmount: _dosageAmount!,
        dosageUnit: _dosageUnit,
        frequency: _frequency,
        selectedDays: _selectedDays,
        times: _times,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('Error saving medication: $error');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void resetForm() {
    _medicationName = null;
    _dosageAmount = null;
    _dosageUnit = 'pill(s)';
    _frequency = Frequency.daily;
    _selectedDays.clear();
    _times.clear();
    _isLoading = false;
    notifyListeners();
  }

  bool _validateMedicationData() {
    if (_medicationName == null || _medicationName!.trim().isEmpty) {
      return false;
    }
    if (_dosageAmount == null || _dosageAmount!.trim().isEmpty) {
      return false;
    }
    if (_times.isEmpty) {
      return false;
    }
    if (_frequency == Frequency.specificDays && _selectedDays.isEmpty) {
      return false;
    }
    return true;
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