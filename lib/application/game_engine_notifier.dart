import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'game_engine_state.dart';
import '../../infrastructure/audio/audio_service.dart';
import '../../common/logger.dart';
import 'services/power_simulation_service.dart';
import 'services/goal_checking_service.dart';
import 'audio_manager.dart';
import 'input_manager.dart';
import 'animation_scheduler.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';

import 'package:circuit_stem/domain/behaviors/behavior.dart';
import 'package:circuit_stem/application/game_context.dart';
import 'package:circuit_stem/application/use_cases/move_component_use_case.dart';
import 'package:circuit_stem/application/use_cases/create_component_use_case.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/application/services/component_factory.dart';

import 'package:circuit_stem/application/use_cases/tap_component_use_case.dart';
import 'package:circuit_stem/application/use_cases/restart_level_use_case.dart';
import 'package:circuit_stem/application/use_cases/update_component_use_case.dart';
import 'package:circuit_stem/application/use_cases/select_palette_component_use_case.dart';

class GameEngineNotifier extends StateNotifier<GameEngineState> {
  final InputManager input;
  final AudioManager audio;
  final PowerSimulationService simulation;
  final GoalCheckingService _goalChecker;
  final AnimationScheduler animationScheduler;
  final LevelManagerNotifier _levelManager;

  // Use Cases
  final CreateComponentFromTemplateUseCase _createUseCase;
  final MoveComponentUseCase _moveUseCase;
  final TapComponentUseCase _tapUseCase;
  final RestartLevelUseCase _restartLevelUseCase;
  final UpdateComponentUseCase _updateComponentUseCase;
  final SelectPaletteComponentUseCase _selectPaletteComponentUseCase;
  final ComponentFactory _factory;

  final bool _useNewSystem = true; // FEATURE FLAG

  GameEngineNotifier({
    required AudioService audioService,
    required this.animationScheduler,
    required LevelManagerNotifier levelManager,
  })  : input = InputManager(),
        audio = AudioManager(audioService),
        simulation = const PowerSimulationService(),
        _goalChecker = const GoalCheckingService(),
        _levelManager = levelManager,
        _factory = const ComponentFactory(),
        _createUseCase = CreateComponentFromTemplateAction(const PowerSimulationService(), const ComponentFactory()),
        _moveUseCase = MoveComponentUseCase(const PowerSimulationService()),
        _tapUseCase = TapComponentUseCase(const PowerSimulationService(), const GoalCheckingService()),
        _restartLevelUseCase = RestartLevelUseCase(levelManager),
        _updateComponentUseCase = UpdateComponentUseCase(const PowerSimulationService(), const GoalCheckingService()),
        _selectPaletteComponentUseCase = const SelectPaletteComponentUseCase(),
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
    grid = _runPowerSimulation(grid);
    _checkWinCondition(grid);
    state = GameEngineState.initial(level).copyWith(grid: grid, paletteComponents: level.paletteComponents);
  }

  Grid _runPowerSimulation(Grid grid) {
    return simulation.simulatePowerFlow(grid);
  }

  void _checkWinCondition(Grid grid) {
    if (state.currentLevel != null) {
      final isComplete = _goalChecker.isLevelComplete(grid, state.currentLevel!);
      if (isComplete != state.isWin) {
        state = state.copyWith(isWin: isComplete);
        if (isComplete) {
          // audio.playSuccess();
        }
      }
    }
  }

  void executeAction(ComponentAction action) {
    if (!_useNewSystem) return;

    final history = [...state.history, state];

    GameEngineState newState = state;
    if (action is CreateComponentFromTemplateAction) {
      newState = _createUseCase.execute(state, action);
      audio.playPlacement();
    } else if (action is RotateComponentAction) {
      final component = state.grid.componentsById[action.componentId];
      if (component != null) {
        final updatedComponent = component.copyWith(rotation: action.rotation);
        var newGrid = state.grid.copyWithUpdatedComponent(updatedComponent);
        newGrid = _runPowerSimulation(newGrid);
        _checkWinCondition(newGrid);
        newState = state.copyWith(grid: newGrid);
        audio.playToggle();
      }
    } else if (action is MoveComponentAction) {
      final newGrid = _moveUseCase.execute(state.grid, action.componentId, toRow: action.newRow, toCol: action.newCol);
      if (newGrid != null) {
        audio.playPlacement();
        newState = state.copyWith(grid: newGrid);
      }
    } else if (action is TapComponentAction) {
      newState = _tapUseCase.execute(state, action);
      // Determine if audio should play based on the change in state from the use case
      // For now, we'll assume a toggle sound if the state changed.
      if (newState != state) {
        audio.playToggle();
      }
    } else if (action is RestartLevelAction) {
      newState = await _restartLevelUseCase.execute(state, action);
    }

    state = newState.copyWith(history: history);
  }

  void _handleTap(ComponentModel comp) {
    executeAction(TapComponentAction(componentId: comp.id));
  }

  void _moveComponent(String id, int r, int c) {
    if (_useNewSystem) {
      if (id.endsWith('_palette')) {
        executeAction(CreateComponentFromTemplateAction(templateId: id, row: r, col: c));
      }
    }
  }

  void updateComponent(ComponentModel component) {
    executeAction(UpdateComponentAction(componentId: component.id, newState: component.state));
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
    executeAction(const RestartLevelAction());
  }

  void undo() {
    if (state.history.isNotEmpty) {
      state = state.history.last;
    }
  }
}