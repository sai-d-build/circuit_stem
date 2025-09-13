import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/unified_providers.dart';
import 'package:sparkcircuit/application/transaction.dart';
import 'package:sparkcircuit/application/use_cases/create_component_use_case.dart';
import 'package:sparkcircuit/application/use_cases/notifier_integrated_use_case.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';

enum ComponentAction {
  place,
  delete,
  rotate,
  move,
  copy,
}

class ComponentActionResult {
  final bool success;
  final String? errorMessage;
  final ComponentModel? affectedComponent;

  const ComponentActionResult({
    required this.success,
    this.errorMessage,
    this.affectedComponent,
  });

  factory ComponentActionResult.success(ComponentModel? component) {
    return ComponentActionResult(
      success: true,
      affectedComponent: component,
    );
  }

  factory ComponentActionResult.failure(String error) {
    return ComponentActionResult(
      success: false,
      errorMessage: error,
    );
  }
}

final componentActionServiceProvider =
    Provider.family<ComponentActionService, String>(
  (ref, levelId) {
    MigrationTracker.markFileMigrated(
        'component_action_service.dart', DateTime.now().toIso8601String());
    return ComponentActionService(
      gameNotifier: ref.read(unifiedGameStateProvider.notifier),
      gameState: ref.read(unifiedGameStateProvider),
      levelId: levelId,
    );
  },
);

class ComponentActionService {
  final dynamic
      gameNotifier; // 🔧 INJECTED: No longer accessing provider directly
  final dynamic gameState; // 🔧 INJECTED: Passed at construction time
  final String levelId;

  ComponentActionService({
    required this.gameNotifier,
    required this.gameState,
    required this.levelId,
  });

  Future<ComponentActionResult> executeAction(
    ComponentAction action,
    ComponentModel component,
    GridPosition? targetPosition,
  ) async {
    try {
      // 🔧 DECOUPLED: Using injected gameNotifier instead of ref.read()
      final gameNotifier = this.gameNotifier;

      switch (action) {
        case ComponentAction.place:
          if (targetPosition == null) {
            return ComponentActionResult.failure(
                'Target position required for placement');
          }
          // Use centralized CreateComponentUseCase instead of direct notifier call
          final transaction = GameTransaction();
          final result = await CreateComponentUseCase.placeComponent(
            component.type,
            targetPosition.row,
            targetPosition.col,
            _createMinimalNotifierContext(gameNotifier),
            transaction,
          );

          if (result.isSuccess) {
            await transaction.commit();
            return ComponentActionResult.success(component);
          } else {
            transaction.rollback();
            return ComponentActionResult.failure(
                result.error ?? 'Failed to place component');
          }

        case ComponentAction.delete:
          // TODO: Implement delete functionality in game engine
          return ComponentActionResult.failure(
              'Delete action not yet implemented');

        case ComponentAction.rotate:
          // TODO: Implement rotation functionality
          return ComponentActionResult.failure(
              'Rotate action not yet implemented');

        case ComponentAction.move:
          if (targetPosition == null) {
            return ComponentActionResult.failure(
                'Target position required for move');
          }
          // TODO: Implement move functionality
          return ComponentActionResult.failure(
              'Move action not yet implemented');

        case ComponentAction.copy:
          if (targetPosition == null) {
            return ComponentActionResult.failure(
                'Target position required for copy');
          }
          // TODO: Implement copy functionality
          return ComponentActionResult.failure(
              'Copy action not yet implemented');
      }
    } catch (e) {
      return ComponentActionResult.failure('Action failed: $e');
    }
  }

  Future<ComponentActionResult> placeComponent(
      ComponentType type, GridPosition position) async {
    try {
      // 🔧 DECOUPLED: Using injected gameNotifier instead of ref.read()
      final gameNotifier = this.gameNotifier;

      // Use the centralized CreateComponentUseCase static method
      final transaction = GameTransaction();
      final result = await CreateComponentUseCase.placeComponent(
        type,
        position.row,
        position.col,
        _createMinimalNotifierContext(gameNotifier),
        transaction,
      );

      if (result.isSuccess) {
        await transaction.commit();

        // Create a component model for the result
        final component = ComponentModel(
          id: 'placed_${position.row}_${position.col}',
          type: type,
          row: position.row,
          col: position.col,
        );

        return ComponentActionResult.success(component);
      } else {
        transaction.rollback();
        return ComponentActionResult.failure(
            result.error ?? 'Failed to place component');
      }
    } catch (e) {
      return ComponentActionResult.failure('Failed to place component: $e');
    }
  }

  /// Create minimal NotifierContext with just the grid notifier
  NotifierContext _createMinimalNotifierContext(dynamic gameNotifier) {
    return NotifierContext(
      grid: gameNotifier,
      history: null,
      progress: null,
      selection: null,
      interaction: null,
      paletteManager: null,
    );
  }

  Future<ComponentActionResult> validateAction(
    ComponentAction action,
    ComponentModel component,
    GridPosition? targetPosition,
  ) async {
    // Basic validation logic
    switch (action) {
      case ComponentAction.place:
        if (targetPosition == null) {
          return ComponentActionResult.failure('Target position required');
        }
        // Check if position is occupied
        // 🔧 DECOUPLED: Using injected gameState instead of ref.read()
        final gameState = this.gameState;
        final occupied = gameState.grid.components.values.any(
            (c) => c.row == targetPosition.row && c.col == targetPosition.col);
        if (occupied) {
          return ComponentActionResult.failure('Position is already occupied');
        }
        break;

      default:
        // Other actions don't have specific validation yet
        break;
    }

    return ComponentActionResult.success(null);
  }
}
