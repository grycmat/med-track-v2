import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class AddMedicationDialog extends StatelessWidget {
  const AddMedicationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.darkGradient
                  : AppColors.lightGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: isDark ? Colors.white : AppColors.lightHeader,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text('Add Medication', style: theme.textTheme.displaySmall),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Navigate to the medication setup flow to add a new medication to your schedule.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.darkGradient
                  : AppColors.lightGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  HapticFeedback.lightImpact();
                },
                borderRadius: BorderRadius.circular(24),
                child: Center(
                  child: Text(
                    'Add Medication',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.lightHeader,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
      ],
    );
  }
}
