import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class ProgressCard extends StatefulWidget {
  final double progress;
  final int completedCount;
  final int totalCount;
  final String title;

  const ProgressCard({
    super.key,
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    this.title = "Today's Progress",
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
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

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: theme.textTheme.displaySmall),
                ProgressStats(
                  progress: widget.progress,
                  completedCount: widget.completedCount,
                  totalCount: widget.totalCount,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedProgressBar(animation: _progressAnimation),
          ],
        ),
      ),
    );
  }
}

class ProgressStats extends StatelessWidget {
  final double progress;
  final int completedCount;
  final int totalCount;

  const ProgressStats({
    super.key,
    required this.progress,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${(progress * 100).round()}%',
          style: theme.textTheme.displayMedium?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : AppColors.lightHeader,
          ),
        ),
        Text(
          '$completedCount of $totalCount taken',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  final Animation<double> animation;

  const AnimatedProgressBar({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 12,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkAccent
            : AppColors.lightSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * animation.value * 0.8,
              height: 12,
              decoration: BoxDecoration(
                gradient: isDark
                    ? AppColors.darkGradient
                    : AppColors.lightGradient,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        },
      ),
    );
  }
}
