import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/level_definition.dart';
import '../models/component.dart';
import '../models/grid.dart';
import 'game_engine_state.dart';
import 'animation_scheduler.dart';
import '../services/audio_service.dart';
import '../behaviors/interaction_behavior.dart';
import '../behaviors/goal_checking_behavior.dart';
import '../behaviors/logic_behavior.dart';
import '../common/assets.dart';
import '../common/logger.dart';
import 'render_state.dart';

class _SimpleLogicSimulator {
  Set<String> evaluate(Grid grid) {
    Logger.log('_SimpleLogicSimulator: Evaluating grid with ${grid.components.length} components.');
    final graph = _buildGraph(grid);
    final battery = grid.components.where((c) => c.type == 'Component.Battery').firstOrNull;
    if (battery == null) {
      Logger.log('_SimpleLogicSimulator: No battery found.');
      return {};
    }

    final startNodes = battery.terminals
        .where((t) => t.type == TerminalType.power)
        .map((t) => '${battery.id}_${t.offset.x}_${t.offset.y}_${t.direction.name}_${t.type.name}');

    if (startNodes.isEmpty) {
      Logger.log('_SimpleLogicSimulator: Battery has no positive terminals.');
      return {};
    }

    final poweredTerminals = _bfs(graph, startNodes.first);

    final poweredComponentIds = <String>{};
    for (final terminalId in poweredTerminals) {
      final componentId = terminalId.split('_').first;
      poweredComponentIds.add(componentId);
    }
    Logger.log('_SimpleLogicSimulator: Powered component IDs: $poweredComponentIds');
    return poweredComponentIds;
  }

  Map<String, List<String>> _buildGraph(Grid grid) {
    final graph = <String, List<String>>{};
    for (final component in grid.components) {
      for (final terminal in component.terminals) {
        final terminalId = '${component.id}_${terminal.offset.x}_${terminal.offset.y}_${terminal.direction.name}_${terminal.type.name}';
        graph[terminalId] = [];
      }
      for (final connection in component.internalConnections) {
        final term1Spec = component.terminals[connection[0]];
        final term2Spec = component.terminals[connection[1]];
        final term1 = '${component.id}_${term1Spec.offset.x}_${term1Spec.offset.y}_${term1Spec.direction.name}_${term1Spec.type.name}';
        final term2 = '${component.id}_${term2Spec.offset.x}_${term2Spec.offset.y}_${term2Spec.direction.name}_${term2Spec.type.name}';
        graph[term1]?.add(term2);
        graph[term2]?.add(term1);
      }
    }
    Logger.log('_SimpleLogicSimulator: Built graph with ${graph.keys.length} nodes.');
    return graph;
  }

  Set<String> _bfs(Map<String, List<String>> graph, String startNode) {
    final visited = <String>{};
    final queue = Queue<String>();

    if (graph.containsKey(startNode)) {
      visited.add(startNode);
      queue.add(startNode);
    }

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      for (final neighbor in graph[node] ?? []) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(neighbor);
        }
      }
    }
    Logger.log('_SimpleLogicSimulator: BFS found ${visited.length} visited nodes.');
    return visited;
  }
}

class GameEngineNotifier extends StateNotifier<GameEngineState> {
  final LevelDefinition? initialLevel;
  final AnimationScheduler animationScheduler;
  final AudioService audioService;
  final _logicSimulator = _SimpleLogicSimulator();

  /// History stack for undo functionality
  final List<GameEngineState> _stateHistory = [];
  static const int _maxHistorySize = 50;

  GameEngineNotifier({
    this.initialLevel,
    required this.animationScheduler,
    required this.audioService,
  }) : super(GameEngineState.empty()) {
    Logger.log('GameEngineNotifier: Initializing with initialLevel: $initialLevel');
    final level = initialLevel;
    if (level != null) {
      _loadLevel(level);
    }
  }

  factory GameEngineNotifier.forNoLevel({
    required AnimationScheduler animationScheduler,
    required AudioService audioService,
  }) {
    Logger.log('GameEngineNotifier.forNoLevel: Initializing for no level.');
    return GameEngineNotifier(
      initialLevel: null,
      animationScheduler: animationScheduler,
      audioService: audioService,
    );
  }

  void _pushToHistory() {
    _stateHistory.add(state);
    if (_stateHistory.length > _maxHistorySize) {
      _stateHistory.removeAt(0);
    }
  }

  // ============================================================================
  // SINGLE COMMIT PIPELINE - The ONLY method that modifies state
  // ============================================================================
  
  /// The single, canonical pipeline for ALL state updates.
  /// This method ensures atomic, race-condition-free state management.
  void _commitGrid(Grid newGrid, {
    String? selectedComponentId,
    String? draggedComponentId,
    Offset? dragPosition,
    bool? isPaused,
    bool? isWin,
  }) {
    Logger.log('GameEngineNotifier: _commitGrid called - SINGLE COMMIT PIPELINE');
    
    // Step 1: Evaluate all LogicBehavior components
    for (var component in newGrid.components) {
      final behavior = component.getBehavior<LogicBehavior>();
      if (behavior != null) {
        Logger.log('GameEngineNotifier: Evaluating logic for component: ${component.id}');
        behavior.evaluate(newGrid, component);
      }
    }

    // Step 2: Calculate powered components
    final poweredIds = _logicSimulator.evaluate(newGrid);

    // Step 3: Update component power states
    final updatedComponents = newGrid.components.map((c) {
      return c.copyWith(isPowered: poweredIds.contains(c.id));
    }).toList();

    final finalGrid = newGrid.copyWith(components: updatedComponents);
    
    // Step 4: Create updated render state
    final updatedRenderState = RenderState(
      grid: finalGrid,
      poweredComponentIds: poweredIds,
      draggedComponentId: draggedComponentId ?? state.draggedComponentId,
      dragPosition: dragPosition ?? state.dragPosition,
    );
    
    // Step 5: Update state EXACTLY ONCE
    state = state.copyWith(
      grid: finalGrid,
      renderState: updatedRenderState,
      selectedComponentId: selectedComponentId ?? state.selectedComponentId,
      draggedComponentId: draggedComponentId ?? state.draggedComponentId,
      dragPosition: dragPosition ?? state.dragPosition,
      isPaused: isPaused ?? state.isPaused,
      isWin: isWin ?? state.isWin,
    );
    
    Logger.log('GameEngineNotifier: State committed. Powered components: $poweredIds');
    
    // Step 6: Check win condition
    _checkWinCondition();
  }

  // ============================================================================
  // PUBLIC API - All public methods delegate to _commitGrid
  // ============================================================================

  void _loadLevel(LevelDefinition level) {
    Logger.log('GameEngineNotifier: Loading level: ${level.id}');
    final grid = Grid(rows: level.rows, cols: level.cols, components: level.initialComponents);
    Logger.log('GameEngineNotifier: Created grid with ${grid.components.length} initial components.');
    
    state = GameEngineState.initial(level);
    _commitGrid(grid, isWin: false, isPaused: false);
  }

  void handleTap(Offset tapPosition) {
    Logger.log('GameEngineNotifier: Handling tap at: $tapPosition');
    final cell = state.grid.cellAt(tapPosition.dx, tapPosition.dy);
    if (cell == null) {
      Logger.log('GameEngineNotifier: Tap outside grid.');
      return;
    }
    
    final component = state.grid.componentAt(cell.r, cell.c);
    if (component != null) {
      Logger.log('GameEngineNotifier: Tapped on component: ${component.id}');
      final behavior = component.getBehavior<InteractionBehavior>();
      if (behavior != null) {
        // Push to history before interactive behavior (like switch toggle)
        _pushToHistory();
        
        Logger.log('GameEngineNotifier: Invoking InteractionBehavior for component: ${component.id}');
        behavior.onTap(this, component);
      } else {
        Logger.log('GameEngineNotifier: No InteractionBehavior found for component: ${component.id}. Selecting component.');
        _commitGrid(state.grid, selectedComponentId: component.isDraggable ? component.id : null);
      }
    } else {
      Logger.log('GameEngineNotifier: No component at tapped cell: (${cell.r}, ${cell.c})');
    }
  }

  void selectPaletteComponent(ComponentModel component) {
    Logger.log('GameEngineNotifier: Selecting palette component: ${component.id}');
    _commitGrid(state.grid, selectedComponentId: component.id);
  }

  /// Called by InteractionBehavior implementations to update component state
  void updateComponent(ComponentModel component) {
    Logger.log('GameEngineNotifier: Updating component: ${component.id} with new state: ${component.state}');
    
    final newGrid = state.grid.copyWithUpdatedComponent(component);
    _commitGrid(newGrid);
  }

  void startDrag(ComponentModel component, Offset position) {
    Logger.log('GameEngineNotifier: Starting drag for component: ${component.id} at $position');
    _commitGrid(state.grid, draggedComponentId: component.id, dragPosition: position);
  }

  void updateDrag(Offset position) {
    Logger.log('GameEngineNotifier: Updating drag position to: $position');
    _commitGrid(state.grid, dragPosition: position);
  }

  void endDrag() {
    Logger.log('GameEngineNotifier: Ending drag.');
    final draggedComponentId = state.draggedComponentId;
    final dragPosition = state.dragPosition;

    if (draggedComponentId != null && dragPosition != null) {
      final cell = state.grid.cellAt(dragPosition.dx, dragPosition.dy);
      if (cell != null) {
        Logger.log('GameEngineNotifier: Dropped at cell: (${cell.r}, ${cell.c})');
        final oldComponent = state.grid.componentsById[draggedComponentId];
        if (oldComponent != null) {
          if (state.grid.isCellOccupied(cell.r, cell.c, excludeComponentId: oldComponent.id)) {
            Logger.log('GameEngineNotifier: Cell occupied, playing warning sound.');
            audioService.play(AppAssets.audioWarning);
            // Clear drag state but don't move component
            _commitGrid(state.grid, draggedComponentId: null, dragPosition: null);
          } else {
            Logger.log('GameEngineNotifier: Valid drop, updating component position.');
            
            // Push to history before making the move
            _pushToHistory();
            
            final newComponent = oldComponent.copyWith(r: cell.r, c: cell.c);
            final newGrid = state.grid.copyWithUpdatedComponent(newComponent);
            
            // Play placement sound for successful moves
            audioService.play(AppAssets.audioPlacement);
            
            // Clear drag state and commit new position
            _commitGrid(newGrid, draggedComponentId: null, dragPosition: null);
          }
        }
      } else {
        Logger.log('GameEngineNotifier: Dropped outside grid.');
        _commitGrid(state.grid, draggedComponentId: null, dragPosition: null);
      }
    } else {
      Logger.log('GameEngineNotifier: No component being dragged.');
      _commitGrid(state.grid, draggedComponentId: null, dragPosition: null);
    }
  }

  void addComponent(ComponentModel paletteComponent, int r, int c) {
    Logger.log('GameEngineNotifier: Adding component ${paletteComponent.type} at ($r, $c)');
    
    // Push current state to history before adding component
    _pushToHistory();
    
    final grid = state.grid;
    final newId = '${paletteComponent.type}_${DateTime.now().millisecondsSinceEpoch}';
    final newComponent = paletteComponent.copyWith(id: newId, r: r, c: c);
    final newGrid = grid.copyWith(components: [...grid.components, newComponent]);
    
    // Play placement sound
    audioService.play(AppAssets.audioPlacement);
    
    _commitGrid(newGrid);
  }

  void rotateComponent() {
    Logger.log('GameEngineNotifier: Rotating selected component.');
    final selectedComponentId = state.selectedComponentId;
    if (selectedComponentId != null) {
      final component = state.grid.componentsById[selectedComponentId];
      if (component != null && component.isDraggable) {
        // Push to history before rotating
        _pushToHistory();
        
        final newRotation = (component.rotation + 90) % 360;
        final updatedComponent = component.copyWith(rotation: newRotation);
        final newGrid = state.grid.copyWithUpdatedComponent(updatedComponent);
        
        _commitGrid(newGrid);
        Logger.log('GameEngineNotifier: Rotated component ${component.id} to $newRotation degrees.');
      } else {
        Logger.log('GameEngineNotifier: Selected component is null or not draggable.');
      }
    } else {
      Logger.log('GameEngineNotifier: No component selected for rotation.');
    }
  }

  void togglePause() {
    Logger.log('GameEngineNotifier: Toggling pause. Current state: ${state.isPaused}');
    _commitGrid(state.grid, isPaused: !state.isPaused);
  }

  /// Restart the current level to its initial state
  void restartLevel() {
    Logger.log('GameEngineNotifier: Restarting level.');
    
    final currentLevel = state.currentLevel;
    if (currentLevel == null) {
      Logger.log('GameEngineNotifier: No current level to restart.');
      return;
    }

    // Clear state history when restarting
    _stateHistory.clear();
    
    // Recreate the initial grid from level definition
    final initialGrid = Grid(
      rows: currentLevel.rows, 
      cols: currentLevel.cols, 
      components: currentLevel.initialComponents.map((c) => c.copyWith()).toList()
    );
    
    // Reset to initial state
    state = GameEngineState.initial(currentLevel);
    
    _commitGrid(
      initialGrid, 
      isWin: false, 
      isPaused: false, 
      selectedComponentId: null,
      draggedComponentId: null,
      dragPosition: null,
    );
    
    Logger.log('GameEngineNotifier: Level restarted successfully.');
  }

  /// Undo the last action that changed game state
  void undo() {
    Logger.log('GameEngineNotifier: Attempting to undo last action.');
    
    if (_stateHistory.isEmpty) {
      Logger.log('GameEngineNotifier: No actions to undo.');
      return;
    }

    final previousState = _stateHistory.removeLast();
    state = previousState;
    
    // Re-evaluate grid to ensure consistency
    _commitGrid(state.grid);
    
    Logger.log('GameEngineNotifier: Undo successful. History size: ${_stateHistory.length}');
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  void _checkWinCondition() {
    Logger.log('GameEngineNotifier: Checking win condition.');
    final currentLevel = state.currentLevel;
    if (currentLevel == null) {
      Logger.log('GameEngineNotifier: No current level to check win condition.');
      return;
    }

    bool allGoalsMet = true;
    for (final goal in currentLevel.goals) {
      final behavior = goal.getBehavior<GoalCheckingBehavior>();
      if (behavior == null) {
        Logger.log('GameEngineNotifier: No GoalCheckingBehavior found for goal: ${goal.type}');
        allGoalsMet = false;
        break;
      }
      if (!behavior.isMet(state.grid, goal)) {
        Logger.log('GameEngineNotifier: Goal ${goal.type} not met.');
        allGoalsMet = false;
        break;
      }
    }

    if (allGoalsMet && !state.isWin) {
      state = state.copyWith(isWin: true);
      audioService.play(AppAssets.audioSuccess);
      Logger.log('GameEngineNotifier: Win condition met!');
    }
  }
}