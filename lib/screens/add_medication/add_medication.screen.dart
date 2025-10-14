import 'package:flutter/material.dart';
import 'package:med_track_v2/screens/add_medication/medication_details.view.dart';
import 'package:med_track_v2/screens/add_medication/medication_frequency.view.dart';
import 'package:med_track_v2/screens/add_medication/medication_review.view.dart';
import 'package:med_track_v2/services/medication_service.dart';
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:med_track_v2/widgets/custom_app_bar.widget.dart';
import 'package:med_track_v2/widgets/step_progress_bar.widget.dart';
import 'package:provider/provider.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 1;
  static const int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = _pageController.page;
    if (page != null) {
      final newStep = page.round() + 1;
      if (newStep != _currentStep) {
        setState(() {
          _currentStep = newStep;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicationService = Provider.of<MedicationService>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => AddMedicationViewModel(medicationService),
      child: Scaffold(
        appBar: const CustomAppBar(
          greeting: 'Add Medication',
          userName: 'User Name',
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: StepProgressBar(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
              ),
            ),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  MedicationDetailsView(pageController: _pageController),
                  MedicationFrequencyView(pageController: _pageController),
                  MedicationReviewView(pageController: _pageController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
