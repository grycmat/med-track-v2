import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_track_v2/main.dart';
import 'package:med_track_v2/services/user_preferences_service.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/viewmodels/settings_viewmodel.dart';
import 'package:med_track_v2/viewmodels/user_preferences_viewmodel.dart';
import 'package:med_track_v2/widgets/gradient_button.widget.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late TextEditingController _usernameController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPreferencesService = Provider.of<UserPreferencesService>(context, listen: false);
    final themeModeProvider = ThemeModeProvider.of(context);

    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(
        userPreferencesService,
        themeModeProvider?.onThemeChanged ?? (_) {},
      )..loadSettings(),
      child: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          if (_usernameController.text.isEmpty && viewModel.username.isNotEmpty) {
            _usernameController.text = viewModel.username;
          }

          return Scaffold(
            appBar: _buildAppBar(context),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'Appearance'),
                            const SizedBox(height: 16),
                            _buildThemeSelector(context, viewModel),
                            const SizedBox(height: 32),
                            _buildSectionTitle(context, 'Profile'),
                            const SizedBox(height: 16),
                            _buildUsernameEditor(context, viewModel),
                            const SizedBox(height: 32),
                            _buildAboutSection(context),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'Settings',
        style: theme.textTheme.headlineMedium?.copyWith(
          color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsViewModel viewModel) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildThemeOption(
            context,
            viewModel,
            'System Default',
            'Follow device settings',
            Icons.smartphone,
            ThemeMode.system,
          ),
          Divider(
            height: 1,
            color: (isDark ? AppColors.darkText : AppColors.lightText)
                .withValues(alpha: 0.1),
          ),
          _buildThemeOption(
            context,
            viewModel,
            'Light Mode',
            'Bright and clean',
            Icons.light_mode,
            ThemeMode.light,
          ),
          Divider(
            height: 1,
            color: (isDark ? AppColors.darkText : AppColors.lightText)
                .withValues(alpha: 0.1),
          ),
          _buildThemeOption(
            context,
            viewModel,
            'Dark Mode',
            'Easy on the eyes',
            Icons.dark_mode,
            ThemeMode.dark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    SettingsViewModel viewModel,
    String title,
    String subtitle,
    IconData icon,
    ThemeMode themeMode,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = viewModel.themeMode == themeMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          viewModel.updateThemeMode(themeMode);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                    .withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                      : (isDark ? AppColors.darkAccent : AppColors.lightSecondary)
                          .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? (isDark ? Colors.white : AppColors.lightHeader)
                      : (isDark ? AppColors.darkText : AppColors.lightText),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: (isDark ? AppColors.darkText : AppColors.lightText)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameEditor(BuildContext context, SettingsViewModel viewModel) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.avatarGradient(isDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Display Name',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'This name will appear in the app',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: (isDark ? AppColors.darkText : AppColors.lightText)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _usernameController,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: TextStyle(
                color: (isDark ? AppColors.darkText : AppColors.lightText)
                    .withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: (isDark ? AppColors.darkBg : AppColors.lightBg)
                  .withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: Icon(
                Icons.edit,
                color: (isDark ? AppColors.darkText : AppColors.lightText)
                    .withValues(alpha: 0.5),
                size: 20,
              ),
            ),
            onChanged: (value) {
              viewModel.clearMessages();
            },
          ),
          if (viewModel.errorMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMessageBanner(
              context,
              viewModel.errorMessage,
              AppColors.error,
              Icons.error_outline,
            ),
          ],
          if (viewModel.successMessage.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMessageBanner(
              context,
              viewModel.successMessage,
              AppColors.success,
              Icons.check_circle_outline,
            ),
          ],
          const SizedBox(height: 20),
          GradientButton(
            text: 'Save Changes',
            onPressed: () {
              HapticFeedback.mediumImpact();
              viewModel.updateUsername(_usernameController.text);
              FocusScope.of(context).unfocus();

              final userPreferencesViewModel = Provider.of<UserPreferencesViewModel>(
                context,
                listen: false,
              );
              userPreferencesViewModel.loadUsername();
            },
            width: double.infinity,
            isLoading: viewModel.isSaving,
            icon: Icons.save,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBanner(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAboutItem(
            context,
            'App Version',
            '1.0.0',
            Icons.info_outline,
            null,
          ),
          Divider(
            height: 1,
            color: (isDark ? AppColors.darkText : AppColors.lightText)
                .withValues(alpha: 0.1),
          ),
          _buildAboutItem(
            context,
            'Privacy Policy',
            '',
            Icons.privacy_tip_outlined,
            () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Privacy Policy - Coming soon'),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            color: (isDark ? AppColors.darkText : AppColors.lightText)
                .withValues(alpha: 0.1),
          ),
          _buildAboutItem(
            context,
            'Terms of Service',
            '',
            Icons.description_outlined,
            () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Terms of Service - Coming soon'),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkAccent : AppColors.lightSecondary)
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: (isDark ? AppColors.darkText : AppColors.lightText)
                        .withValues(alpha: 0.6),
                  ),
                ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: (isDark ? AppColors.darkText : AppColors.lightText)
                      .withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
