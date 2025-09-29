import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:med_track_v2/widgets/add_medication/review_item.widget.dart';
import 'package:med_track_v2/widgets/gradient_button.widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';


class MedicationReviewView extends StatelessWidget {
  final PageController pageController;
  const MedicationReviewView({super.key, required this.pageController});

  String _formatFrequency(AddMedicationViewModel viewModel) {
    switch (viewModel.frequency) {
      case Frequency.daily:
        return 'Daily';
      case Frequency.weekly:
        return 'Weekly';
      case Frequency.specificDays:
        if (viewModel.selectedDays.isEmpty) {
          return 'No days selected';
        }
        return viewModel.selectedDays.map((d) => d.shortName).join(', ');
    }
  }

  String _formatSchedule(BuildContext context, AddMedicationViewModel viewModel) {
    if (viewModel.times.isEmpty) {
      return 'No time selected';
    }
    return viewModel.times.map((t) => t.format(context)).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Consumer<AddMedicationViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Placeholder for the "Check" image
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Review & Confirm',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Almost done! Please review the details.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: (isDark ? AppColors.darkText : AppColors.lightText).withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                ReviewItem(
                  label: 'Medication',
                  value: viewModel.medicationName ?? 'Not set',
                  onEdit: () => pageController.jumpToPage(0),
                ),
                ReviewItem(
                  label: 'Dosage',
                  value: viewModel.dosage ?? 'Not set',
                  onEdit: () => pageController.jumpToPage(0),
                ),
                ReviewItem(
                  label: 'Frequency',
                  value: _formatFrequency(viewModel),
                  onEdit: () => pageController.jumpToPage(1),
                ),
                ReviewItem(
                  label: 'Schedule',
                  value: _formatSchedule(context, viewModel),
                  onEdit: () => pageController.jumpToPage(1),
                ),
                const SizedBox(height: 24),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add notes (e.g., take with food)',
                    hintStyle: TextStyle(color: (isDark ? AppColors.darkText : AppColors.lightText).withOpacity(0.5)),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GradientButton(
          text: 'Confirm',
          onPressed: () {
            // TODO: Implement save logic
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}