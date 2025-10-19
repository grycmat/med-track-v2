import 'package:flutter/material.dart';
import 'package:med_track_v2/screens/dashboard.screen.dart';
import 'package:med_track_v2/screens/settings/settings.screen.dart';
import 'package:med_track_v2/widgets/splash_screen.widget.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String addMedication = '/add-medication';
  static const String medicationDetail = '/medication-detail';
  static const String schedule = '/schedule';
  static const String history = '/history';
  static const String appSettings = '/settings';

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
      case appSettings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
