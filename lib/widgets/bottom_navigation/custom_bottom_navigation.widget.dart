import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/widgets/bottom_navigation/bottom_nav_button.widget.dart';
import 'package:med_track_v2/widgets/bottom_navigation/bottom_nav_item.dart';

class CustomBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animateCurrentSelection();
  }

  void _initializeAnimations() {
    _scaleControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _scaleAnimations = _scaleControllers
        .map(
          (controller) => Tween<double>(begin: 1.0, end: 1.2).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();
  }

  void _animateCurrentSelection() {
    if (widget.currentIndex < _scaleControllers.length) {
      _scaleControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(CustomBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _updateAnimationsForIndexChange(oldWidget.currentIndex);
    }
  }

  void _updateAnimationsForIndexChange(int previousIndex) {
    if (previousIndex < _scaleControllers.length) {
      _scaleControllers[previousIndex].reverse();
    }
    if (widget.currentIndex < _scaleControllers.length) {
      _scaleControllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  void _disposeAnimations() {
    for (final controller in _scaleControllers) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BottomAppBar(
      elevation: 0,
      height: 70,
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      child: _buildContainer(isDark),
    );
  }

  Widget _buildContainer(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: _getBackgroundColor(isDark),
        border: Border(top: _getTopBorder(isDark)),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: _buildNavigationContent(),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    return (isDark ? AppColors.darkSecondary : Colors.white).withValues(
      alpha: 0.8,
    );
  }

  BorderSide _getTopBorder(bool isDark) {
    return BorderSide(
      color: isDark
          ? AppColors.darkAccent
          : AppColors.lightSecondary.withValues(alpha: 0.3),
      width: 1,
    );
  }

  Widget _buildNavigationContent() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _buildNavigationButtons(),
      ),
    );
  }

  List<Widget> _buildNavigationButtons() {
    return widget.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = index == widget.currentIndex;

      return Expanded(child: _buildAnimatedButton(index, item, isSelected));
    }).toList();
  }

  Widget _buildAnimatedButton(int index, BottomNavItem item, bool isSelected) {
    return AnimatedBuilder(
      animation: _scaleAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimations[index].value : 1.0,
          child: BottomNavButton(
            item: item,
            isSelected: isSelected,
            onTap: () => widget.onTap(index),
          ),
        );
      },
    );
  }
}
