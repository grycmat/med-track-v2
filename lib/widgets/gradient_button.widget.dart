import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final Gradient? gradient;
  final bool isLoading;
  final Color? shadowColor;
  final double elevation;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.width,
    this.height = 56,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.gradient,
    this.isLoading = false,
    this.shadowColor,
    this.elevation = 8,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

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

    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation * 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse().then((_) {
        widget.onPressed!();
      });
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradient =
        widget.gradient ??
        (isDark ? AppColors.darkGradient : AppColors.lightGradient);

    final shadowColor =
        widget.shadowColor ??
        (isDark ? AppColors.darkPrimary : AppColors.lightPrimary);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.onPressed == null || widget.isLoading
                    ? _getDisabledGradient(isDark)
                    : gradient,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.4),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed != null && !widget.isLoading
                      ? () {}
                      : null,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(28),
                  child: Container(
                    padding:
                        widget.padding ??
                        const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                    child: widget.isLoading
                        ? _buildLoadingContent(isDark)
                        : _buildButtonContent(isDark),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(bool isDark) {
    final textColor = isDark ? Colors.white : AppColors.lightHeader;
    final style =
        widget.textStyle ??
        TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: textColor, size: 20),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()
              ..translate(_controller.value * 4, 0.0),
            child: Icon(widget.trailingIcon, color: textColor, size: 20),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingContent(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? Colors.white : AppColors.lightHeader,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading...',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightHeader,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Gradient _getDisabledGradient(bool isDark) {
    if (isDark) {
      return LinearGradient(
        colors: [
          AppColors.darkSecondary.withOpacity(0.6),
          AppColors.darkAccent.withOpacity(0.6),
        ],
      );
    }
    return LinearGradient(
      colors: [
        AppColors.lightSecondary.withOpacity(0.6),
        AppColors.lightAccent.withOpacity(0.6),
      ],
    );
  }
}

class PillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;

  const PillButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? (selectedColor ??
                    (isDark ? AppColors.darkPrimary : AppColors.lightPrimary))
              : (unselectedColor ?? theme.cardColor),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        (selectedColor ??
                                (isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary))
                            .withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.lightHeader)
                          : (isDark ? AppColors.darkText : AppColors.lightText),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.lightHeader)
                          : (isDark ? AppColors.darkText : AppColors.lightText),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OutlineButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double borderWidth;

  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.borderColor,
    this.textColor,
    this.borderWidth = 1.5,
  });

  @override
  State<OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<OutlineButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        widget.borderColor ??
        (isDark ? AppColors.darkPrimary : AppColors.lightPrimary);
    final textColor = widget.textColor ?? borderColor;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onPressed?.call();
            },
            onTapCancel: () => _controller.reverse(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: borderColor,
                  width: widget.borderWidth,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: textColor),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
