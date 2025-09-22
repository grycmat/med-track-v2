import 'package:flutter/material.dart';
import 'package:med_track_v2/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String greeting;
  final String userName;
  final bool hasNotification;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;

  const CustomAppBar({
    super.key,
    required this.greeting,
    required this.userName,
    this.hasNotification = false,
    this.onNotificationTap,
    this.onThemeToggle,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkBg : Colors.white).withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              UserAvatar(userName: userName),
              const SizedBox(width: 12),
              Expanded(
                child: UserGreeting(greeting: greeting, userName: userName),
              ),
              if (onThemeToggle != null) ...[
                ThemeToggleButton(
                  isDarkMode: isDarkMode,
                  onTap: onThemeToggle!,
                ),
                const SizedBox(width: 8),
              ],
              NotificationButton(
                hasNotification: hasNotification,
                onTap: onNotificationTap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class UserAvatar extends StatelessWidget {
  final String userName;

  const UserAvatar({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.avatarGradient(isDark),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 20),
    );
  }
}

class UserGreeting extends StatelessWidget {
  final String greeting;
  final String userName;

  const UserGreeting({
    super.key,
    required this.greeting,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(greeting, style: theme.textTheme.bodyMedium),
        Text(userName, style: theme.textTheme.headlineLarge),
      ],
    );
  }
}

class NotificationButton extends StatelessWidget {
  final bool hasNotification;
  final VoidCallback? onTap;

  const NotificationButton({
    super.key,
    this.hasNotification = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSecondary
                : AppColors.lightSecondary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.notifications_outlined,
                  color: isDark ? Colors.white : AppColors.lightHeader,
                ),
              ),
              if (hasNotification)
                Positioned(top: 8, right: 8, child: PulsingDot()),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onTap;

  const ThemeToggleButton({
    super.key,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkPrimary
                : AppColors.lightSecondary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? Colors.white : AppColors.lightHeader,
          ),
        ),
      ),
    );
  }
}

class PulsingDot extends StatefulWidget {
  @override
  _PulsingDotState createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
