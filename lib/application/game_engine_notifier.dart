import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'game_engine_state.dart';
import '../../infrastructure/audio/audio_service.dart';
import '../../common/logger.dart';
import 'services/simulation_service.dart';
import 'audio_manager.dart';
import 'input_manager.dart';
import 'animation_scheduler.dart';

import 'package:circuit_stem/domain/behaviors/behavior.dart';
import 'package:circuit_stem/application/game_context.dart';
import 'package:circuit_stem/application/use_cases/move_component_use_case.dart';
import 'package:uuid/uuid.dart';

class GameEngineNotifierV2 extends StateNotifier<GameEngineState> {
  final InputManager input;
  final AudioManager audio;
  final SimulationService simulation;
  final AnimationScheduler animationScheduler;

  GameEngineNotifierV2({
    required AudioService audioService,
    required this.animationScheduler,
  })  : input = InputManager(),
        audio = AudioManager(audioService),
        simulation = SimulationService(),
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
    state = GameEngineState.initial(level).copyWith(grid: grid, paletteComponents: level.paletteComponents);
  }

  void _handleTap(ComponentModel comp) {
    Logger.log('GameEngineNotifierV2: _handleTap called for component ${comp.id}');
    audio.playSelection(); // Keep initial audio for selection

    ComponentModel? updatedComponent;
    final gameContext = GameContext.from(state); // Create GameContext

    // Iterate through behaviors associated with the component
    // Assuming comp.behaviors now contains instances of ComponentBehavior
    for (final behavior in comp.behaviors.whereType<ComponentBehavior>()) {
      final result = behavior.handle(comp, 'tap', gameContext);
      if (result != null) {
        updatedComponent = result;
        // Trigger specific audio based on behavior type or component type
        // This can be refined later with an event bus if needed.
        if (behavior.behaviorType == 'interaction' && comp.type == 'switch') { 
            audio.playToggle(); 
        }
        break; // Assuming only one behavior handles a 'tap' action
      }
    }

    if (updatedComponent != null) {
      var newGrid = state.grid.copyWithUpdatedComponent(updatedComponent);
      newGrid = simulation.simulatePowerFlow(newGrid);
      state = state.copyWith(grid: newGrid);
    }

    // Tapping does not change the grid logic, only selection state
    // This line should probably be moved or removed if the interaction behavior handles selection
    state = state.copyWith(selectedComponentId: comp.id);
  }

  void _moveComponent(String id, int r, int c) {
    Logger.log('[_moveComponent] id: \$id, targetR: \$r, targetC: \$c');

    if (id.endsWith('_palette')) {
      // This is a component from the palette
      Logger.log('[_moveComponent] Attempting to find palette component with ID: $id');
      Logger.log('[_moveComponent] Current palette components IDs: ${state.paletteComponents.map((comp) => comp.id).join(', ')}');
      final paletteComponent = state.paletteComponents.firstWhere((c) => c.id == id);
      Logger.log('[_moveComponent] Found palette component: ${paletteComponent.id}');
      final newId = Uuid().v4();
      final newComponent = paletteComponent.copyWith(id: newId, r: r, c: c);

      final newPalette = state.paletteComponents.where((c) => c.id != id).toList();
      var newGrid = state.grid.copyWith(components: [...state.grid.components, newComponent]);
      newGrid = simulation.simulatePowerFlow(newGrid);

      audio.playPlacement();
      state = state.copyWith(grid: newGrid, paletteComponents: newPalette);
    } else {
      // This is a component already on the grid
      final useCase = MoveComponentUseCase(simulation);
      final newGrid = useCase.execute(
        state.grid,
        id,
        toRow: r,
        toCol: c,
      );

      if (newGrid == null) {
        Logger.log('[_moveComponent] Move failed for component \$id');
        return;
      }

      final loggedComp = newGrid.componentsById[id];
      Logger.log('[_moveComponent] Post-UseCase Coords: (${loggedComp?.r}, ${loggedComp?.c})');

      audio.playPlacement();
      state = state.copyWith(grid: newGrid);
    }
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