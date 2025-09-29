import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:med_track_v2/widgets/add_medication/custom_text_field.widget.dart';
import 'package:med_track_v2/widgets/gradient_button.widget.dart';
import 'package:provider/provider.dart';

class MedicationDetailsView extends StatelessWidget {
  final PageController pageController;
  const MedicationDetailsView({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final viewModel = Provider.of<AddMedicationViewModel>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Placeholder for the "Pill bottle and pills" image
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_liquid, // Placeholder icon
                size: 48,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Medication Details',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start by telling us the name and dosage.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: (isDark ? AppColors.darkText : AppColors.lightText)
                    .withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            CustomTextField(
              label: 'Medication Name',
              hintText: 'e.g. Ibuprofen',
              icon: Icons.medication,
              onChanged: (value) => viewModel.setMedicationName(value),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Dosage (e.g., 200 mg)',
              hintText: 'e.g. 1 pill',
              icon: Icons.medical_services_outlined,
              onChanged: (value) => viewModel.setDosage(value),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<AddMedicationViewModel>(
          builder: (context, vm, child) {
            final bool isEnabled =
                (vm.medicationName?.isNotEmpty ?? false) &&
                (vm.dosage?.isNotEmpty ?? false);

            return GradientButton(
              text: 'Next: Frequency',
              trailingIcon: Icons.arrow_forward,
              onPressed: isEnabled
                  ? () {
                      pageController.animateToPage(
                        1,
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
