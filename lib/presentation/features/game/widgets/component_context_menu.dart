import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../application/game_engine/v3/providers_v3.dart';
import '../../../core/theme/app_theme.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

class ComponentContextMenu extends StatelessWidget {
  final String componentId;
  final Offset position;
  final VoidCallback onDismiss;

  const ComponentContextMenu({
    super.key,
    required this.componentId,
    required this.position,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(8.0),
        color: circuitColors.surface,
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: circuitColors.outline.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                context,
                'Rotate',
                Icons.rotate_right,
                circuitColors,
                () => _handleRotate(context),
              ),
              Divider(height: 1, color: circuitColors.outline.withValues(alpha: 0.3)),
              _buildMenuItem(
                context,
                'Delete',
                Icons.delete,
                circuitColors,
                () => _handleDelete(context),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String label,
    IconData icon,
    CircuitColorScheme colors,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: () {
        onTap();
        onDismiss();
      },
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDestructive ? colors.error : colors.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDestructive ? colors.error : colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRotate(BuildContext context) {
    final ref = ProviderScope.containerOf(context, listen: false);
    ref.read(enhancedGameStateNotifierProvider.notifier).rotateComponent(componentId);
    StructuredLogger.info('Component rotated via context menu', context: {
      'componentId': componentId,
      'action': 'rotate_component',
    });
  }

  void _handleDelete(BuildContext context) {
    final ref = ProviderScope.containerOf(context, listen: false);
    ref.read(enhancedGameStateNotifierProvider.notifier).removeComponent(componentId);
    StructuredLogger.info('Component deleted via context menu', context: {
      'componentId': componentId,
      'action': 'delete_component',
    });
  }
}
