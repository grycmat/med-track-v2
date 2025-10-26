import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:med_track_v2/database/app_database.dart';
import 'package:med_track_v2/services/medication_service.dart';

class MedicationsListViewModel extends ChangeNotifier {
  final MedicationService _medicationService;

  List<Medication> _medications = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<Medication>>? _medicationsSubscription;
  String _searchQuery = '';
  MedicationFilter _filter = MedicationFilter.all;

  MedicationsListViewModel(this._medicationService);

  // Getters
  List<Medication> get medications => _filteredMedications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  MedicationFilter get filter => _filter;
  bool get hasMedications => _medications.isNotEmpty;
  int get medicationsCount => _medications.length;

  List<Medication> get _filteredMedications {
    var filtered = _medications;

    // Apply filter
    switch (_filter) {
      case MedicationFilter.active:
        filtered = filtered.where((m) => m.isActive).toList();
        break;
      case MedicationFilter.inactive:
        filtered = filtered.where((m) => !m.isActive).toList();
        break;
      case MedicationFilter.all:
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((m) {
        return m.name.toLowerCase().contains(query) ||
            m.dosageUnit.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));

    return filtered;
  }

  // Methods
  Future<void> loadMedications() async {
    _setLoading(true);
    _clearError();

    try {
      await _startWatchingMedications();
    } catch (e) {
      _setError('Failed to load medications: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _startWatchingMedications() async {
    await _medicationsSubscription?.cancel();

    _medicationsSubscription = _medicationService.watchAllMedications().listen(
      (medications) {
        _medications = medications;
        notifyListeners();
      },
      onError: (error) {
        _setError('Error watching medications: $error');
      },
    );
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(MedicationFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> toggleMedicationActive(Medication medication) async {
    try {
      await _medicationService.toggleMedicationActive(medication.id);
      // The stream will automatically update the list
    } catch (e) {
      _setError('Failed to update medication: $e');
    }
  }

  Future<void> deleteMedication(Medication medication) async {
    try {
      await _medicationService.deleteMedication(medication.id);
      // The stream will automatically update the list
    } catch (e) {
      _setError('Failed to delete medication: $e');
    }
  }

  Future<void> refresh() async {
    await loadMedications();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _medicationsSubscription?.cancel();
    super.dispose();
  }
}

enum MedicationFilter {
  all,
  active,
  inactive,
}
