import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class ReviewItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  const ReviewItem({
    super.key,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: (isDark ? AppColors.darkText : AppColors.lightText)
                        .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
