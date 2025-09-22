import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class StatsGrid extends StatelessWidget {
  final List<StatItem> stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return StatsCard(stat: stats[index]);
      },
    );
  }
}

class StatsCard extends StatefulWidget {
  final StatItem stat;

  const StatsCard({super.key, required this.stat});

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.stat.animationDelay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatIcon(icon: widget.stat.icon, color: widget.stat.color),
                    const SizedBox(height: 12),
                    AnimatedStatValue(
                      value: widget.stat.value,
                      animation: _controller,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.stat.label,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StatIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const StatIcon({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class AnimatedStatValue extends StatelessWidget {
  final String value;
  final Animation<double> animation;

  const AnimatedStatValue({
    super.key,
    required this.value,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final numericValue = _extractNumericValue(value);
        final displayValue = numericValue != null
            ? _formatAnimatedValue(numericValue * animation.value)
            : value;

        return Text(
          displayValue,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: isDark ? Colors.white : AppColors.lightHeader,
            fontSize: 18,
          ),
        );
      },
    );
  }

  double? _extractNumericValue(String value) {
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(value);
    if (match != null) {
      return double.tryParse(match.group(0)!);
    }
    return null;
  }

  String _formatAnimatedValue(double animatedValue) {
    if (value.contains('%')) {
      return '${animatedValue.round()}%';
    }
    return animatedValue.round().toString();
  }
}

class StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final int animationDelay;

  const StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.animationDelay = 0,
  });
}

class QuickStatsSection extends StatelessWidget {
  final String title;
  final List<StatItem> stats;

  const QuickStatsSection({
    super.key,
    this.title = 'Quick Stats',
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.displaySmall),
        const SizedBox(height: 16),
        StatsGrid(stats: stats),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.textTheme.displaySmall),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText!,
              style: TextStyle(
                color: isDark ? AppColors.darkPrimary : AppColors.lightAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
