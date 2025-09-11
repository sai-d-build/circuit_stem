import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import '../../../core/debug/structured_logger.dart';
import '../../states/game_state.dart';

/// Clean V3 Game Engine Notifier - Built from scratch with current domain models
class GameEngineNotifierV3 extends StateNotifier<GameState> {
  GameEngineNotifierV3() : super(GameState.initial(null));

  /// Load a level
  void loadLevel(LevelDefinition level) {
    state = GameState.initial(level);
  }

  /// Place a component on the grid
  ComponentModel placeComponent(ComponentType componentType, int row, int col) {
    final componentId = '${componentType.toString().split('.').last}_${DateTime.now().millisecondsSinceEpoch}';

    StructuredLogger.info('🎯 GameEngineNotifierV3: Placing component', context: {
      'componentId': componentId,
      'componentType': componentType.toString(),
      'targetPosition': {'row': row, 'col': col},
      'currentGridComponents': state.grid.components.length,
      'currentGridRows': state.grid.rows,
      'currentGridCols': state.grid.cols,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // 🔍 STEP 1: Check if position is valid relative to grid boundaries
    final isValidPosition = row >= 0 && row < state.grid.rows && col >= 0 && col < state.grid.cols;
    StructuredLogger.debug('🔍 GameEngine: Position boundary check', context: {
      'isValidPosition': isValidPosition,
      'positionCheck': {
        'rowCheck': '$row >= 0 && $row < ${state.grid.rows}',
        'colCheck': '$col >= 0 && $col < ${state.grid.cols}',
      },
    });

    if (!isValidPosition) {
      StructuredLogger.error('🚫 GameEngine: Invalid position for component placement', context: {
        'componentId': componentId,
        'invalidPosition': {'row': row, 'col': col},
        'gridBoundaries': {
          'rows': state.grid.rows,
          'cols': state.grid.cols,
        },
        'boundaryViolations': {
          'rowTooLow': row < 0,
          'rowTooHigh': row >= state.grid.rows,
          'colTooLow': col < 0,
          'colTooHigh': col >= state.grid.cols,
        },
      });
      throw Exception('Position out of bounds: row=$row, col=$col, grid=${state.grid.rows}x${state.grid.cols}');
    }

    // 🔍 STEP 2: Check for position occupation
    final existingComponent = state.grid.componentAt(row, col);
    final isOccupied = existingComponent != null;
    StructuredLogger.debug('🔍 GameEngine: Occupation check', context: {
      'isOccupied': isOccupied,
      'existingComponentId': existingComponent?.id,
      'checkLocation': '$row,$col',
    });

    if (isOccupied) {
      StructuredLogger.warning('⚠️ GameEngine: Position already occupied', context: {
        'componentId': componentId,
        'attemptedPosition': {'row': row, 'col': col},
        'existingComponent': {
          'id': existingComponent.id,
          'type': existingComponent.type.toString(),
        },
      });
      throw Exception('Position ($row, $col) is already occupied by component ${existingComponent.id}');
    }

    // 🔍 STEP 3: Create ComponentModel for grid storage
    StructuredLogger.debug('🔍 GameEngine: Creating component model', context: {
      'componentId': componentId,
      'componentType': componentType.toString(),
      'creationTimestamp': DateTime.now().millisecondsSinceEpoch,
    });

    final componentModel = ComponentModel(
      id: componentId,
      type: componentType,
      row: row,
      col: col,
    );

    // 🔍 STEP 4: Update grid with new component
    StructuredLogger.debug('🔍 GameEngine: Updating grid state', context: {
      'previousComponentsCount': state.grid.components.length,
      'newComponentsCount': state.grid.components.length + 1,
      'componentId': componentId,
      'componentPosition': '$row,$col',
      'componentType': componentType.toString(),
    });

    final updatedGrid = state.grid.copyWith(
      components: {...state.grid.components, componentId: componentModel},
      updatedAt: DateTime.now(),
    );

    // 🔍 STEP 5: Update overall game state
    StructuredLogger.debug('🔍 GameEngine: Updating game state', context: {
      'previousStateComponents': state.grid.components.length,
      'updatedStateComponents': updatedGrid.components.length,
      'newComponentAdded': componentId,
      'stateUpdateTimestamp': DateTime.now().toIso8601String(),
    });

    state = state.copyWith(
      grid: updatedGrid,
      lastUpdated: DateTime.now(),
    );

    StructuredLogger.info('✅ GameEngineNotifierV3: Component placed successfully', context: {
      'componentId': componentId,
      'componentType': componentType.toString(),
      'finalPosition': {'row': row, 'col': col},
      'gridUpdatedComponents': updatedGrid.components.length,
      'operationTimestamp': DateTime.now().toIso8601String(),
    });

    return componentModel;
  }

  /// Select a component
  void selectComponent(String? componentId) {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        selectedComponentId: componentId,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  /// Remove a component
  void removeComponent(String componentId) {
    final updatedComponents = Map<String, ComponentModel>.from(state.grid.components);
    updatedComponents.remove(componentId);

    final updatedGrid = state.grid.copyWith(components: updatedComponents);

    state = state.copyWith(
      grid: updatedGrid,
      lastUpdated: DateTime.now(),
    );
  }

  /// Add a connection between components
  void addConnection(String fromComponentId, String toComponentId) {
    final updatedConnections = Map<String, List<String>>.from(state.grid.connections);
    final existingConnections = updatedConnections[fromComponentId] ?? [];
    if (!existingConnections.contains(toComponentId)) {
      updatedConnections[fromComponentId] = [...existingConnections, toComponentId];
    }

    final updatedGrid = state.grid.copyWith(connections: updatedConnections);

    state = state.copyWith(
      grid: updatedGrid,
      lastUpdated: DateTime.now(),
    );
  }

  /// Remove a connection between components
  void removeConnection(String fromComponentId, String toComponentId) {
    final updatedConnections = Map<String, List<String>>.from(state.grid.connections);
    final existingConnections = updatedConnections[fromComponentId] ?? [];
    updatedConnections[fromComponentId] = existingConnections.where((id) => id != toComponentId).toList();

    final updatedGrid = state.grid.copyWith(connections: updatedConnections);

    state = state.copyWith(
      grid: updatedGrid,
      lastUpdated: DateTime.now(),
    );
  }

  /// Toggle pause state
  void togglePause() {
    state = state.copyWith(
      isPaused: !state.isPaused,
      lastUpdated: DateTime.now(),
    );
  }

  /// Reset the level
  void resetLevel() {
    if (state.currentLevel != null) {
      state = GameState.initial(state.currentLevel);
    }
  }

  /// Undo last action (simplified implementation)
  void undo() {
    // TODO: Implement proper undo functionality
    // For now, just reset the level
    resetLevel();
  }

  /// Redo last undone action (simplified implementation)
  void redo() {
    // TODO: Implement proper redo functionality
    // For now, this is a placeholder - redo functionality would require
    // maintaining a redo stack separate from the undo stack
    StructuredLogger.info('Redo called - not yet implemented');
  }

  /// Get CircuitComponent representation for UI
  List<CircuitComponent> getCircuitComponents() {
    return state.grid.components.values
        .map((component) => CircuitComponent.fromComponentModel(component))
        .toList();
  }

  /// Get selected component as CircuitComponent
  CircuitComponent? getSelectedCircuitComponent() {
    if (state.interactionState.selectedComponentId == null) return null;

    final componentModel = state.grid.components[state.interactionState.selectedComponentId];
    return componentModel != null
        ? CircuitComponent.fromComponentModel(componentModel)
        : null;
  }

  /// Tap on a component (select it)
  void tapComponent(String componentId) {
    selectComponent(componentId);
  }

  /// Start dragging a component
  void startDragging(String componentId, Offset position) {
    StructuredLogger.info('🎯 GAME ENGINE: START DRAGGING', context: {
      'componentId': componentId,
      'position': position.toString(),
      'currentState': {
        'selectedComponentId': state.interactionState.selectedComponentId,
        'draggedComponentId': state.interactionState.draggedComponentId,
        'isDragging': state.interactionState.isDragging,
      },
      'timestamp': DateTime.now().toIso8601String(),
    });

    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        selectedComponentId: componentId,
        draggedComponentId: componentId,
        dragStartLocalPosition: position,
        isDragging: true,
      ),
      lastUpdated: DateTime.now(),
    );

    StructuredLogger.info('✅ GAME ENGINE: DRAG STARTED SUCCESSFULLY', context: {
      'componentId': componentId,
      'newState': {
        'selectedComponentId': state.interactionState.selectedComponentId,
        'draggedComponentId': state.interactionState.draggedComponentId,
        'isDragging': state.interactionState.isDragging,
      },
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Update drag position
  void dragUpdate(Offset position) {
    StructuredLogger.debug('🔄 GAME ENGINE: DRAG UPDATE', context: {
      'position': position.toString(),
      'currentDraggedComponent': state.interactionState.draggedComponentId,
      'isDragging': state.interactionState.isDragging,
      'timestamp': DateTime.now().toIso8601String(),
    });

    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        dragUpdateLocalPosition: position,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  /// End dragging
  void endDragging() {
    StructuredLogger.info('🏁 GAME ENGINE: END DRAGGING', context: {
      'draggedComponentId': state.interactionState.draggedComponentId,
      'dragStartPosition': state.interactionState.dragStartLocalPosition?.toString(),
      'finalPosition': state.interactionState.dragUpdateLocalPosition?.toString(),
      'isDragging': state.interactionState.isDragging,
      'timestamp': DateTime.now().toIso8601String(),
    });

    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        draggedComponentId: null,
        dragStartLocalPosition: null,
        dragUpdateLocalPosition: null,
        isDragging: false,
      ),
      lastUpdated: DateTime.now(),
    );

    StructuredLogger.info('✅ GAME ENGINE: DRAGGING ENDED', context: {
      'finalState': {
        'draggedComponentId': state.interactionState.draggedComponentId,
        'isDragging': state.interactionState.isDragging,
      },
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Move a component to a new position
  void moveComponent(String componentId, int newRow, int newCol) {
    StructuredLogger.info('🎯 GAME ENGINE: MOVE COMPONENT', context: {
      'componentId': componentId,
      'targetPosition': {'row': newRow, 'col': newCol},
      'currentComponents': state.grid.components.length,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final component = state.grid.components[componentId];
    if (component == null) {
      StructuredLogger.warning('⚠️ GAME ENGINE: Component not found for move', context: {
        'componentId': componentId,
        'availableComponents': state.grid.components.keys.toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      return;
    }

    StructuredLogger.debug('🔍 GAME ENGINE: Checking position occupation', context: {
      'componentId': componentId,
      'targetPosition': {'row': newRow, 'col': newCol},
      'currentPosition': {'row': component.row, 'col': component.col},
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Check if new position is occupied
    final existingComponent = state.grid.components.values.firstWhere(
      (c) => c.row == newRow && c.col == newCol && c.id != componentId,
      orElse: () => ComponentModel(id: '', type: ComponentType.wire, row: -1, col: -1),
    );

    if (existingComponent.id.isNotEmpty) {
      StructuredLogger.warning('🚫 GAME ENGINE: Position occupied, cannot move', context: {
        'componentId': componentId,
        'targetPosition': {'row': newRow, 'col': newCol},
        'occupyingComponent': {
          'id': existingComponent.id,
          'type': existingComponent.type.toString(),
        },
        'timestamp': DateTime.now().toIso8601String(),
      });
      return;
    }

    StructuredLogger.debug('✅ GAME ENGINE: Position available, moving component', context: {
      'componentId': componentId,
      'fromPosition': {'row': component.row, 'col': component.col},
      'toPosition': {'row': newRow, 'col': newCol},
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Update component position
    final updatedComponent = component.copyWith(
      row: newRow,
      col: newCol,
    );

    final updatedComponents = Map<String, ComponentModel>.from(state.grid.components);
    updatedComponents[componentId] = updatedComponent;

    final updatedGrid = state.grid.copyWith(components: updatedComponents);

    state = state.copyWith(
      grid: updatedGrid,
      lastUpdated: DateTime.now(),
    );

    StructuredLogger.info('✅ GAME ENGINE: Component moved successfully', context: {
      'componentId': componentId,
      'finalPosition': {'row': newRow, 'col': newCol},
      'totalComponents': updatedGrid.components.length,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Rotate a component by 90 degrees clockwise
  void rotateComponent(String componentId) {
    final component = state.grid.components[componentId];
    if (component == null) return;

    // Rotate by 90 degrees (0 -> 90 -> 180 -> 270 -> 0)
    final newRotation = (component.rotation + 90) % 360;

    final updatedComponent = component.copyWith(rotation: newRotation);

    final updatedComponents = Map<String, ComponentModel>.from(state.grid.components);
    updatedComponents[componentId] = updatedComponent;

    final updatedGrid = state.grid.copyWith(components: updatedComponents);

    state = state.copyWith(
      grid: updatedGrid,
      lastUpdated: DateTime.now(),
    );
  }
}