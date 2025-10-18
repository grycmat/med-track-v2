import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_track_v2/database/app_database.dart';
import 'package:med_track_v2/screens/dashboard.screen.dart';
import 'package:med_track_v2/screens/welcome_screen.dart';
import 'package:med_track_v2/services/medication_service.dart';
import 'package:med_track_v2/services/user_preferences_service.dart';
import 'package:med_track_v2/theme/app_theme.dart';
import 'package:med_track_v2/viewmodels/user_preferences_viewmodel.dart';
import 'package:med_track_v2/viewmodels/welcome_viewmodel.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final medicationService = MedicationService(database);
  final userPreferencesService = UserPreferencesService(database);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MedTrackV2App(
    database: database,
    medicationService: medicationService,
    userPreferencesService: userPreferencesService,
  ));
}

class MedTrackV2App extends StatelessWidget {
  final AppDatabase database;
  final MedicationService medicationService;
  final UserPreferencesService userPreferencesService;

  const MedTrackV2App({
    super.key,
    required this.database,
    required this.medicationService,
    required this.userPreferencesService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<MedicationService>.value(value: medicationService),
        Provider<UserPreferencesService>.value(value: userPreferencesService),
        ChangeNotifierProvider(
          create: (_) => UserPreferencesViewModel(userPreferencesService)
            ..loadUsername(),
        ),
      ],
      child: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isCheckingOnboarding = true;
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final database = context.read<AppDatabase>();
    final userPreferencesService = UserPreferencesService(database);

    try {
      final hasCompleted = await userPreferencesService.hasCompletedOnboarding();
      final themeMode = await userPreferencesService.getThemeMode();

      setState(() {
        _hasCompletedOnboarding = hasCompleted;
        _themeMode = _parseThemeMode(themeMode);
        _isCheckingOnboarding = false;
      });
    } catch (e) {
      setState(() {
        _hasCompletedOnboarding = false;
        _isCheckingOnboarding = false;
      });
    }
  }

  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void _updateThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void _handleOnboardingComplete() {
    setState(() {
      _hasCompletedOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingOnboarding) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Medication Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _hasCompletedOnboarding
          ? ThemeModeProvider(
              onThemeChanged: _updateThemeMode,
              child: const DashboardScreen(),
            )
          : _buildWelcomeScreen(),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final currentScale = mediaQuery.textScaler.scale(1.0);
        final clampedScale = currentScale.clamp(0.8, 1.2);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(clampedScale),
          ),
          child: child!,
        );
      },
    );
  }

  Widget _buildWelcomeScreen() {
    final database = context.read<AppDatabase>();
    final userPreferencesService = UserPreferencesService(database);

    return ChangeNotifierProvider(
      create: (_) => WelcomeViewModel(userPreferencesService),
      child: WelcomeScreen(
        onComplete: _handleOnboardingComplete,
      ),
    );
  }
}

class ThemeModeProvider extends InheritedWidget {
  final Function(ThemeMode) onThemeChanged;

  const ThemeModeProvider({
    super.key,
    required this.onThemeChanged,
    required super.child,
  });

  static ThemeModeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeModeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeModeProvider oldWidget) {
    return onThemeChanged != oldWidget.onThemeChanged;
  }
}

extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension DateTimeExtension on DateTime {
  String get timeOfDayString {
    final hour = this.hour > 12
        ? this.hour - 12
        : this.hour == 0
        ? 12
        : this.hour;
    final minute = this.minute.toString().padLeft(2, '0');
    final period = this.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get dayName {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[weekday % 7];
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }
}
