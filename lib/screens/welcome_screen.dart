import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_track_v2/theme/app_colors.dart';
import 'package:med_track_v2/viewmodels/welcome_viewmodel.dart';
import 'package:med_track_v2/widgets/gradient_button.widget.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const WelcomeScreen({super.key, required this.onComplete});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late AnimationController _contentAnimationController;

  late Animation<double> _iconScaleAnimation;
  late Animation<Offset> _iconSlideAnimation;
  late Animation<double> _iconFadeAnimation;

  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;

  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;

  late Animation<double> _inputFadeAnimation;
  late Animation<Offset> _inputSlideAnimation;

  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  final TextEditingController _usernameController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _iconSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.2),
    ).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _inputFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _inputSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _iconAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _contentAnimationController.dispose();
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleGetStarted() async {
    HapticFeedback.mediumImpact();

    final viewModel = context.read<WelcomeViewModel>();
    final success = await viewModel.saveUsername();

    if (success && mounted) {
      await HapticFeedback.heavyImpact();
      widget.onComplete();
    } else if (!success && mounted) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            height: screenHeight - MediaQuery.of(context).padding.top,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedIcon(isDark),
                        const SizedBox(height: 80),
                        _buildContent(isDark),
                      ],
                    ),
                  ),
                  _buildBottomButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(bool isDark) {
    return AnimatedBuilder(
      animation: _iconAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _iconFadeAnimation,
          child: SlideTransition(
            position: _iconSlideAnimation,
            child: ScaleTransition(
              scale: _iconScaleAnimation,
              child: _buildGradientIconContainer(isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGradientIconContainer(bool isDark) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkGradient : AppColors.lightGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                .withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        Icons.medication_rounded,
        size: 80,
        color: isDark ? Colors.white : AppColors.lightHeader,
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      children: [
        _buildAnimatedTitle(isDark),
        const SizedBox(height: 16),
        _buildAnimatedSubtitle(isDark),
        const SizedBox(height: 48),
        _buildAnimatedInput(isDark),
      ],
    );
  }

  Widget _buildAnimatedTitle(bool isDark) {
    return FadeTransition(
      opacity: _titleFadeAnimation,
      child: SlideTransition(
        position: _titleSlideAnimation,
        child: Text(
          'Welcome to MedTrack',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle(bool isDark) {
    return FadeTransition(
      opacity: _subtitleFadeAnimation,
      child: SlideTransition(
        position: _subtitleSlideAnimation,
        child: Text(
          'Your personal medication companion.\nNever miss a dose again.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppColors.darkText : AppColors.lightText,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedInput(bool isDark) {
    return FadeTransition(
      opacity: _inputFadeAnimation,
      child: SlideTransition(
        position: _inputSlideAnimation,
        child: Consumer<WelcomeViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkAccent.withOpacity(0.3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: viewModel.errorMessage.isNotEmpty
                          ? AppColors.error
                          : (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary)
                              .withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary)
                            .withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _usernameController,
                    focusNode: _usernameFocusNode,
                    onChanged: viewModel.setUsername,
                    onSubmitted: (_) => _handleGetStarted(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkHeader : AppColors.lightHeader,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(
                        color: (isDark ? AppColors.darkText : AppColors.lightText)
                            .withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                    ),
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                ),
                if (viewModel.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      viewModel.errorMessage,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return FadeTransition(
      opacity: _buttonFadeAnimation,
      child: SlideTransition(
        position: _buttonSlideAnimation,
        child: Consumer<WelcomeViewModel>(
          builder: (context, viewModel, child) {
            return GradientButton(
              text: 'Get Started',
              onPressed: viewModel.isValidUsername ? _handleGetStarted : null,
              width: double.infinity,
              height: 60,
              isLoading: viewModel.isSaving,
              trailingIcon: Icons.arrow_forward_rounded,
            );
          },
        ),
      ),
    );
  }
}
