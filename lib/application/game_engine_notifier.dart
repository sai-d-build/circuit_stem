Corrected lib/application/game_engine_notifier.dart
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
import 'use_cases/component_action.dart';
import 'use_cases/create_component_use_case.dart';
import 'use_cases/move_component_use_case.dart';
import 'use_cases/tap_component_use_case.dart';
import 'use_cases/restart_level_use_case.dart';
import 'use_cases/update_component_use_case.dart';
import 'use_cases/select_palette_component_use_case.dart';
import 'use_cases/simulate_power_flow_use_case.dart';
import 'use_cases/simulate_power_flow_action.dart';
import 'use_cases/check_win_condition_use_case.dart';
import 'use_cases/toggle_pause_use_case.dart';
import 'use_cases/undo_use_case.dart';
import 'use_cases/rotate_component_use_case.dart';
import 'use_cases/load_level_use_case.dart';
import 'middleware/middleware.dart';
import 'middleware/logging_middleware.dart';
import 'middleware/validation_middleware.dart';
import 'middleware/performance_middleware.dart';
import 'package:circuit_stem/application/services/component_factory.dart';
import 'core/result.dart';

class GameEngineNotifier extends StateNotifier<GameEngineState> {
  final InputManager input;
  final AudioManager audio;
  final AnimationScheduler animationScheduler;

  final CreateComponentFromTemplateUseCase _createUseCase;
  final MoveComponentUseCase _moveUseCase;
  final TapComponentUseCase _tapUseCase;
  final RestartLevelUseCase _restartLevelUseCase;
  final UpdateComponentUseCase _updateComponentUseCase;
  final SelectPaletteComponentUseCase _selectPaletteComponentUseCase;
  final SimulatePowerFlowUseCase _simulatePowerFlowUseCase;
  final CheckWinConditionUseCase _checkWinConditionUseCase;
  final TogglePauseUseCase _togglePauseUseCase;
  final UndoUseCase _undoUseCase;
  final RotateComponentUseCase _rotateUseCase;
  final LoadLevelUseCase _loadLevelUseCase;

  final List<GameEngineMiddleware> _middleware;

  GameEngineNotifier({
    required AudioService audioService,
    required this.animationScheduler,
    required LevelManagerNotifier levelManager,
  })  : input = InputManager(),
        audio = AudioManager(audioService),
        _createUseCase = CreateComponentFromTemplateUseCase(
          const PowerSimulationService(),
          const ComponentFactory(),
        ),
        _moveUseCase = const MoveComponentUseCase(PowerSimulationService()),
        _tapUseCase = const TapComponentUseCase(
          PowerSimulationService(),
          GoalCheckingService(),
        ),
        _restartLevelUseCase = RestartLevelUseCase(levelManager),
        _updateComponentUseCase = const UpdateComponentUseCase(
          PowerSimulationService(),
          GoalCheckingService(),
        ),
        _selectPaletteComponentUseCase = const SelectPaletteComponentUseCase(),
        _simulatePowerFlowUseCase = const SimulatePowerFlowUseCase(PowerSimulationService()),
        _checkWinConditionUseCase = const CheckWinConditionUseCase(GoalCheckingService()),
        _togglePauseUseCase = const TogglePauseUseCase(),
        _undoUseCase = const UndoUseCase(),
        _rotateUseCase = const RotateComponentUseCase(),
        _loadLevelUseCase = LoadLevelUseCase(
          const SimulatePowerFlowUseCase(PowerSimulationService()),
          const CheckWinConditionUseCase(GoalCheckingService()),
        ),
        _middleware = [
          ValidationMiddleware(),
          LoggingMiddleware(),
          PerformanceMiddleware(),
        ],
        super(GameEngineState.empty()) {
    _init();
  }

  void _init() {
    input.onComponentTapped = _handleTap;
    input.onComponentMoved = _moveComponent;
  }

  Grid get grid => state.grid;
  LevelDefinition? get currentLevel => state.currentLevel;
  bool get canUndo => state.history.isNotEmpty;
  bool get isGamePaused => state.isPaused;

  Future<void> loadLevel(LevelDefinition level) async {
    await executeAction(LoadLevelAction(level));
  }

  Future<void> executeAction(ComponentAction action) async {
    try {
      ComponentAction processedAction = action;
      for (final middleware in _middleware) {
        processedAction = await middleware.beforeAction(state, processedAction);
      }

      final oldState = state;
      final history = [...state.history, oldState];

      final result = await _executeUseCase(processedAction);

      if (result.isSuccess) {
        var newState = result.data!;

        if (_shouldRunSimulation(processedAction)) {
          final simulationResult = _simulatePowerFlowUseCase.execute(newState, const SimulatePowerFlowAction());
          if (simulationResult.isSuccess) {
            newState = newState.copyWith(grid: simulationResult.data!);
          }

          final winResult = _checkWinConditionUseCase.execute(newState, const CheckWinConditionAction());
          if (winResult.isSuccess && winResult.data! != newState.isWin) {
            newState = newState.copyWith(isWin: winResult.data!);
            if (winResult.data!) {
              audio.playSuccess();
            }
          }
        }

        if (processedAction is! UndoAction) {
          newState = newState.copyWith(history: history);
        }

        _playAudioForAction(processedAction, oldState, newState);

        state = newState;

        for (final middleware in _middleware) {
          state = await middleware.afterAction(oldState, state, processedAction);
        }
      } else {
        Logger.log('Action execution failed: ${result.error}');
      }
    } catch (e, s) {
      Logger.log('Action execution error', error: e, stackTrace: s);
    }
  }

  Future<Result<GameEngineState>> _executeUseCase(ComponentAction action) async {
    Result<GameEngineState> result;
    switch (action.runtimeType) {
      case LoadLevelAction:
        result = _loadLevelUseCase.execute(state, action as LoadLevelAction);
        break;
      case CreateComponentFromTemplateAction:
        result = _createUseCase.execute(state, action as CreateComponentFromTemplateAction);
        break;
      case RotateComponentAction:
        result = _rotateUseCase.execute(state, action as RotateComponentAction);
        break;
      case MoveComponentAction:
        result = _moveUseCase.execute(state, action as MoveComponentAction);
        break;
      case TapComponentAction:
        result = _tapUseCase.execute(state, action as TapComponentAction);
        break;
      case UpdateComponentAction:
        result = _updateComponentUseCase.execute(state, action as UpdateComponentAction);
        break;
      case RestartLevelAction:
        result = await _restartLevelUseCase.execute(state, action as RestartLevelAction);
        break;
      case SelectPaletteComponentAction:
        result = _selectPaletteComponentUseCase.execute(state, action as SelectPaletteComponentAction);
        break;
      case TogglePauseAction:
        result = _togglePauseUseCase.execute(state, action as TogglePauseAction);
        break;
      case UndoAction:
        result = _undoUseCase.execute(state, action as UndoAction);
        break;
      default:
        result = const Failure('Unknown action type');
    }
    return result;
  }

  void _playAudioForAction(ComponentAction action, GameEngineState oldState, GameEngineState newState) {
    if (action is CreateComponentFromTemplateAction || action is MoveComponentAction) {
      audio.playPlacement();
    } else if (action is TapComponentAction || action is RotateComponentAction) {
      if (oldState != newState) {
        audio.playToggle();
      }
    } else if (action is SelectPaletteComponentAction) {
      audio.playSelection();
    }
  }

  bool _shouldRunSimulation(ComponentAction action) {
    return action is! SelectPaletteComponentAction &&
        action is! TogglePauseAction &&
        action is! UndoAction;
  }

  void _handleTap(ComponentModel comp) {
    executeAction(TapComponentAction(componentId: comp.id));
  }

  void _moveComponent(String id, int r, int c) {
    if (id.endsWith('_palette')) {
      executeAction(CreateComponentFromTemplateAction(
        templateId: id,
        row: r,
        col: c,
      ));
    } else {
      executeAction(MoveComponentAction(
        componentId: id,
        newRow: r,
        newCol: c,
      ));
    }
  }

  void updateComponent(ComponentModel component) {
    executeAction(UpdateComponentAction(
      componentId: component.id,
      newState: component.state,
    ));
  }

  void selectPaletteComponent(ComponentModel component) {
    executeAction(SelectPaletteComponentAction(componentId: component.id));
  }

  void togglePause() {
    executeAction(const TogglePauseAction());
  }

  void restartLevel() {
    executeAction(const RestartLevelAction());
  }

  void undo() {
    executeAction(const UndoAction());
  }

  void rotateComponent(String componentId, int rotation) {
    executeAction(RotateComponentAction(
      componentId: componentId,
      rotation: rotation,
    ));
  }

  InputManager get inputManager => input;

  void toggleDebugOverlay() {
    state = state.copyWith(isDebugOverlayVisible: !state.isDebugOverlayVisible);
  }
}
