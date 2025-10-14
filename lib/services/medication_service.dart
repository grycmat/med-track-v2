import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_track_v2/database/app_database.dart';
import 'package:med_track_v2/models/medication.dart' as models;
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:med_track_v2/widgets/stats_card.widget.dart';

class MedicationService {
  final AppDatabase _database;

  MedicationService(this._database);

  Future<void> addMedication({
    required String name,
    required String dosageAmount,
    required String dosageUnit,
    required Frequency frequency,
    required Set<Day> selectedDays,
    required List<TimeOfDay> times,
  }) async {
    await _database.transaction(() async {
      final medicationId = await _database.insertMedication(
        MedicationsCompanion.insert(
          name: name,
          dosageAmount: dosageAmount,
          dosageUnit: dosageUnit,
          frequency: frequency.name,
          selectedDays: Value(selectedDays),
        ),
      );

      for (final time in times) {
        await _database.insertMedicationTime(
          MedicationTimesCompanion.insert(
            medicationId: medicationId,
            hour: time.hour,
            minute: time.minute,
          ),
        );
      }
    });
  }

  Future<List<models.MedicationData>> getTodaysMedications() async {
    final medications = await _database.getAllActiveMedications();
    final today = DateTime.now();
    final todayWeekday = _convertToDayEnum(today.weekday);
    final result = <models.MedicationData>[];

    for (final medication in medications) {
      if (!_shouldShowMedicationToday(medication, todayWeekday)) {
        continue;
      }

      final times = await _database.getTimesForMedication(medication.id);

      for (final time in times) {
        final log = await _database.getLogForMedicationTimeAndDate(
          medication.id,
          time.id,
          today,
        );

        final scheduledTime = DateTime(
          today.year,
          today.month,
          today.day,
          time.hour,
          time.minute,
        );

        final medicationData = _mapToMedicationData(
          medication,
          time,
          scheduledTime,
          log,
        );

        result.add(medicationData);
      }
    }

    result.sort((a, b) => a.time.compareTo(b.time));
    return result;
  }

  Future<models.MedicationData?> getNextDoseMedication() async {
    final medications = await getTodaysMedications();

    final upcomingMedications = medications.where((med) {
      if (med.status == models.MedicationStatus.upcoming ||
          med.status == models.MedicationStatus.takeNow) {
        return true;
      }
      return false;
    }).toList();

    if (upcomingMedications.isEmpty) {
      return null;
    }

    upcomingMedications.sort((a, b) {
      final timeA = _parseTimeString(a.time);
      final timeB = _parseTimeString(b.time);
      return timeA.compareTo(timeB);
    });

    return upcomingMedications.first;
  }

  Stream<List<models.MedicationData>> watchTodaysMedications() {
    return _database.watchActiveMedications().asyncMap((_) async {
      return getTodaysMedications();
    });
  }

  Future<void> markMedicationTaken(
    int medicationId,
    int timeId,
    DateTime date,
  ) async {
    final existingLog = await _database.getLogForMedicationTimeAndDate(
      medicationId,
      timeId,
      date,
    );

    if (existingLog != null) {
      await _database.updateMedicationLog(
        MedicationLogsCompanion(
          id: Value(existingLog.id),
          medicationId: Value(medicationId),
          medicationTimeId: Value(timeId),
          logDate: Value(date),
          status: const Value('taken'),
          takenAt: Value(DateTime.now()),
        ),
      );
    } else {
      await _database.insertMedicationLog(
        MedicationLogsCompanion.insert(
          medicationId: medicationId,
          medicationTimeId: timeId,
          logDate: date,
          status: 'taken',
          takenAt: Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> updateMedication({
    required int medicationId,
    required String name,
    required String dosageAmount,
    required String dosageUnit,
    required Frequency frequency,
    required Set<Day> selectedDays,
    required List<TimeOfDay> times,
  }) async {
    await _database.transaction(() async {
      await _database.updateMedication(
        MedicationsCompanion(
          id: Value(medicationId),
          name: Value(name),
          dosageAmount: Value(dosageAmount),
          dosageUnit: Value(dosageUnit),
          frequency: Value(frequency.name),
          selectedDays: Value(selectedDays),
        ),
      );

      await _database.deleteTimesForMedication(medicationId);

      for (final time in times) {
        await _database.insertMedicationTime(
          MedicationTimesCompanion.insert(
            medicationId: medicationId,
            hour: time.hour,
            minute: time.minute,
          ),
        );
      }
    });
  }

  Future<void> deleteMedication(int medicationId) async {
    await _database.softDeleteMedication(medicationId);
  }

  Future<List<StatItem>> getDashboardStats() async {
    final streak = await calculateStreak();
    final adherence = await calculateWeeklyAdherence();

    return [
      StatItem(
        icon: Icons.local_fire_department,
        value: streak.toString(),
        label: 'Day Streak',
        color: const Color(0xFFFF6B6B),
        animationDelay: 0,
      ),
      StatItem(
        icon: Icons.show_chart,
        value: '${adherence.round()}%',
        label: 'Weekly Adherence',
        color: const Color(0xFF4ECDC4),
        animationDelay: 100,
      ),
    ];
  }

  Future<int> calculateStreak() async {
    int streak = 0;
    DateTime checkDate = DateTime.now().subtract(const Duration(days: 1));

    while (true) {
      final dayAdherence = await _calculateDayAdherence(checkDate);

      if (dayAdherence == null || dayAdherence < 1.0) {
        break;
      }

      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));

      if (streak > 365) {
        break;
      }
    }

    return streak;
  }

  Future<double> calculateWeeklyAdherence() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6));

    int totalScheduled = 0;
    int totalTaken = 0;

    for (int i = 0; i < 7; i++) {
      final checkDate = startDate.add(Duration(days: i));
      final dayStats = await _getDayStatistics(checkDate);

      totalScheduled += dayStats.scheduled;
      totalTaken += dayStats.taken;
    }

    if (totalScheduled == 0) {
      return 0.0;
    }

    return (totalTaken / totalScheduled) * 100;
  }

  Future<int> getTodaysProgress() async {
    final today = DateTime.now();
    final logs = await _database.getLogsForDate(today);
    return logs.where((log) => log.status == 'taken').length;
  }

  Future<int> getTodaysTotal() async {
    final medications = await getTodaysMedications();
    return medications.length;
  }

  bool _shouldShowMedicationToday(Medication medication, Day todayWeekday) {
    final frequency = _parseFrequency(medication.frequency);

    switch (frequency) {
      case Frequency.daily:
        return true;
      case Frequency.weekly:
        return medication.selectedDays?.contains(todayWeekday) ?? false;
      case Frequency.specificDays:
        return medication.selectedDays?.contains(todayWeekday) ?? false;
    }
  }

  models.MedicationData _mapToMedicationData(
    Medication medication,
    MedicationTime time,
    DateTime scheduledTime,
    MedicationLog? log,
  ) {
    final status = _determineStatus(scheduledTime, log);
    final dueInfo = _generateDueInfo(scheduledTime, status, log);
    final timeString = _formatTime(time.hour, time.minute);
    final dosage = '${medication.dosageAmount} ${medication.dosageUnit}';

    return models.MedicationData(
      id: medication.id,
      timeId: time.id,
      name: medication.name,
      dosage: dosage,
      time: timeString,
      status: status,
      dueInfo: dueInfo,
      icon: Icons.medication,
    );
  }

  models.MedicationStatus _determineStatus(
    DateTime scheduledTime,
    MedicationLog? log,
  ) {
    if (log != null && log.status == 'taken') {
      return models.MedicationStatus.taken;
    }

    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.inMinutes.abs() <= 30) {
      return models.MedicationStatus.takeNow;
    }

    if (difference.isNegative) {
      return models.MedicationStatus.missed;
    }

    return models.MedicationStatus.upcoming;
  }

  String _generateDueInfo(
    DateTime scheduledTime,
    models.MedicationStatus status,
    MedicationLog? log,
  ) {
    switch (status) {
      case models.MedicationStatus.taken:
        if (log?.takenAt != null) {
          final takenTime = log!.takenAt!;
          return 'Taken at ${_formatTime(takenTime.hour, takenTime.minute)}';
        }
        return 'Taken';

      case models.MedicationStatus.takeNow:
        return 'Take now';

      case models.MedicationStatus.upcoming:
        final difference = scheduledTime.difference(DateTime.now());
        return 'Take in ${_formatDuration(difference)}';

      case models.MedicationStatus.missed:
        final difference = DateTime.now().difference(scheduledTime);
        return 'Overdue by ${_formatDuration(difference)}';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    }
    return '$minutes min${minutes > 1 ? 's' : ''}';
  }

  String _formatTime(int hour, int minute) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, hour, minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  DateTime _parseTimeString(String timeString) {
    final now = DateTime.now();
    final format = DateFormat('h:mm a');
    final parsedTime = format.parse(timeString);
    return DateTime(
      now.year,
      now.month,
      now.day,
      parsedTime.hour,
      parsedTime.minute,
    );
  }

  Frequency _parseFrequency(String frequency) {
    switch (frequency) {
      case 'daily':
        return Frequency.daily;
      case 'weekly':
        return Frequency.weekly;
      case 'specificDays':
        return Frequency.specificDays;
      default:
        return Frequency.daily;
    }
  }

  Day _convertToDayEnum(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return Day.monday;
      case DateTime.tuesday:
        return Day.tuesday;
      case DateTime.wednesday:
        return Day.wednesday;
      case DateTime.thursday:
        return Day.thursday;
      case DateTime.friday:
        return Day.friday;
      case DateTime.saturday:
        return Day.saturday;
      case DateTime.sunday:
        return Day.sunday;
      default:
        return Day.monday;
    }
  }

  Future<double?> _calculateDayAdherence(DateTime date) async {
    final dayStats = await _getDayStatistics(date);

    if (dayStats.scheduled == 0) {
      return null;
    }

    return dayStats.taken / dayStats.scheduled;
  }

  Future<({int scheduled, int taken})> _getDayStatistics(DateTime date) async {
    final medications = await _database.getAllActiveMedications();
    final dayWeekday = _convertToDayEnum(date.weekday);

    int scheduled = 0;
    int taken = 0;

    for (final medication in medications) {
      if (medication.createdAt.isAfter(date.add(const Duration(days: 1)))) {
        continue;
      }

      if (!_shouldShowMedicationToday(medication, dayWeekday)) {
        continue;
      }

      final times = await _database.getTimesForMedication(medication.id);
      scheduled += times.length;

      for (final time in times) {
        final log = await _database.getLogForMedicationTimeAndDate(
          medication.id,
          time.id,
          date,
        );

        if (log != null && log.status == 'taken') {
          taken++;
        }
      }
    }

    return (scheduled: scheduled, taken: taken);
  }
}
