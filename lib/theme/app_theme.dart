import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.lightBg,
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
    textTheme: _textTheme(false),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Manrope',
    scaffoldBackgroundColor: AppColors.darkBg,
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
    textTheme: _textTheme(true),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.darkSecondary,
    ),
  );

  static TextTheme _textTheme(bool isDark) => TextTheme(
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
