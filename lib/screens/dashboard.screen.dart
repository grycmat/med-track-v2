import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_track_v2/models/medication.dart';
import 'package:med_track_v2/screens/add_medication/add_medication.screen.dart';
import 'package:med_track_v2/screens/settings/settings.screen.dart';
import 'package:med_track_v2/services/medication_service.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/viewmodels/dashboard_viewmodel.dart';
import 'package:med_track_v2/viewmodels/user_preferences_viewmodel.dart';
import 'package:med_track_v2/widgets/bottom_navigation/bottom_nav_item.dart';
import 'package:med_track_v2/widgets/bottom_navigation/custom_bottom_navigation.widget.dart';
import 'package:med_track_v2/widgets/custom_app_bar.widget.dart';
import 'package:med_track_v2/widgets/fab/fab.widget.dart';
import 'package:med_track_v2/widgets/medication_card.widget.dart';
import 'package:med_track_v2/widgets/progress_card.widget.dart';
import 'package:med_track_v2/widgets/sliver_dashboard_app_bar.widget.dart';
import 'package:med_track_v2/widgets/stats_card.widget.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();

    if (index == 0) {
      return;
    }

    if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
      return;
    }

    setState(() {
      _currentNavIndex = index;
    });

    final routes = [
      null,
      '/schedule',
      '/history',
      '/settings',
    ];

    if (routes[index] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_navItems[index].label} - Coming soon'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _onNotificationTap() {
    HapticFeedback.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('You have upcoming medications'),
        backgroundColor: isDark
            ? AppColors.darkPrimary
            : AppColors.lightPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onAddMedication() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final medicationService = Provider.of<MedicationService>(
      context,
      listen: false,
    );
    final userPreferencesViewModel = Provider.of<UserPreferencesViewModel>(
      context,
    );

    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(medicationService)
        ..loadDashboardData()
        ..startWatchingMedications(),
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<DashboardViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.todaysMedications.isEmpty) {
                return Column(
                  children: [
                    CustomAppBar(
                      greeting: _getGreeting(),
                      userName: userPreferencesViewModel.displayName,
                      hasNotification: true,
                      onNotificationTap: _onNotificationTap,
                    ),
                    Expanded(child: _buildEmptyState()),
                  ],
                );
              }

              return CustomScrollView(
                slivers: [
                  SliverDashboardAppBar(
                    greeting: _getGreeting(),
                    userName: userPreferencesViewModel.displayName,
                    stats: viewModel.stats,
                    hasNotification: true,
                    onNotificationTap: _onNotificationTap,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildProgressCard(viewModel),
                        const SizedBox(height: 24),
                        _buildNextDoseSection(viewModel),
                        const SizedBox(height: 24),
                        _buildTodayScheduleSection(viewModel),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              );
            },
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

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: (isDark ? AppColors.darkText : AppColors.lightText)
                .withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No medications yet',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first medication',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (isDark ? AppColors.darkText : AppColors.lightText)
                  .withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(DashboardViewModel viewModel) {
    final completed = viewModel.todaysMedications
        .where((med) => med.status == MedicationStatus.taken)
        .length;
    final total = viewModel.todaysMedications.length;
    final progress = total > 0 ? completed / total : 0.0;

    return ProgressCard(
      progress: progress,
      completedCount: completed,
      totalCount: total,
    );
  }

  Widget _buildNextDoseSection(DashboardViewModel viewModel) {
    final nextDose = viewModel.nextDose;
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
        Consumer<DashboardViewModel>(
          builder: (context, vm, child) {
            return MedicationCard(
              name: nextDose.name,
              dosage: nextDose.dosage,
              time: nextDose.time,
              status: nextDose.status,
              dueInfo: nextDose.dueInfo,
              customIcon: nextDose.icon,
              onTakeNow: () => _onTakeNow(vm, nextDose),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodayScheduleSection(DashboardViewModel viewModel) {
    final schedule = viewModel.todaysMedications
        .where((med) => med.status != MedicationStatus.takeNow)
        .toList();

    if (schedule.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        SectionHeader(
          title: "Today's Schedule",
          subtitle: _formatDate(DateTime.now()),
        ),
        const SizedBox(height: 16),
        ...schedule.map(
          (medication) => Consumer<DashboardViewModel>(
            builder: (context, vm, child) {
              return MedicationCard(
                name: medication.name,
                dosage: medication.dosage,
                time: medication.time,
                status: medication.status,
                dueInfo: medication.dueInfo,
                customIcon: medication.icon,
                onTakeNow: medication.status == MedicationStatus.upcoming
                    ? () => _onTakeNow(vm, medication)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  void _onTakeNow(DashboardViewModel viewModel, MedicationData medication) {
    HapticFeedback.mediumImpact();
    viewModel.markMedicationTaken(medication.id, medication.timeId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medication.name} marked as taken'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
