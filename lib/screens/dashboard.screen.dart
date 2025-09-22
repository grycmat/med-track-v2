import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_track_v2/models/medication.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/widgets/bottom_nav.widget.dart';
import 'package:med_track_v2/widgets/custom_app_bar.widget.dart';
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

  final List<MedicationData> _medications = [
    MedicationData(
      name: 'Vitamin D',
      dosage: '1 tablet • 1000 IU',
      time: '2:30 PM',
      status: MedicationStatus.takeNow,
      dueInfo: 'Due in 30 minutes',
      icon: Icons.medication,
    ),
    MedicationData(
      name: 'Aspirin',
      dosage: '1 tablet • 325mg',
      time: '8:00 AM',
      status: MedicationStatus.taken,
      dueInfo: null,
      icon: Icons.check_circle,
    ),
    MedicationData(
      name: 'Omega-3',
      dosage: '2 capsules • 1000mg',
      time: '12:00 PM',
      status: MedicationStatus.taken,
      dueInfo: null,
      icon: Icons.check_circle,
    ),
    MedicationData(
      name: 'Multivitamin',
      dosage: '1 tablet',
      time: '6:00 PM',
      status: MedicationStatus.taken,
      dueInfo: null,
      icon: Icons.check_circle,
    ),
    MedicationData(
      name: 'Calcium',
      dosage: '1 tablet • 600mg',
      time: '9:00 PM',
      status: MedicationStatus.missed,
      dueInfo: null,
      icon: Icons.schedule,
    ),
  ];

  final List<StatItem> _stats = [
    StatItem(
      icon: Icons.trending_up,
      value: '95%',
      label: 'This week',
      color: AppColors.info,
      animationDelay: 100,
    ),
    StatItem(
      icon: Icons.local_fire_department,
      value: '7',
      label: 'Day streak',
      color: AppColors.purple,
      animationDelay: 200,
    ),
  ];

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
      data: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
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

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: AppColors.lightBg,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightHeader,
        secondary: AppColors.lightPrimary,
        surface: Colors.white,
        background: AppColors.lightBg,
        onPrimary: Colors.white,
        onSecondary: AppColors.lightHeader,
        onSurface: AppColors.lightText,
        onBackground: AppColors.lightText,
      ),
      textTheme: _buildTextTheme(false),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: AppColors.darkBg,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkHeader,
        secondary: AppColors.darkPrimary,
        surface: AppColors.darkSecondary,
        background: AppColors.darkBg,
        onPrimary: AppColors.darkBg,
        onSecondary: AppColors.darkHeader,
        onSurface: AppColors.darkText,
        onBackground: AppColors.darkText,
      ),
      textTheme: _buildTextTheme(true),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.darkSecondary,
      ),
    );
  }

  TextTheme _buildTextTheme(bool isDark) => TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
    ),
    displaySmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
    ),
    headlineLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: isDark ? Colors.white : AppColors.lightHeader,
    ),
    headlineMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : AppColors.lightHeader,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkText : AppColors.lightText,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.darkText : AppColors.lightText,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.darkText : AppColors.lightText,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : AppColors.lightHeader,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.darkText : AppColors.lightText,
    ),
  );
}

class MedicationData {
  final String name;
  final String dosage;
  final String time;
  final MedicationStatus status;
  final String? dueInfo;
  final IconData? icon;

  const MedicationData({
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
    this.dueInfo,
    this.icon,
  });

  MedicationData copyWith({
    String? name,
    String? dosage,
    String? time,
    MedicationStatus? status,
    String? dueInfo,
    IconData? icon,
  }) {
    return MedicationData(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      status: status ?? this.status,
      dueInfo: dueInfo ?? this.dueInfo,
      icon: icon ?? this.icon,
    );
  }
}

class AddMedicationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.darkGradient
                  : AppColors.lightGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: isDark ? Colors.white : AppColors.lightHeader,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text('Add Medication', style: theme.textTheme.displaySmall),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Navigate to the medication setup flow to add a new medication to your schedule.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppColors.darkGradient
                  : AppColors.lightGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  HapticFeedback.lightImpact();
                },
                borderRadius: BorderRadius.circular(24),
                child: Center(
                  child: Text(
                    'Add Medication',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.lightHeader,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
      ],
    );
  }
}
