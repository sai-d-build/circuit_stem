import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkcircuit/presentation/core/animations/glow_effect.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/core/utils/feedback_utils.dart';
import 'package:sparkcircuit/presentation/core/widgets/menu_button.dart';
import 'package:sparkcircuit/presentation/state/hud_state.dart';

// ✅ CLEAN ARCHITECTURE: Reuse HudService from pause_menu.dart
class HudService {
  final dynamic hudNotifier;

  HudService(this.hudNotifier);

  void hideOverlay() {
    hudNotifier.hideOverlay();
  }
}

final hudServiceProvider = Provider.family<HudService, String>((ref, levelId) {
  final hudNotifier = ref.watch(hudStateProvider(levelId).notifier);
  return HudService(hudNotifier);
});

class WinScreen extends ConsumerStatefulWidget {
  final String levelId;

  const WinScreen({super.key, required this.levelId});

  @override
  ConsumerState<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends ConsumerState<WinScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _starsController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _starsAnimation;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _starsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _starsController,
      curve: Curves.bounceOut,
    ));

    // Start animations
    _celebrationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _starsController.forward();
    });

    // Play success sound
    _playSuccessSound();
  }

  void _playSuccessSound() {
    FeedbackUtils.provideSoundFeedback(ref, SoundType.success);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final hudState = ref.watch(hudStateProvider(widget.levelId));
    final progress = hudState.progress;
    final hudService = ref.watch(hudServiceProvider(widget.levelId));

    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 380,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  circuitColors.primary.withValues(alpha: 0.1),
                  circuitColors.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: circuitColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: circuitColors.shadow.withValues(alpha: 0.3),
                  offset: const Offset(0, 12),
                  blurRadius: 32,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GlowEffect(
                  glowColor: Colors.amber,
                  glowRadius: 20,
                  child: Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Level Complete!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: circuitColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Excellent work on your circuit!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: circuitColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildStarsDisplay(theme, circuitColors, progress),
                const SizedBox(height: 24),
                _buildStatsGrid(theme, circuitColors, progress),
                const SizedBox(height: 32),
                _buildActionButtons(context, hudService),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStarsDisplay(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    ProgressData progress,
  ) {
    return AnimatedBuilder(
      animation: _starsAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final starValue = (_starsAnimation.value - delay).clamp(0.0, 1.0);
            final isEarned = index < progress.starsEarned;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Transform.scale(
                scale: starValue,
                child: GlowEffect(
                  glowColor: Colors.amber,
                  glowRadius: 12,
                  isGlowing: isEarned,
                  child: Icon(
                    isEarned ? Icons.star : Icons.star_outline,
                    size: 48,
                    color: isEarned ? Colors.amber : circuitColors.outline,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStatsGrid(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    ProgressData progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: circuitColors.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Score',
                  '${progress.currentScore}',
                  Icons.emoji_events_outlined,
                  theme,
                  circuitColors,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: circuitColors.outline.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Time',
                  progress.formattedTime,
                  Icons.timer_outlined,
                  theme,
                  circuitColors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: circuitColors.outline.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Hints Used',
                  '${progress.hintsUsed}',
                  Icons.lightbulb_outline,
                  theme,
                  circuitColors,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: circuitColors.outline.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Best Score',
                  '${progress.bestScore}',
                  Icons.military_tech_outlined,
                  theme,
                  circuitColors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
    CircuitColorScheme circuitColors,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: circuitColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: circuitColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: circuitColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, HudService hudService) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MenuButton(
                text: 'Next Level',
                icon: Icons.arrow_forward,
                isPrimary: true,
                onPressed: () {
                  final nextLevelId =
                      (int.parse(widget.levelId) + 1).toString();
                  context.go('/game/$nextLevelId');
                },
              ),
            ),
            const SizedBox(width: 12),
            MenuButton(
              text: 'Replay',
              icon: Icons.replay,
              onPressed: () {
                hudService.hideOverlay();
                // Reset level logic would go here
              },
              width: 100,
            ),
          ],
        ),
        const SizedBox(height: 12),
        MenuButton(
          text: 'Level Select',
          icon: Icons.list,
          onPressed: () => context.go('/level-select'),
        ),
      ],
    );
  }
}
