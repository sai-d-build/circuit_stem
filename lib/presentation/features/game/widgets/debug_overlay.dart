import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';

class DebugOverlay extends StatelessWidget {
  final GameCanvasController controller;
  final bool isVisible;
  final Map<String, dynamic>? gameDebugInfo;

  const DebugOverlay({
    super.key,
    required this.controller,
    this.isVisible = false,
    this.gameDebugInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final debugInfo = controller.getDebugInfo();

    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: circuitColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: circuitColors.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Info',
              style: theme.textTheme.titleSmall?.copyWith(
                color: circuitColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...debugInfo.entries.map((entry) => _buildDebugRow(
              entry.key,
              entry.value.toString(),
              theme,
              circuitColors,
            )),
            if (gameDebugInfo != null) ...[
              const Divider(),
              ...gameDebugInfo!.entries.map((entry) => _buildDebugRow(
                entry.key,
                entry.value.toString(),
                theme,
                circuitColors,
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDebugRow(
    String key,
    String value,
    ThemeData theme,
    CircuitColorScheme circuitColors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$key: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: circuitColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: circuitColors.onSurface,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}