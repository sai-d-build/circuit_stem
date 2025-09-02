import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/state/hud_state.dart';
import 'package:sparkcircuit/presentation/ui_components/glass_panel.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

class ProgressHud extends ConsumerWidget {
  final String levelId;

  const ProgressHud({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final hudState = ref.watch(hudStateProvider(levelId));
    final progress = hudState.progress;
    
    return GlassPanel(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: UIConstants.progressHudHorizontalPadding,
          vertical: UIConstants.progressHudVerticalPadding,
        ),
        child: Row(
          children: [
            _buildStarsIndicator(theme, circuitColors, progress),
            SizedBox(width: UIConstants.progressHudSpacing),
            _buildScoreDisplay(theme, circuitColors, progress),
            const Spacer(),
            _buildTimeDisplay(theme, circuitColors, progress),
            SizedBox(width: UIConstants.progressHudSpacing),
            _buildHintsDisplay(theme, circuitColors, progress),
          ],
        ),
      ),
    );
  }

  Widget _buildStarsIndicator(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    ProgressData progress,
  ) {
    return Row(
      children: List.generate(progress.totalStars, (index) {
        final isEarned = index < progress.starsEarned;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            isEarned ? Icons.star : Icons.star_outline,
            color: isEarned
                ? circuitColors.highlightAccent // Use neon highlight for earned stars
                : circuitColors.onSurface.withOpacity(0.3),
            size: 20,
          ),
        );
      }),
    );
  }

  Widget _buildScoreDisplay(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    ProgressData progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Score',
          style: theme.textTheme.bodySmall?.copyWith(
            color: circuitColors.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          '${progress.currentScore}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: circuitColors.onSurface,
            fontWeight: FontWeight.w600,
            shadows: [
              BoxShadow(
                color: circuitColors.neonPrimary.withOpacity(0.3),
                blurRadius: 5.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDisplay(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    ProgressData progress,
  ) {
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 16,
          color: circuitColors.onSurface.withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          progress.formattedTime,
          style: theme.textTheme.titleSmall?.copyWith(
            color: circuitColors.onSurface,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: [
              BoxShadow(
                color: circuitColors.neonPrimary.withOpacity(0.3),
                blurRadius: 5.0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHintsDisplay(
    ThemeData theme,
    CircuitColorScheme circuitColors,
    ProgressData progress,
  ) {
    final hintsColor = progress.hintsUsed == 0
        ? circuitColors.energyPulse // Green for full hints
        : progress.hintsUsed < progress.totalHints
            ? circuitColors.neonAccent // Magenta for some hints used
            : circuitColors.errorGlow; // Red for no hints left

    return Row(
      children: [
        Icon(
          Icons.lightbulb_outline,
          size: 16,
          color: hintsColor,
        ),
        const SizedBox(width: 4),
        Text(
          '${progress.totalHints - progress.hintsUsed}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: hintsColor,
            fontWeight: FontWeight.w600,
            shadows: [
              BoxShadow(
                color: hintsColor.withOpacity(0.5),
                blurRadius: 5.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}