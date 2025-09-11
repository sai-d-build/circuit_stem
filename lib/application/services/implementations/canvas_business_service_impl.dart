import 'package:flutter/material.dart';
import 'package:sparkcircuit/application/services/interfaces/canvas_business_service.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/application/services/interfaces/component_placement_service.dart';
import 'package:sparkcircuit/core/services/unified_coordinate_service.dart';

/// Implementation of CanvasBusinessService
/// Handles business logic for canvas operations like component placement and validation
class CanvasBusinessServiceImpl implements CanvasBusinessService {
  final dynamic paletteStateNotifier;
  final dynamic componentPlacementService;

  CanvasBusinessServiceImpl({
    required this.paletteStateNotifier,
    required this.componentPlacementService,
  });

  @override
  Future<ComponentPlacementResult> placeComponent(
    String componentTypeString,
    Offset position,
    GameState gameState,
    PaletteState paletteState,
    String levelId,
  ) async {
    StructuredLogger.info('Component placement initiated', context: {
      'componentType': componentTypeString,
      'position': position.toString(),
      'levelId': levelId,
    });

    // Check inventory
    if (!paletteState.canUseComponent(componentTypeString)) {
      StructuredLogger.warning('Component placement denied - insufficient inventory', context: {
        'componentType': componentTypeString,
        'availableInventory': paletteState.inventory,
      });
      return ComponentPlacementResult.failure('No more $componentTypeString components available');
    }

    // Get grid configuration and convert position
    final config = _getGridConfiguration(gameState);
    final unifiedService = UnifiedCoordinateService();
    final gridPosition = unifiedService.screenToGrid(position, config);
    final snappedPosition = Offset(
      gridPosition.dx.round().toDouble(),
      gridPosition.dy.round().toDouble(),
    );

    // Check if position is occupied
    final existingComponent = _getComponentAtPosition(
      Offset(snappedPosition.dx.toInt().toDouble(), snappedPosition.dy.toInt().toDouble()),
      gameState
    );

    if (existingComponent != null) {
      StructuredLogger.warning('Component placement denied - position occupied', context: {
        'position': '${snappedPosition.dx.toInt()}, ${snappedPosition.dy.toInt()}',
        'occupyingComponent': existingComponent.id,
      });
      return ComponentPlacementResult.failure('Position already occupied');
    }

    // Convert string to ComponentType enum
    final componentType = ComponentType.values.firstWhere(
      (e) => e.toString().split('.').last == componentTypeString,
      orElse: () => ComponentType.wire,
    );

    // Place component in game state
    StructuredLogger.debug('Placing component in game state', context: {
      'componentType': componentType.toString(),
      'gridPosition': '${snappedPosition.dy.toInt()}, ${snappedPosition.dx.toInt()}',
    });

    // Update game state
    paletteStateNotifier.useComponent(componentTypeString);
    paletteStateNotifier.stopPlacingComponent();

    StructuredLogger.info('Component placement successful', context: {
      'componentType': componentTypeString,
      'gridPosition': '${snappedPosition.dy.toInt()}, ${snappedPosition.dx.toInt()}',
    });

    return ComponentPlacementResult.success(componentType, snappedPosition.dy.toInt(), snappedPosition.dx.toInt());
  }

  @override
  Future<ComponentDropResult> processComponentDrop(
    DragTargetDetails<ComponentDragData> details,
    Offset localPosition,
    GameState gameState,
    PaletteState paletteState,
    String levelId,
  ) async {
    StructuredLogger.info('Processing component drop', context: {
      'componentName': details.data.componentName,
      'componentType': details.data.componentType.toString(),
      'levelId': levelId,
    });

    // Get placement service
    final placementService = componentPlacementService;

    // Convert component type
    final componentType = ComponentType.values.firstWhere(
      (e) => e.toString().split('.').last == details.data.componentType.toString().split('.').last,
      orElse: () => ComponentType.wire,
    );

    // Convert position
    final config = _getGridConfiguration(gameState);
    final unifiedService = UnifiedCoordinateService();
    final gridPosition = unifiedService.screenToGrid(localPosition, config);
    final row = gridPosition.dy.round();
    final col = gridPosition.dx.round();

    // Create placement request
    final request = ComponentPlacementRequest(
      componentType: componentType,
      row: row,
      col: col,
      currentGameState: gameState,
      levelId: levelId,
    );

    try {
      final result = await placementService.executeComponentPlacement(request);

      if (result.isSuccess) {
        paletteStateNotifier.stopPlacingComponent();
        return ComponentDropResult.success(componentType, row, col);
      } else {
        return ComponentDropResult.failure(result.errorMessage ?? 'Failed to place component');
      }
    } catch (e) {
      StructuredLogger.error('Component drop error', context: {
        'error': e.toString(),
      }, error: e);
      return ComponentDropResult.failure('Error placing component: $e');
    }
  }

  @override
  bool canAcceptComponentDrop(
    DragTargetDetails<ComponentDragData> details,
    Offset localPosition,
    GameState gameState,
    PaletteState paletteState,
    String levelId,
  ) {
    StructuredLogger.debug('Validating component drop', context: {
      'componentName': details.data.componentName,
      'componentType': details.data.componentType.toString(),
    });

    // Get grid configuration
    final config = _getGridConfiguration(gameState);
    final unifiedService = UnifiedCoordinateService();
    final validGridPosition = unifiedService.getValidGridPosition(localPosition, config);

    if (validGridPosition == null) {
      StructuredLogger.debug('Drop validation failed - invalid grid position');
      return false;
    }

    // Check if position is available
    final existingComponent = _getComponentAtPosition(validGridPosition, gameState);
    if (existingComponent != null) {
      StructuredLogger.debug('Drop validation failed - position occupied', context: {
        'occupyingComponent': existingComponent.id,
      });
      return false;
    }

    // Check inventory
    final componentTypeString = details.data.componentType.toString().split('.').last;
    final canUse = paletteState.canUseComponent(componentTypeString);

    if (!canUse) {
      StructuredLogger.debug('Drop validation failed - insufficient inventory', context: {
        'componentType': componentTypeString,
      });
      return false;
    }

    StructuredLogger.debug('Drop validation passed');
    return true;
  }

  ComponentModel? _getComponentAtPosition(Offset gridPosition, GameState gameState) {
    for (final component in gameState.grid.components.values) {
      if (component.col == gridPosition.dx.toInt() && component.row == gridPosition.dy.toInt()) {
        return component;
      }
    }
    return null;
  }

  GridConfiguration _getGridConfiguration(GameState gameState) {
    return GridConfiguration(
      rows: gameState.grid.rows,
      cols: gameState.grid.cols,
      cellSize: 60.0,
      scale: 1.0,
      panOffset: Offset.zero,
    );
  }
}