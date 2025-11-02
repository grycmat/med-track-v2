import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class AddMedicationFab extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Object tag;

  const AddMedicationFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.tooltip,
    this.tag = 'add_medication_fab',
  });

  @override
  State<AddMedicationFab> createState() => _AddMedicationFabState();
}

class _AddMedicationFabState extends State<AddMedicationFab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: widget.onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  .withValues(alpha: 0.6),
              blurRadius: 16,
              offset: const Offset(0, 1),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: isDark ? Colors.white : AppColors.lightHeader,
          size: 28,
        ),
      ),
    );
  }
}
