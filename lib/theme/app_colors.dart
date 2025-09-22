import 'package:flutter/material.dart';

class AppColors {
  static const lightBg = Color(0xFFFDF4F5);
  static const lightText = Color(0xFF5B5F97);
  static const lightPrimary = Color(0xFFFFD6E0);
  static const lightSecondary = Color(0xFFC7CEEA);
  static const lightAccent = Color(0xFFB3E5FC);
  static const lightHeader = Color(0xFF4A4E8A);

  static const darkBg = Color(0xFF2C2C3E);
  static const darkText = Color(0xFFEAE8FF);
  static const darkPrimary = Color(0xFF756D9F);
  static const darkSecondary = Color(0xFF534B7E);
  static const darkAccent = Color(0xFF3A355A);
  static const darkHeader = Color(0xFFFFFFFF);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF97316);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  static const purple = Color(0xFF9333EA);

  static LinearGradient lightGradient = const LinearGradient(
    colors: [lightPrimary, lightAccent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient darkGradient = const LinearGradient(
    colors: [darkPrimary, darkAccent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static LinearGradient avatarGradient(bool isDark) => LinearGradient(
    colors: isDark ? [darkPrimary, darkAccent] : [lightPrimary, lightAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
