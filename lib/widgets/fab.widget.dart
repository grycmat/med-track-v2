import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class CustomFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;

  const CustomFloatingActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.tooltip,
  });

  @override
  State<CustomFloatingActionButton> createState() =>
      _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
    _rotationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    _rotationController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
    _rotationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      bottom: 90,
      right: 20,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColors.darkGradient
                        : AppColors.lightGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary)
                                .withOpacity(0.6),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: isDark ? Colors.white : AppColors.lightHeader,
                    size: 28,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExpandableFAB extends StatefulWidget {
  final List<FABAction> actions;
  final IconData mainIcon;
  final IconData closeIcon;

  const ExpandableFAB({
    super.key,
    required this.actions,
    this.mainIcon = Icons.add,
    this.closeIcon = Icons.close,
  });

  @override
  State<ExpandableFAB> createState() => _ExpandableFABState();
}

class _ExpandableFABState extends State<ExpandableFAB>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Positioned(
      bottom: 90,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ..._buildActionButtons(),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColors.darkGradient
                        : AppColors.lightGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary)
                                .withOpacity(0.6),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggle,
                      borderRadius: BorderRadius.circular(28),
                      child: Icon(
                        _isExpanded ? widget.closeIcon : widget.mainIcon,
                        color: isDark ? Colors.white : AppColors.lightHeader,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons() {
    return widget.actions
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final action = entry.value;

          return AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              final offset = _expandAnimation.value * (index + 1) * 70.0;

              return Transform.translate(
                offset: Offset(0, -offset),
                child: Opacity(
                  opacity: _expandAnimation.value,
                  child: FABActionButton(action: action, delay: index * 50),
                ),
              );
            },
          );
        })
        .toList()
        .reversed
        .toList();
  }
}

class FABActionButton extends StatefulWidget {
  final FABAction action;
  final int delay;

  const FABActionButton({super.key, required this.action, this.delay = 0});

  @override
  State<FABActionButton> createState() => _FABActionButtonState();
}

class _FABActionButtonState extends State<FABActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(_scaleController);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.action.label != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.action.label!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                GestureDetector(
                  onTapDown: (_) => _scaleController.forward(),
                  onTapUp: (_) {
                    _scaleController.reverse();
                    widget.action.onPressed();
                  },
                  onTapCancel: () => _scaleController.reverse(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.action.backgroundColor ?? theme.cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.action.icon,
                      color:
                          widget.action.iconColor ?? theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FABAction {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;

  const FABAction({
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor,
    this.iconColor,
  });
}
