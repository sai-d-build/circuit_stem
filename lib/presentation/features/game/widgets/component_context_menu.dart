import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/use_cases/component_interaction_use_case.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';

import '../../../core/theme/app_theme.dart';

// ✅ CLEAN ARCHITECTURE: Component Interaction Service (reused from circuit_component_widget.dart)
class ComponentInteractionService {
  final ComponentInteractionUseCase _useCase;

  ComponentInteractionService(this._useCase);

  void handleRotation(String componentId) {
    _useCase.handleComponentRotation(componentId);
  }

  void handleDeletion(String componentId) {
    _useCase.handleComponentDeletion(componentId);
  }
}

final componentInteractionServiceProvider =
    Provider.family<ComponentInteractionService, String>((ref, levelId) {
  final useCase = ref.watch(componentInteractionUseCaseProvider(levelId));
  return ComponentInteractionService(useCase);
});

class ComponentContextMenu extends ConsumerWidget {
  final String componentId;
  final Offset position;
  final VoidCallback onDismiss;
  final String levelId; // Add levelId parameter

  const ComponentContextMenu({
    super.key,
    required this.componentId,
    required this.position,
    required this.onDismiss,
    required this.levelId, // Require levelId
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MigrationTracker.markFileMigrated(
        'component_context_menu.dart', DateTime.now().toIso8601String());
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final interactionService =
        ref.watch(componentInteractionServiceProvider(levelId));

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: circuitColors.surface,
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: circuitColors.outline.withValues(alpha: 0.3),
              width: 1,
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
                () => _handleRotate(context, interactionService),
              ),
              Divider(
                  height: 1,
                  color: circuitColors.outline.withValues(alpha: 0.3)),
              _buildMenuItem(
                context,
                'Delete',
                Icons.delete,
                circuitColors,
                () => _handleDelete(context, interactionService),
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
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  void _handleRotate(
      BuildContext context, ComponentInteractionService interactionService) {
    interactionService.handleRotation(componentId);
    StructuredLogger.info('Component rotated via context menu', context: {
      'componentId': componentId,
      'action': 'rotate_component',
    });
  }

  void _handleDelete(
      BuildContext context, ComponentInteractionService interactionService) {
    interactionService.handleDeletion(componentId);
    StructuredLogger.info('Component deleted via context menu', context: {
      'componentId': componentId,
      'action': 'delete_component',
    });
  }
}
