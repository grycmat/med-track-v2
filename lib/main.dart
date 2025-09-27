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

  runApp(MedTrackV2App());
}

class MedTrackV2App extends StatefulWidget {
  const MedTrackV2App({super.key});

  @override
  State<MedTrackV2App> createState() => _MedTrackV2AppState();
}

class _MedTrackV2AppState extends State<MedTrackV2App> {
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
