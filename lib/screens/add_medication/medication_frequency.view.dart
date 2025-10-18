import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:med_track_v2/widgets/add_medication/day_of_week_picker.widget.dart';
import 'package:med_track_v2/widgets/add_medication/frequency_selector.widget.dart';
import 'package:med_track_v2/widgets/add_medication/time_of_day.widget.dart';
import 'package:med_track_v2/widgets/gradient_button.widget.dart';
import 'package:provider/provider.dart';

class MedicationFrequencyView extends StatelessWidget {
  final PageController pageController;
  const MedicationFrequencyView({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Placeholder for the "Calendar" image
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined, // Placeholder icon
                size: 48,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How often?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Set the frequency for your medication.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: (isDark ? AppColors.darkText : AppColors.lightText)
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const FrequencySelector(),
            const DayOfWeekPicker(),
            const SizedBox(height: 24),
            const TimeOfDayWidget(),
            const SizedBox(height: 64),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<AddMedicationViewModel>(
          builder: (context, vm, child) {
            final bool isEnabled = vm.times.isNotEmpty;
            return GradientButton(
              text: 'Continue',
              trailingIcon: Icons.arrow_forward,
              onPressed: isEnabled
                  ? () {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }
}
