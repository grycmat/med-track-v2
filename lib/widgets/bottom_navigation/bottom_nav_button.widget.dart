import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/widgets/bottom_navigation/bottom_nav_item.dart';
import 'package:med_track_v2/widgets/bottom_navigation/notification_badge.widget.dart';

class BottomNavButton extends StatefulWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNavButton({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<BottomNavButton> createState() => _BottomNavButtonState();
}

class _BottomNavButtonState extends State<BottomNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rippleController);
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _rippleController.forward().then((_) {
      _rippleController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(12),
            splashColor:
                (widget.isSelected
                        ? (isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary)
                        : theme.colorScheme.primary)
                    .withValues(alpha: 0.2),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Icon(
                        widget.item.icon,
                        size: 24,
                        color: _getIconColor(theme, isDark),
                      ),
                      if (widget.item.badgeCount != null &&
                          widget.item.badgeCount! > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: NotificationBadge(
                            count: widget.item.badgeCount!,
                          ),
                        ),
                      if (_rippleAnimation.value > 0)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  (widget.isSelected
                                          ? (isDark
                                                ? AppColors.darkPrimary
                                                : AppColors.lightPrimary)
                                          : theme.colorScheme.primary)
                                      .withValues(
                                        alpha: 0.2 * _rippleAnimation.value,
                                      ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getIconColor(ThemeData theme, bool isDark) {
    if (widget.isSelected) {
      return isDark ? AppColors.lightPrimary : AppColors.lightHeader;
    }
    return isDark ? AppColors.darkText : AppColors.lightText;
  }
}
