import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:circuit_stem/models/level_definition.dart';
import 'package:circuit_stem/models/grid.dart';
import 'package:circuit_stem/models/component.dart';
import 'game_engine_state.dart'; // Corrected import
import '../services/audio_service.dart';
import '../common/logger.dart';
import 'simulation_manager.dart';
import 'game_engine_core.dart';
import 'audio_manager.dart';
import 'input_manager.dart';

/// Orchestrator: Owns state and glues Core, Simulation, Input, and Audio.
class GameEngineNotifierV2 extends StateNotifier<GameEngineState> {
  final GameEngineCore core;
  final InputManager input;
  final AudioManager audio;
  late final SimulationManager _simulationManager; // Added

  GameEngineNotifierV2({
    required AudioService audioService,
    LevelDefinition? initialLevel,
  })  : _simulationManager = SimulationManager(this), // Instantiate here
        core = GameEngineCore(_simulationManager), // Pass to GameEngineCore
        audio = AudioManager(audioService),
        input = InputManager(
          onComponentTapped: (comp) {},
          onComponentMoved: (id, r, c) {},
        ),
        super(GameEngineState.empty()) {
    _init(initialLevel);
  }

  void _init(LevelDefinition? initialLevel) {
    input.onComponentTapped = _handleTap;
    input.onComponentMoved = _moveComponent;

    if (initialLevel != null) {
      loadLevel(initialLevel);
    }
  }

  void loadLevel(LevelDefinition level) {
    final grid = Grid(
      rows: level.rows,
      cols: level.cols,
      components: level.initialComponents,
    );
    state = GameEngineState.initial(level);
    state = core.commit(state, grid, isWin: false, isPaused: false);
  }

  void _handleTap(ComponentModel comp) {
    audio.playSelection();
    state = core.commit(state, state.grid,
        selectedComponentId: comp.id, isPaused: state.isPaused);
  }

  void _moveComponent(String id, int r, int c) {
    final comp = state.grid.componentsById[id];
    if (comp == null) return;
    final moved = comp.copyWith(r: r, c: c);
    final newGrid = state.grid.copyWithUpdatedComponent(moved);
    audio.playPlacement();
    state = core.commit(state, newGrid);
  }

  // Public method to move components
  void moveComponent(String id, int r, int c) => _moveComponent(id, r, c);

  // Public method to update components
  void updateComponent(ComponentModel component) {
    final updatedGrid = state.grid.copyWithUpdatedComponent(component);
    state = core.commit(state, updatedGrid);
  }

  // Public method to update the grid
  void updateGrid(Grid newGrid) {
    state = state.copyWith(grid: newGrid);
  }

  InputManager get inputManager => input;

  void reset() {
    if (state.currentLevel == null) return; // Changed state.level to state.currentLevel
    loadLevel(state.currentLevel!); // Changed state.level to state.currentLevel
  }

  void selectPaletteComponent(ComponentModel comp) {
    audio.playSelection();
    state = core.commit(state, state.grid,
        selectedComponentId: comp.id, isPaused: state.isPaused);
  }

  void restartLevel() {
    reset();
  }

  void undo() {
    // Placeholder for undo logic, will interact with GameEngineCore
    Logger.log('Undo not yet implemented.');
  }

  void togglePause() {
    state = core.commit(state, state.grid, isPaused: !state.isPaused);
  }
}