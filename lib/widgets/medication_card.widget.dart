import 'package:flutter/material.dart';
import 'package:med_track_v2/models/medication.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class MedicationCard extends StatefulWidget {
  final String name;
  final String dosage;
  final String time;
  final MedicationStatus status;
  final String? dueInfo;
  final VoidCallback? onTakeNow;
  final IconData? customIcon;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.time,
    required this.status,
    this.dueInfo,
    this.onTakeNow,
    this.customIcon,
  });

  @override
  State<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: _getBorder(),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    MedicationIcon(
                      status: widget.status,
                      customIcon: widget.customIcon,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MedicationDetails(
                        name: widget.name,
                        dosage: widget.dosage,
                        dueInfo: widget.dueInfo,
                        status: widget.status,
                      ),
                    ),
                    if (widget.status == MedicationStatus.takeNow &&
                        widget.onTakeNow != null)
                      TakeNowButton(onPressed: widget.onTakeNow!)
                    else
                      TimeDisplay(time: widget.time, status: widget.status),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Border? _getBorder() {
    switch (widget.status) {
      case MedicationStatus.takeNow:
        return const Border(
          left: BorderSide(color: AppColors.warning, width: 4),
        );
      case MedicationStatus.missed:
        return const Border(left: BorderSide(color: AppColors.error, width: 4));
      default:
        return null;
    }
  }
}

class MedicationIcon extends StatelessWidget {
  final MedicationStatus status;
  final IconData? customIcon;

  const MedicationIcon({super.key, required this.status, this.customIcon});

  @override
  Widget build(BuildContext context) {
    final config = _getIconConfig();

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(customIcon ?? config.icon, color: config.iconColor, size: 24),
    );
  }

  _IconConfig _getIconConfig() {
    switch (status) {
      case MedicationStatus.taken:
        return _IconConfig(
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
        );
      case MedicationStatus.takeNow:
      case MedicationStatus.upcoming:
        return _IconConfig(
          icon: Icons.medication,
          iconColor: AppColors.warning,
          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
        );
      case MedicationStatus.missed:
        return _IconConfig(
          icon: Icons.schedule,
          iconColor: AppColors.error,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
        );
    }
  }
}

class _IconConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  _IconConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}

class MedicationDetails extends StatelessWidget {
  final String name;
  final String dosage;
  final String? dueInfo;
  final MedicationStatus status;

  const MedicationDetails({
    super.key,
    required this.name,
    required this.dosage,
    this.dueInfo,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name, style: theme.textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text(dosage, style: theme.textTheme.bodyMedium),
        if (dueInfo != null) ...[
          const SizedBox(height: 4),
          Text(
            dueInfo!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: _getInfoColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Color _getInfoColor() {
    switch (status) {
      case MedicationStatus.taken:
        return AppColors.success;
      case MedicationStatus.takeNow:
      case MedicationStatus.upcoming:
        return AppColors.warning;
      case MedicationStatus.missed:
        return AppColors.error;
    }
  }
}

class TimeDisplay extends StatelessWidget {
  final String time;
  final MedicationStatus status;

  const TimeDisplay({super.key, required this.time, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(time, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          _getStatusText(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: _getStatusColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    switch (status) {
      case MedicationStatus.taken:
        return 'Taken';
      case MedicationStatus.takeNow:
        return 'Due Now';
      case MedicationStatus.missed:
        return 'Missed';

      case MedicationStatus.upcoming:
        return 'Upcoming';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case MedicationStatus.taken:
        return AppColors.success;
      case MedicationStatus.takeNow:
      case MedicationStatus.upcoming:
        return AppColors.warning;
      case MedicationStatus.missed:
        return AppColors.error;
    }
  }
}

class TakeNowButton extends StatefulWidget {
  final VoidCallback onPressed;

  const TakeNowButton({super.key, required this.onPressed});

  @override
  State<TakeNowButton> createState() => _TakeNowButtonState();
}

class _TakeNowButtonState extends State<TakeNowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isTaken = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    _controller.forward().then((_) {
      _controller.reverse();
      setState(() {
        _isTaken = true;
      });
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedOpacity(
            opacity: _isTaken ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.darkGradient
                    : AppColors.lightGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary)
                            .withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isTaken ? null : _handlePress,
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isTaken ? Icons.check : Icons.check,
                          color: isDark ? Colors.white : AppColors.lightHeader,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isTaken ? 'Taken' : 'Take Now',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : AppColors.lightHeader,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
