import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/widgets/custom_app_bar.widget.dart';
import 'package:med_track_v2/widgets/stats_card.widget.dart';

class SliverDashboardAppBar extends StatelessWidget {
  final String greeting;
  final String userName;
  final List<StatItem> stats;
  final bool hasNotification;
  final VoidCallback? onNotificationTap;

  const SliverDashboardAppBar({
    super.key,
    required this.greeting,
    required this.userName,
    required this.stats,
    this.hasNotification = false,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: isDark ? AppColors.darkBg : Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        titlePadding: EdgeInsets.zero,
        centerTitle: false,
        background: ExpandableAppBarContent(
          greeting: greeting,
          userName: userName,
          stats: stats,
        ),
        title: CollapsedAppBarTitle(greeting: greeting, userName: userName),
      ),

      actions: [
        NotificationButton(
          hasNotification: hasNotification,
          onTap: onNotificationTap,
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class ExpandableAppBarContent extends StatelessWidget {
  final String greeting;
  final String userName;
  final List<StatItem> stats;

  const ExpandableAppBarContent({
    super.key,
    required this.greeting,
    required this.userName,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildUserSection(theme, isDark),
              const SizedBox(height: 24),
              Expanded(child: _buildStatsSection()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection(ThemeData theme, bool isDark) {
    return Row(
      children: [
        UserAvatar(userName: userName),

        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: (isDark ? AppColors.darkText : AppColors.lightText)
                      .withValues(alpha: 0.8),
                ),
              ),

              Text(userName, style: theme.textTheme.headlineLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [CompactStatsGrid(stats: stats, shouldAnimate: false)],
    );
  }
}

class CompactStatsGrid extends StatelessWidget {
  final List<StatItem> stats;
  final bool shouldAnimate;

  const CompactStatsGrid({
    super.key,
    required this.stats,
    required this.shouldAnimate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CompactStatCard(stat: stat, shouldAnimate: true),
          ),
        );
      }).toList(),
    );
  }
}

class CompactStatCard extends StatefulWidget {
  final StatItem stat;
  final bool shouldAnimate;

  const CompactStatCard({
    super.key,
    required this.stat,
    required this.shouldAnimate,
  });

  @override
  State<CompactStatCard> createState() => _CompactStatCardState();
}

class _CompactStatCardState extends State<CompactStatCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSecondary : Colors.white).withValues(
          alpha: 0.3,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.stat.icon, color: widget.stat.color, size: 28),
          const SizedBox(height: 8),
          AnimatedCompactStatValue(value: widget.stat.value),
          const SizedBox(height: 2),
          Text(
            widget.stat.label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: (isDark ? AppColors.darkText : AppColors.lightText)
                  .withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class AnimatedCompactStatValue extends StatelessWidget {
  final String value;

  const AnimatedCompactStatValue({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      value,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.lightHeader,
      ),
    );
  }
}

class CollapsedAppBarTitle extends StatelessWidget {
  final String greeting;
  final String userName;

  const CollapsedAppBarTitle({
    super.key,
    required this.greeting,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
          Text(
            userName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
