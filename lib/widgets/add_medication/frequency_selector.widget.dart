import 'package:flutter/material.dart';
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:med_track_v2/widgets/gradient_button.widget.dart';
import 'package:provider/provider.dart';

class FrequencySelector extends StatelessWidget {
  const FrequencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddMedicationViewModel>(
      builder: (context, viewModel, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PillButton(
              text: 'Daily',
              isSelected: viewModel.frequency == Frequency.daily,
              onPressed: () => viewModel.setFrequency(Frequency.daily),
            ),
            const SizedBox(width: 12),
            PillButton(
              text: 'Weekly',
              isSelected: viewModel.frequency == Frequency.weekly,
              onPressed: () => viewModel.setFrequency(Frequency.weekly),
            ),
            const SizedBox(width: 12),
            PillButton(
              text: 'Specific Days',
              isSelected: viewModel.frequency == Frequency.specificDays,
              onPressed: () => viewModel.setFrequency(Frequency.specificDays),
            ),
          ],
        );
      },
    );
  }
}