import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:provider/provider.dart';

class DayOfWeekPicker extends StatelessWidget {
  const DayOfWeekPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<AddMedicationViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...[
              const SizedBox(height: 24),
              Text(
                'Days of the Week',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: Day.values.map((day) {
                  final isSelected = viewModel.selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () => viewModel.toggleDay(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary)
                            : theme.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      (isDark
                                              ? AppColors.darkPrimary
                                              : AppColors.lightPrimary)
                                          .withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          day.shortName,
                          style: TextStyle(
                            color: isSelected
                                ? (isDark
                                      ? Colors.white
                                      : AppColors.lightHeader)
                                : (isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }
}
