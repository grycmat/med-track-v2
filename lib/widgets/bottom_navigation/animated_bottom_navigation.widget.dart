import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/widgets/bottom_navigation/bottom_nav_item.dart';
import 'package:med_track_v2/widgets/bottom_navigation/notification_badge.widget.dart';

class AnimatedBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final double height;

  const AnimatedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.height = 70,
  });

  @override
  State<AnimatedBottomNavigation> createState() =>
      _AnimatedBottomNavigationState();
}

class _AnimatedBottomNavigationState extends State<AnimatedBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _updateSlideAnimation();
    _slideController.forward();
  }

  void _updateSlideAnimation() {
    final double targetX =
        (widget.currentIndex * 2.0 - (widget.items.length - 1)) /
        (widget.items.length - 1);
    _slideAnimation =
        Tween<Offset>(
          begin: _slideAnimation?.value ?? const Offset(0, 0),
          end: Offset(targetX * 0.25, 0),
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutCubic,
          ),
        );
  }

  @override
  void didUpdateWidget(AnimatedBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateSlideAnimation();
      _slideController.forward();
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ??
            (isDark ? AppColors.darkSecondary : Colors.white).withValues(
              alpha: 0.9,
            ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkAccent
                : Colors.grey.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _slideAnimation!,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _slideAnimation!.value.dx *
                          MediaQuery.of(context).size.width,
                      0,
                    ),
                    child: Container(
                      width:
                          MediaQuery.of(context).size.width /
                          widget.items.length,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? AppColors.darkGradient
                            : AppColors.lightGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == widget.currentIndex;

                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => widget.onTap(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: Matrix4.diagonal3Values(
                                    isSelected ? 1.1 : 1.0,
                                    isSelected ? 1.1 : 1.0,
                                    1.0,
                                  ),
                                  child: Stack(
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 24,
                                        color: isSelected
                                            ? (isDark
                                                  ? AppColors.lightPrimary
                                                  : AppColors.lightHeader)
                                            : (isDark
                                                  ? AppColors.darkText
                                                  : AppColors.lightText),
                                      ),
                                      if (item.badgeCount != null &&
                                          item.badgeCount! > 0)
                                        Positioned(
                                          right: -6,
                                          top: -6,
                                          child: NotificationBadge(
                                            count: item.badgeCount!,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? (isDark
                                              ? AppColors.lightPrimary
                                              : AppColors.lightHeader)
                                        : (isDark
                                              ? AppColors.darkText
                                              : AppColors.lightText),
                                  ),
                                  child: Text(item.label),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
