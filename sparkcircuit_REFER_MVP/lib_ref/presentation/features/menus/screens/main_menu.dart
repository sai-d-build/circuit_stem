import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/core/widgets/menu_button.dart';
import 'package:sparkcircuit/presentation/core/widgets/responsive_scaffold.dart';
import 'package:sparkcircuit/presentation/core/animations/glow_effect.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late AnimationController _buttonsAnimationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _buttonsStaggerAnimation;

  @override
  void initState() {
    super.initState();
    
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _buttonsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));
    
    _buttonsStaggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonsAnimationController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animations
    _titleAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _buttonsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _buttonsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    
    return ResponsiveScaffold(
      backgroundColor: circuitColors.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              circuitColors.primary.withValues(alpha: 0.1),
              circuitColors.surface,
              circuitColors.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildTitle(theme, circuitColors),
                const Spacer(flex: 1),
                _buildMenuButtons(theme, circuitColors),
                const Spacer(flex: 2),
                _buildFooter(theme, circuitColors),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, CircuitColorScheme circuitColors) {
    return AnimatedBuilder(
      animation: _titleAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _titleFadeAnimation,
          child: SlideTransition(
            position: _titleSlideAnimation,
            child: Column(
              children: [
                GlowEffect(
                  glowColor: circuitColors.glowEffect,
                  glowRadius: 20,
                  child: Icon(
                    Icons.developer_board,
                    size: 80,
                    color: circuitColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Circuit STEM',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: circuitColors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Build, Learn, Discover',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: circuitColors.onSurfaceVariant,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButtons(ThemeData theme, CircuitColorScheme circuitColors) {
    final buttons = [
      _MenuButtonData(
        text: 'Start Learning',
        icon: Icons.play_arrow,
        onPressed: () => context.go('/level-select'),
        isPrimary: true,
        delay: 0,
      ),
      _MenuButtonData(
        text: 'Continue',
        icon: Icons.refresh,
        onPressed: () => context.go('/game/1'), // Last played level
        isPrimary: false,
        delay: 100,
      ),
      _MenuButtonData(
        text: 'Tutorial',
        icon: Icons.school,
        onPressed: () => context.go('/onboarding'),
        isPrimary: false,
        delay: 200,
      ),
      _MenuButtonData(
        text: 'Settings',
        icon: Icons.settings,
        onPressed: () => context.go('/settings'),
        isPrimary: false,
        delay: 300,
      ),
    ];

    return AnimatedBuilder(
      animation: _buttonsStaggerAnimation,
      builder: (context, child) {
        return Column(
          children: buttons.map((buttonData) {
            return _buildAnimatedButton(
              buttonData,
              _buttonsStaggerAnimation.value,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAnimatedButton(_MenuButtonData buttonData, double animationValue) {
    final delayedValue = ((animationValue * 1000) - buttonData.delay).clamp(0.0, 300.0) / 300.0;
    final opacity = delayedValue.clamp(0.0, 1.0);
    final offset = (1.0 - delayedValue) * 50.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Transform.translate(
        offset: Offset(0, offset),
        child: Opacity(
          opacity: opacity,
          child: MenuButton(
            text: buttonData.text,
            icon: buttonData.icon,
            onPressed: buttonData.onPressed,
            isPrimary: buttonData.isPrimary,
            width: 280,
            height: 56,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, CircuitColorScheme circuitColors) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFooterButton(
              icon: Icons.help_outline,
              onTap: () {
                // Show help dialog
                _showHelpDialog();
              },
              theme: theme,
              circuitColors: circuitColors,
            ),
            const SizedBox(width: 24),
            _buildFooterButton(
              icon: Icons.info_outline,
              onTap: () {
                // Show about dialog
                _showAboutDialog();
              },
              theme: theme,
              circuitColors: circuitColors,
            ),
            const SizedBox(width: 24),
            _buildFooterButton(
              icon: Icons.share,
              onTap: () {
                // Share app
                _shareApp();
              },
              theme: theme,
              circuitColors: circuitColors,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Version 1.0.0',
          style: theme.textTheme.bodySmall?.copyWith(
            color: circuitColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required VoidCallback onTap,
    required ThemeData theme,
    required CircuitColorScheme circuitColors,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: circuitColors.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            color: circuitColors.onSurface.withValues(alpha: 0.7),
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: const Text(
          'Circuit STEM is an interactive electronics learning game.\n\n'
          '• Drag components from the palette to the grid\n'
          '• Connect them with wires to create circuits\n'
          '• Test your circuits and see electricity flow\n'
          '• Complete objectives to earn stars and unlock new levels',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Circuit STEM'),
        content: const Text(
          'Circuit STEM is an educational app designed to make learning electronics fun and interactive.\n\n'
          'Perfect for students, educators, and anyone curious about how circuits work.\n\n'
          'Built with Flutter and powered by a physics simulation engine.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    // Implementation for sharing the app
    // In a real app, this would use the share package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would be implemented here'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _MenuButtonData {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final int delay;

  const _MenuButtonData({
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.isPrimary,
    required this.delay,
  });
}