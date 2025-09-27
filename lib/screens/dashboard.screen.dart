import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_track_v2/data/dummy_data.dart';
import 'package:med_track_v2/models/medication.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/theme/app_theme.dart';
import 'package:med_track_v2/widgets/add_medication.widget.dart';
import 'package:med_track_v2/widgets/custom_app_bar.widget.dart';
import 'package:med_track_v2/widgets/custom_bottom_navigation.widget.dart';
import 'package:med_track_v2/widgets/fab.widget.dart';
import 'package:med_track_v2/widgets/medication_card.widget.dart';
import 'package:med_track_v2/widgets/progress_card.widget.dart';
import 'package:med_track_v2/widgets/stats_card.widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  bool _isDarkMode = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<MedicationData> _medications = dummyData;

  final List<StatItem> _stats = dummyStats;

  final List<BottomNavItem> _navItems = [
    BottomNavItem(icon: Icons.medication, label: 'Medications'),
    BottomNavItem(icon: Icons.calendar_month, label: 'Schedule'),
    BottomNavItem(icon: Icons.history, label: 'History'),
    BottomNavItem(icon: Icons.settings, label: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    HapticFeedback.lightImpact();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
    HapticFeedback.selectionClick();
  }

  void _onNotificationTap() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('You have 2 upcoming medications'),
        backgroundColor: _isDarkMode
            ? AppColors.darkPrimary
            : AppColors.lightPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onTakeNow(String medicationName) {
    HapticFeedback.mediumImpact();
    setState(() {
      final index = _medications.indexWhere(
        (med) => med.name == medicationName,
      );
      if (index != -1) {
        _medications[index] = _medications[index].copyWith(
          status: MedicationStatus.taken,
          dueInfo: null,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$medicationName marked as taken'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onAddMedication() {
    HapticFeedback.lightImpact();
    showDialog(context: context, builder: (context) => AddMedicationDialog());
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  int _getCompletedCount() {
    return _medications
        .where((med) => med.status == MedicationStatus.taken)
        .length;
  }

  double _getProgress() {
    final completed = _getCompletedCount();
    return completed / _medications.length;
  }

  MedicationData? _getNextDose() {
    return _medications
            .where((med) => med.status == MedicationStatus.upcoming)
            .isNotEmpty
        ? _medications.firstWhere(
            (med) => med.status == MedicationStatus.upcoming,
          )
        : null;
  }

  List<MedicationData> _getTodaySchedule() {
    return _medications
        .where((med) => med.status != MedicationStatus.takeNow)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              CustomAppBar(
                greeting: _getGreeting(),
                userName: 'Alex',
                hasNotification: true,
                onNotificationTap: _onNotificationTap,
                onThemeToggle: _toggleTheme,
                isDarkMode: _isDarkMode,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProgressCard(
                        progress: _getProgress(),
                        completedCount: _getCompletedCount(),
                        totalCount: _medications.length,
                      ),
                      const SizedBox(height: 24),
                      _buildNextDoseSection(),
                      const SizedBox(height: 24),
                      _buildTodayScheduleSection(),
                      const SizedBox(height: 24),
                      QuickStatsSection(stats: _stats),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: CustomFloatingActionButton(
          onPressed: _onAddMedication,
        ),
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: _currentNavIndex,
          onTap: _onNavTap,
          items: _navItems,
        ),
      ),
    );
  }

  Widget _buildNextDoseSection() {
    final nextDose = _getNextDose();
    if (nextDose == null) {
      return Container();
    }

    return Column(
      children: [
        SectionHeader(
          title: 'Next Dose',
          actionText: 'View all',
          onActionTap: () {
            HapticFeedback.lightImpact();
          },
        ),
        const SizedBox(height: 16),
        MedicationCard(
          name: nextDose.name,
          dosage: nextDose.dosage,
          time: nextDose.time,
          status: nextDose.status,
          dueInfo: nextDose.dueInfo,
          customIcon: nextDose.icon,
          onTakeNow: () => _onTakeNow(nextDose.name),
        ),
      ],
    );
  }

  Widget _buildTodayScheduleSection() {
    final schedule = _getTodaySchedule();

    return Column(
      children: [
        SectionHeader(
          title: "Today's Schedule",
          subtitle: _formatDate(DateTime.now()),
        ),
        const SizedBox(height: 16),
        ...schedule.map(
          (medication) => MedicationCard(
            name: medication.name,
            dosage: medication.dosage,
            time: medication.time,
            status: medication.status,
            dueInfo: medication.dueInfo,
            customIcon: medication.icon,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
