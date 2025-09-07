import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
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

    // Create ComponentModel for grid storage
    final componentModel = ComponentModel(
      id: componentId,
      type: componentType,
      row: row,
      col: col,
    );

    // Update grid with new component
    final updatedGrid = state.grid.copyWith(
      components: {...state.grid.components, componentId: componentModel},
    );

    state = state.copyWith(
      grid: updatedGrid,
      lastUpdated: DateTime.now(),
    );

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
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        selectedComponentId: componentId,
        draggedComponentId: componentId,
        dragStartLocalPosition: position,
        isDragging: true,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  /// Update drag position
  void dragUpdate(Offset position) {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        dragUpdateLocalPosition: position,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  /// End dragging
  void endDragging() {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        draggedComponentId: null,
        dragStartLocalPosition: null,
        dragUpdateLocalPosition: null,
        isDragging: false,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  /// Move a component to a new position
  void moveComponent(String componentId, int newRow, int newCol) {
    final component = state.grid.components[componentId];
    if (component == null) return;

    // Check if new position is occupied
    final existingComponent = state.grid.components.values.firstWhere(
      (c) => c.row == newRow && c.col == newCol && c.id != componentId,
      orElse: () => ComponentModel(id: '', type: ComponentType.wire, row: -1, col: -1),
    );

    if (existingComponent.id.isNotEmpty) {
      // Position is occupied, don't move
      return;
    }

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