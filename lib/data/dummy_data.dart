import 'package:flutter/material.dart';
import 'package:med_track_v2/models/medication.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/widgets/stats_card.widget.dart';

final List<MedicationData> dummyData = [
  MedicationData(
    name: 'Vitamin D',
    dosage: '1 tablet • 1000 IU',
    time: '2:30 PM',
    status: MedicationStatus.takeNow,
    dueInfo: 'Due in 30 minutes',
    icon: Icons.medication,
  ),
  MedicationData(
    name: 'Aspirin',
    dosage: '1 tablet • 325mg',
    time: '8:00 AM',
    status: MedicationStatus.taken,
    dueInfo: null,
    icon: Icons.check_circle,
  ),
  MedicationData(
    name: 'Omega-3',
    dosage: '2 capsules • 1000mg',
    time: '12:00 PM',
    status: MedicationStatus.taken,
    dueInfo: null,
    icon: Icons.check_circle,
  ),
  MedicationData(
    name: 'Multivitamin',
    dosage: '1 tablet',
    time: '6:00 PM',
    status: MedicationStatus.taken,
    dueInfo: null,
    icon: Icons.check_circle,
  ),
  MedicationData(
    name: 'Calcium',
    dosage: '1 tablet • 600mg',
    time: '9:00 PM',
    status: MedicationStatus.missed,
    dueInfo: null,
    icon: Icons.schedule,
  ),
];

final dummyStats = [
  StatItem(
    icon: Icons.trending_up,
    value: '95%',
    label: 'This week',
    color: AppColors.info,
    animationDelay: 100,
  ),
  StatItem(
    icon: Icons.local_fire_department,
    value: '7',
    label: 'Day streak',
    color: AppColors.purple,
    animationDelay: 200,
  ),
];
