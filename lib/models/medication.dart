import 'package:flutter/material.dart';

enum MedicationStatus { takeNow, upcoming, taken, missed }

class Medication {
  final String name;
  final String dosage;
  final String time;
  final MedicationStatus status;

  const Medication({
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
  });
}

class MedicationData {
  final String name;
  final String dosage;
  final String time;
  final MedicationStatus status;
  final String? dueInfo;
  final IconData? icon;

  const MedicationData({
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
    this.dueInfo,
    this.icon,
  });

  MedicationData copyWith({
    String? name,
    String? dosage,
    String? time,
    MedicationStatus? status,
    String? dueInfo,
    IconData? icon,
  }) {
    return MedicationData(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      status: status ?? this.status,
      dueInfo: dueInfo ?? this.dueInfo,
      icon: icon ?? this.icon,
    );
  }
}
