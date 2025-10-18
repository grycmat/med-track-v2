import 'package:flutter/material.dart';
import 'package:med_track_v2/models/fab_action.dart';

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
                          color: Colors.black.withValues(alpha: 0.1),
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
                          color: Colors.black.withValues(alpha: 0.1),
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
