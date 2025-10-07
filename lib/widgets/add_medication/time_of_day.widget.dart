import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:provider/provider.dart';

class TimeOfDayWidget extends StatelessWidget {
  const TimeOfDayWidget({super.key});

  Future<void> _selectTime(
    BuildContext context,
    AddMedicationViewModel viewModel,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      viewModel.addTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time of Day',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 16),
        Consumer<AddMedicationViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: viewModel.times.map((time) {
                final iconData = time.period == DayPeriod.am
                    ? Icons.wb_sunny_outlined
                    : Icons.nightlight_outlined;
                final periodLabel = time.period == DayPeriod.am
                    ? 'Morning'
                    : 'Evening';

                return Dismissible(
                  key: Key(time.toString()),
                  onDismissed: (_) => viewModel.removeTime(time),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete_outline, color: Colors.white),
                    ),
                  ),
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        iconData,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                      ),
                      title: Text(periodLabel),
                      trailing: Text(
                        time.format(context),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _selectTime(
            context,
            Provider.of<AddMedicationViewModel>(context, listen: false),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add a time',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
