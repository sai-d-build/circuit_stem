
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/application/services/component_factory.dart';
import 'package:sparkcircuit/core/commands/command_stack.dart';
import 'package:sparkcircuit/core/commands/create_component_command.dart';
import 'package:sparkcircuit/core/commands/game_command.dart';
import 'package:sparkcircuit/core/commands/move_component_command.dart';
import 'package:sparkcircuit/core/commands/rotate_component_command.dart';
import 'package:sparkcircuit/core/commands/tap_component_command.dart';
import 'package:sparkcircuit/core/commands/add_connection_command.dart';
import 'package:sparkcircuit/core/commands/select_component_command.dart';

import 'package:sparkcircuit/core/persistence/storage_service.dart';
import 'package:sparkcircuit/core/simulation/netlist_builder.dart';
import 'package:sparkcircuit/core/simulation/simulation_engine.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart'; // Import for Offset

class EnhancedGameStateNotifier extends StateNotifier<GameState> {
  final SimulationEngine _simulationEngine;
  final NetlistBuilder _netlistBuilder;
  final StorageService _storageService;
  final CommandStack _commandStack;
  final ComponentFactory _componentFactory;

  EnhancedGameStateNotifier({
    required SimulationEngine simulationEngine,
    required NetlistBuilder netlistBuilder,
    required StorageService storageService,
    required CommandStack commandStack,
    required ComponentFactory componentFactory,
  })  : _simulationEngine = simulationEngine,
        _netlistBuilder = netlistBuilder,
        _storageService = storageService,
        _commandStack = commandStack,
        _componentFactory = componentFactory,
        super(GameState.initial(null));

  // Centralized method to execute commands and update state
  Future<void> _executeCommand(GameCommand command) async {
    // Execute the command to get the new state
    final newState = command.execute(state);

    // Push the command onto the stack
    _commandStack.push(command);

    // Run simulation
    final netlist = _netlistBuilder.buildNetlist(newState);
    final simulationResult = await _simulationEngine.solveDC(netlist);

    // Update the state with the result of the command and simulation
    state = newState.copyWith(
      simulationResult: simulationResult,
      lastUpdated: DateTime.now(),
    );

    // Auto-save
    await _storageService.saveState('game_state', state);
  }

  Future<void> placeComponent(ComponentType type, int row, int col) async {
    const uuid = Uuid();
    final newCircuitComponent = _componentFactory.create(
      type: type.name,
      id: uuid.v4(),
      r: row,
      c: col,
    );
    // Convert CircuitComponent to ComponentModel for Grid operations
    final newComponent = newCircuitComponent.toComponentModel();
    final command = CreateComponentCommand(newComponent);
    await _executeCommand(command);
  }

  Future<void> moveComponent(
      String componentId, int newRow, int newCol) async {
    final component = state.grid.getComponentById(componentId);
    if (component == null) return;

    final command = MoveComponentCommand(
      componentId: componentId,
      oldRow: component.row,
      oldCol: component.col,
      newRow: newRow,
      newCol: newCol,
    );
    await _executeCommand(command);
  }

  Future<void> rotateComponent(String componentId) async {
    final component = state.grid.getComponentById(componentId);
    if (component == null) return;

    // Example: Rotate by 90 degrees. Logic can be more complex.
    final newRotation = (component.rotation + 90) % 360;

    final command = RotateComponentCommand(
      componentId: componentId,
      oldRotation: component.rotation,
      newRotation: newRotation,
    );
    await _executeCommand(command);
  }

  void resetLevel() {
    state = GameState.initial(state.currentLevel);
    _commandStack.clear(); // Clear command history on reset
    _storageService.saveState('game_state', state); // Save the reset state
  }

  Future<void> undo() async {
    final command = _commandStack.undo();
    if (command != null) {
      final newState = command.undo(state);

      // Run simulation
      final netlist = _netlistBuilder.buildNetlist(newState);
      final simulationResult = await _simulationEngine.solveDC(netlist);

      state = newState.copyWith(
        simulationResult: simulationResult,
        lastUpdated: DateTime.now(),
      );
      await _storageService.saveState('game_state', state);
    }
  }

  Future<void> redo() async {
    final command = _commandStack.redo();
    if (command != null) {
      final newState = command.execute(state);

      // Run simulation
      final netlist = _netlistBuilder.buildNetlist(newState);
      final simulationResult = await _simulationEngine.solveDC(netlist);

      state = newState.copyWith(
        simulationResult: simulationResult,
        lastUpdated: DateTime.now(),
      );
      await _storageService.saveState('game_state', state);
    }
  }

  Future<void> tapComponent(String componentId) async {
    final command = TapComponentCommand(
      componentIdToSelect: componentId,
      previousSelectedComponentId: state.interactionState.selectedComponentId,
    );
    await _executeCommand(command);
  }

  Future<void> selectComponent(String? componentId) async {
    final command = SelectComponentCommand(
      componentIdToSelect: componentId,
      previousSelectedComponentId: state.interactionState.selectedComponentId,
    );
    await _executeCommand(command);
  }

  void startDragging(String componentId, Offset localPosition) {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        draggedComponentId: componentId,
        dragStartLocalPosition: localPosition,
        isDragging: true,
      ),
    );
  }

  void dragUpdate(Offset localPosition) {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        dragUpdateLocalPosition: localPosition,
      ),
    );
  }

  void endDragging() {
    // This is where a move command would be dispatched
    final interaction = state.interactionState;
    final componentId = interaction.draggedComponentId;
    if (componentId == null) return;

    // Logic to determine new grid position from drag would go here
    // For now, we'll just clear the dragging state.
    // In a real implementation, you'd calculate the new (row, col)
    // and call `moveComponent`.

    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        draggedComponentId: null,
        dragStartLocalPosition: null,
        dragUpdateLocalPosition: null,
        isDragging: false,
      ),
    );
  }

  Future<void> addConnection(String fromComponentId, String toComponentId) async {
    final command = AddConnectionCommand(
      fromComponentId: fromComponentId,
      toComponentId: toComponentId,
    );
    await _executeCommand(command);
  }
}
