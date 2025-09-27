import 'package:flutter/material.dart';
import 'package:med_track_v2/viewmodels/add_medication_viewmodel.dart';
import 'package:med_track_v2/screens/add_medication/medication_details.view.dart';
import 'package:med_track_v2/screens/add_medication/medication_frequency.view.dart';
import 'package:med_track_v2/screens/add_medication/medication_review.view.dart';
import 'package:med_track_v2/widgets/custom_app_bar.widget.dart';
import 'package:provider/provider.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddMedicationViewModel(),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Add Medication',
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            MedicationDetailsView(pageController: _pageController),
            MedicationFrequencyView(pageController: _pageController),
            MedicationReviewView(pageController: _pageController),
          ],
        ),
      ),
    );
  }
}