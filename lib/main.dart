import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_track_v2/screens/dashboard.screen.dart';
import 'package:med_track_v2/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MedicationApp());
}

class MedicationApp extends StatefulWidget {
  @override
  State<MedicationApp> createState() => _MedicationAppState();
}

class _MedicationAppState extends State<MedicationApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _updateThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medication Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: AppWrapper(
        onThemeChanged: _updateThemeMode,
        child: DashboardScreen(),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

class AppWrapper extends InheritedWidget {
  final Function(ThemeMode) onThemeChanged;

  const AppWrapper({
    super.key,
    required this.onThemeChanged,
    required super.child,
  });

  static AppWrapper? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppWrapper>();
  }

  @override
  bool updateShouldNotify(AppWrapper oldWidget) {
    return onThemeChanged != oldWidget.onThemeChanged;
  }
}

class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showContent = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showContent) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F5),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD6E0), Color(0xFFB3E5FC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD6E0).withOpacity(0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medication,
                        size: 60,
                        color: Color(0xFF4A4E8A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Medication Tracker',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A4E8A),
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your health companion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5B5F97),
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 40),
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFD6E0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AppRoutes {
  static const String dashboard = '/';
  static const String addMedication = '/add-medication';
  static const String medicationDetail = '/medication-detail';
  static const String schedule = '/schedule';
  static const String history = '/history';
  static const String app_settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(child: DashboardScreen()),
        );
      case addMedication:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Add Medication Screen')),
          ),
        );
      case schedule:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Schedule Screen'))),
        );
      case history:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('History Screen'))),
        );
      case app_settings:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Settings Screen'))),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
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
