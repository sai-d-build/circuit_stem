import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:circuit_stem/models/level_definition.dart';
import 'package:circuit_stem/models/grid.dart';
import 'package:circuit_stem/models/component.dart';
import 'game_engine_state.dart';
import '../services/audio_service.dart';
import '../common/logger.dart';
import 'simulation_manager.dart';
import 'audio_manager.dart';
import 'input_manager.dart';
import '../behaviors/interaction_behavior.dart';

class GameEngineNotifierV2 extends StateNotifier<GameEngineState> {
  final InputManager input;
  final AudioManager audio;
  final SimulationManager simulation;

  GameEngineNotifierV2({
    required AudioService audioService,
  })  : input = InputManager(),
        audio = AudioManager(audioService),
        simulation = SimulationManager(),
        super(GameEngineState.empty()) {
    _init();
  }

  void _init() {
    input.onComponentTapped = _handleTap;
    input.onComponentMoved = _moveComponent;
  }

  // Public getters to encapsulate state
  Grid get grid => state.grid;
  LevelDefinition? get currentLevel => state.currentLevel;

  void loadLevel(LevelDefinition level) {
    var grid = Grid(
      rows: level.rows,
      cols: level.cols,
      components: level.initialComponents,
    );
    // Run an initial simulation
    grid = simulation.simulatePowerFlow(grid);
    state = GameEngineState.initial(level).copyWith(grid: grid);
  }

  void _handleTap(ComponentModel comp) {
    Logger.log('GameEngineNotifierV2: _handleTap called for component ${comp.id}');
    audio.playSelection();

    // Find the interaction behavior for the component and call its onTap
    final interactionBehavior = comp.behaviors.firstWhere(
      (b) => b is InteractionBehavior,
      orElse: () => null,
    );

    if (interactionBehavior != null) {
      (interactionBehavior as InteractionBehavior).onTap(this, comp);
    } else {
      Logger.log('No InteractionBehavior found for component: ${comp.id} of type ${comp.type}');
    }

    // Tapping does not change the grid logic, only selection state
    // This line should probably be moved or removed if the interaction behavior handles selection
    state = state.copyWith(selectedComponentId: comp.id);
  }

  void _moveComponent(String id, int r, int c) {
    Logger.log('[_moveComponent] id: \$id, targetR: \$r, targetC: \$c');
    final comp = state.grid.componentsById[id];
    if (comp == null) {
      Logger.log('[_moveComponent] Component with id \$id not found.');
      return;
    }

    final moved = comp.copyWith(r: r, c: c);
    var newGrid = state.grid.copyWithUpdatedComponent(moved);
    newGrid = simulation.simulatePowerFlow(newGrid);

    audio.playPlacement();
    state = state.copyWith(grid: newGrid);
    Logger.log('[_moveComponent] Component \$id moved to (\$r, \$c). Current state grid: \${state.grid.componentsById[id]?.r}, \${state.grid.componentsById[id]?.c}');
  }

  void updateComponent(ComponentModel component) {
    var newGrid = state.grid.copyWithUpdatedComponent(component);
    newGrid = simulation.simulatePowerFlow(newGrid);
    audio.playToggle(); // Assuming this is for switches
    state = state.copyWith(grid: newGrid);
  }

  void selectPaletteComponent(ComponentModel component) {
    audio.playSelection();
    state = state.copyWith(selectedComponentId: component.id);
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  // Methods that remain largely the same
  InputManager get inputManager => input;

  void restartLevel() {
    if (state.currentLevel != null) {
      loadLevel(state.currentLevel!);
    }
  }

  void undo() {
    Logger.log('Undo not yet implemented.');
  }
}
