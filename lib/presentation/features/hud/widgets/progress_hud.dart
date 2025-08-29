import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/state/hud_state.dart';

class ProgressHud extends ConsumerWidget {
  final String levelId;

  const ProgressHud({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final hudState = ref.watch(hudStateProvider(levelId));
    final progress = hudState.progress;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: circuitColors.surfaceContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: circuitColors.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _buildStarsIndicator(theme, circuitColors, progress),
          const SizedBox(width: 16),
          _buildScoreDisplay(theme, circuitColors, progress),
          const Spacer(),
          _buildTimeDisplay(theme, circuitColors, progress),
          const SizedBox(width: 16),
          _buildHintsDisplay(theme, circuitColors, progress),
        ],
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
                ? Colors.amber
                : circuitColors.onSurface.withValues(alpha: 0.3),
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
            color: circuitColors.onSurfaceVariant,
          ),
        ),
        Text(
          '${progress.currentScore}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: circuitColors.onSurface,
            fontWeight: FontWeight.w600,
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
          color: circuitColors.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          progress.formattedTime,
          style: theme.textTheme.titleSmall?.copyWith(
            color: circuitColors.onSurface,
            fontWeight: FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
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
        ? circuitColors.secondary
        : progress.hintsUsed < progress.totalHints
            ? circuitColors.tertiary
            : circuitColors.error;

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
          ),
        ),
      ],
    );
  }
}