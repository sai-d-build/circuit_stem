import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;

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

final componentActionServiceProvider = Provider.family<ComponentActionService, String>(
  (ref, levelId) => ComponentActionService(ref: ref, levelId: levelId),
);

class ComponentActionService {
  final Ref ref;
  final String levelId;

  ComponentActionService({required this.ref, required this.levelId});

  Future<ComponentActionResult> executeAction(
    ComponentAction action,
    ComponentModel component,
    GridPosition? targetPosition,
  ) async {
    try {
      final gameNotifier = ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier);

      switch (action) {
        case ComponentAction.place:
          if (targetPosition == null) {
            return ComponentActionResult.failure('Target position required for placement');
          }
          gameNotifier.placeComponent(component.type, targetPosition.row, targetPosition.col);
          return ComponentActionResult.success(component);

        case ComponentAction.delete:
          // TODO: Implement delete functionality in game engine
          return ComponentActionResult.failure('Delete action not yet implemented');

        case ComponentAction.rotate:
          // TODO: Implement rotation functionality
          return ComponentActionResult.failure('Rotate action not yet implemented');

        case ComponentAction.move:
          if (targetPosition == null) {
            return ComponentActionResult.failure('Target position required for move');
          }
          // TODO: Implement move functionality
          return ComponentActionResult.failure('Move action not yet implemented');

        case ComponentAction.copy:
          if (targetPosition == null) {
            return ComponentActionResult.failure('Target position required for copy');
          }
          // TODO: Implement copy functionality
          return ComponentActionResult.failure('Copy action not yet implemented');
      }
    } catch (e) {
      return ComponentActionResult.failure('Action failed: $e');
    }
  }

  Future<ComponentActionResult> placeComponent(ComponentType type, GridPosition position) async {
    try {
      final gameNotifier = ref.read(providers_v3.enhancedGameStateNotifierProvider.notifier);
      gameNotifier.placeComponent(type, position.row, position.col);

      // Create a component model for the result
      final component = ComponentModel(
        id: 'temp_${position.row}_${position.col}',
        type: type,
        row: position.row,
        col: position.col,
      );

      return ComponentActionResult.success(component);
    } catch (e) {
      return ComponentActionResult.failure('Failed to place component: $e');
    }
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
        final gameState = ref.read(providers_v3.enhancedGameStateNotifierProvider);
        final occupied = gameState.grid.components.values.any(
          (c) => c.row == targetPosition.row && c.col == targetPosition.col
        );
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