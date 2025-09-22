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
