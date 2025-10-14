import 'dart:async';
import 'package:flutter/material.dart';
import 'package:med_track_v2/models/medication.dart';
import 'package:med_track_v2/services/medication_service.dart';
import 'package:med_track_v2/widgets/stats_card.widget.dart';

class DashboardViewModel extends ChangeNotifier {
  final MedicationService _medicationService;

  List<MedicationData> _todaysMedications = [];
  MedicationData? _nextDose;
  List<StatItem> _stats = [];
  bool _isLoading = false;
  StreamSubscription<List<MedicationData>>? _medicationsSubscription;

  DashboardViewModel(this._medicationService);

  List<MedicationData> get todaysMedications => _todaysMedications;
  MedicationData? get nextDose => _nextDose;
  List<StatItem> get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final medications = await _medicationService.getTodaysMedications();
      final nextDoseMed = await _medicationService.getNextDoseMedication();
      final dashboardStats = await _medicationService.getDashboardStats();

      _todaysMedications = medications;
      _nextDose = nextDoseMed;
      _stats = dashboardStats;
    } catch (error) {
      debugPrint('Error loading dashboard data: $error');
      _todaysMedications = [];
      _nextDose = null;
      _stats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markMedicationTaken(int medicationId, int timeId) async {
    try {
      await _medicationService.markMedicationTaken(
        medicationId,
        timeId,
        DateTime.now(),
      );
      await loadDashboardData();
    } catch (error) {
      debugPrint('Error marking medication as taken: $error');
    }
  }

  void startWatchingMedications() {
    _medicationsSubscription = _medicationService
        .watchTodaysMedications()
        .listen((medications) {
      _todaysMedications = medications;
      notifyListeners();
      _updateNextDose();
    }, onError: (error) {
      debugPrint('Error watching medications: $error');
    });
  }

  void _updateNextDose() async {
    try {
      final nextDoseMed = await _medicationService.getNextDoseMedication();
      _nextDose = nextDoseMed;
      notifyListeners();
    } catch (error) {
      debugPrint('Error updating next dose: $error');
    }
  }

  @override
  void dispose() {
    _medicationsSubscription?.cancel();
    super.dispose();
  }
}
