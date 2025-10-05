import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class DosageInput extends StatelessWidget {
  final String label;
  final String amountHint;
  final String initialUnit;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onUnitChanged;

  const DosageInput({
    super.key,
    required this.label,
    required this.amountHint,
    required this.initialUnit,
    required this.onAmountChanged,
    required this.onUnitChanged,
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
        Row(
          children: [
            Expanded(
              flex: 35,
              child: _buildAmountField(context, theme, isDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 65,
              child: _buildUnitDropdown(context, theme, isDark),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountField(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return TextField(
      onChanged: onAmountChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      style: TextStyle(
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
      decoration: InputDecoration(
        hintText: amountHint,
        hintStyle: TextStyle(
          color: (isDark ? AppColors.darkText : AppColors.lightText)
              .withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(
          Icons.medical_services_outlined,
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          size: 20,
        ),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
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
          borderSide: BorderSide(
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildUnitDropdown(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    final units = [
      'pill(s)',
      'tablet(s)',
      'mg',
      'ml',
      'g',
      'spoon(s)',
      'drop(s)',
      'puff(s)',
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: initialUnit,
        onChanged: (value) {
          if (value != null) {
            onUnitChanged(value);
          }
        },
        items: units.map((unit) {
          return DropdownMenuItem(
            value: unit,
            child: Text(unit),
          );
        }).toList(),
        style: TextStyle(
          color: isDark ? AppColors.darkText : AppColors.lightText,
          fontSize: 16,
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        ),
        dropdownColor: theme.cardColor,
        decoration: InputDecoration(
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
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
            borderSide: BorderSide(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}