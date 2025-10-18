import 'package:flutter/material.dart';

class BottomNavItem {
  final IconData icon;
  final String label;
  final int? badgeCount;
  final Color? activeColor;

  const BottomNavItem({
    required this.icon,
    required this.label,
    this.badgeCount,
    this.activeColor,
  });
}
