import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.icon,
    required this.onChanged,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: (isDark ? AppColors.darkText : AppColors.lightText).withValues(alpha: 0.5)),
            prefixIcon: Icon(icon, color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary, size: 20),
            filled: true,
            fillColor: theme.cardColor,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: theme.cardColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}