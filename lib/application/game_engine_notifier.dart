// lib/application/game_engine_notifier.dart (Fully Refactored)
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

// Use Cases
import 'use_cases/component_action.dart';
import 'use_cases/create_component_use_case.dart';
import 'use_cases/move_component_use_case.dart';
import 'use_cases/tap_component_use_case.dart';
import 'use_cases/restart_level_use_case.dart';
import 'use_cases/update_component_use_case.dart';
import 'use_cases/select_palette_component_use_case.dart';
import 'use_cases/simulate_power_flow_use_case.dart';
import 'use_cases/check_win_condition_use_case.dart';
import 'use_cases/toggle_pause_use_case.dart';
import 'use_cases/undo_use_case.dart';
import 'use_cases/rotate_component_use_case.dart';
import 'use_cases/load_level_use_case.dart';

// Middleware
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
  
  final Logger _logger;

  // Use Cases
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

  // Middleware
  final List<GameEngineMiddleware> _middleware;

  GameEngineNotifier({
    required AudioService audioService,
    required this.animationScheduler,
    required LevelManagerNotifier levelManager,
    required Logger logger,
  })  : input = InputManager(),
        audio = AudioManager(audioService),
        
        
        
        _logger = logger,
        _createUseCase = CreateComponentFromTemplateUseCase(
          const PowerSimulationService(), 
          const ComponentFactory()
        ),
        _moveUseCase = const MoveComponentUseCase(const PowerSimulationService()),
        _tapUseCase = const TapComponentUseCase(
          const PowerSimulationService(), 
          const GoalCheckingService()
        ),
        _restartLevelUseCase = RestartLevelUseCase(levelManager),
        _updateComponentUseCase = const UpdateComponentUseCase(
          const PowerSimulationService(), 
          const GoalCheckingService()
        ),
        _selectPaletteComponentUseCase = const SelectPaletteComponentUseCase(),
        _simulatePowerFlowUseCase = const SimulatePowerFlowUseCase(const PowerSimulationService()),
        _checkWinConditionUseCase = const CheckWinConditionUseCase(const GoalCheckingService()),
        _togglePauseUseCase = const TogglePauseUseCase(),
        _undoUseCase = const UndoUseCase(),
        _rotateUseCase = const RotateComponentUseCase(),
        _loadLevelUseCase = LoadLevelUseCase(
          const SimulatePowerFlowUseCase(const PowerSimulationService()),
          const CheckWinConditionUseCase(const GoalCheckingService()),
        ),
        _middleware = [
          ValidationMiddleware(),
          LoggingMiddleware(logger),
          PerformanceMiddleware(logger),
        ],
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
  bool get canUndo => state.history.isNotEmpty;
  bool get isGamePaused => state.isPaused;

  Future<void> loadLevel(LevelDefinition level) async {
    await executeAction(LoadLevelAction(level));
  }

  Future<void> executeAction(ComponentAction action) async {
    try {
      // Apply middleware before action
      ComponentAction processedAction = action;
      for (final middleware in _middleware) {
        processedAction = await middleware.beforeAction(state, processedAction);
      }

      final oldState = state;
      final history = [...state.history, state];
      GameEngineState newState = state;

      // Execute the appropriate use case
      final Result<GameEngineState> result = await _executeUseCase(processedAction);
      
      // Explicitly cast to help the analyzer
      final typedResult = result as Result<GameEngineState>;

      if (typedResult.isSuccess) {
        newState = typedResult.data!;
        
        // Always run power simulation after state-changing actions
        if (_shouldRunSimulation(processedAction)) {
          final simulationResult = _simulatePowerFlowUseCase.execute(
            newState,
            const SimulatePowerFlowAction()
          );
          
          if (simulationResult.isSuccess) {
            newState = newState.copyWith(grid: simulationResult.data!);
          }
        }

        // Check win condition after simulation
        if (_shouldCheckWinCondition(processedAction)) {
          final winResult = _checkWinConditionUseCase.execute(
            newState,
            const CheckWinConditionAction()
          );
          
          if (winResult.isSuccess && winResult.data! != newState.isWin) {
            newState = newState.copyWith(isWin: winResult.data!);
            
            if (winResult.data!) {
              _playSuccessSound();
            }
          }
        }

        // Add to history for non-history actions
        if (processedAction is! UndoAction) {
          newState = newState.copyWith(history: history);
        }

        // Play appropriate audio feedback
        _playAudioForAction(processedAction, oldState, newState);

        state = newState;

        // Apply middleware after action
        for (final middleware in _middleware) {
          state = await middleware.afterAction(oldState, state, processedAction);
        }
        
      } else {
        _logger.warning('Action execution failed', {
          'action': processedAction.type,
          'error': typedResult.error,
        });
      }

    } catch (e) {
      _logger.error('Action execution error', {
        'action': action.type,
        'error': e.toString(),
      });
    }
  }

  Result<GameEngineState> _executeUseCase(ComponentAction action) {
    try {
      if (action is LoadLevelAction) {
        return _loadLevelUseCase.execute(state, action);
      } else if (action is CreateComponentFromTemplateAction) {
        final result = await _createUseCase.execute(state, action);
        return result.isSuccess 
          ? Success(result.data!) 
          : Failure(result.error!);
      } else if (action is RotateComponentAction) {
        final result = await _rotateUseCase.execute(state, action);
        return result.isSuccess 
          ? Success(result.data!) 
          : Failure(result.error!); 
      } else if (action is MoveComponentAction) {
        final result = await _moveUseCase.execute(state, action);
        return result.isSuccess 
          ? Success(state.copyWith(grid: result.data!)) 
          : Failure(result.error!);
      } else if (action is TapComponentAction) {
        final result = await _tapUseCase.execute(state, action);
        return result.isSuccess 
          ? Success(result.data!) 
          : Failure(result.error!);
      } else if (action is UpdateComponentAction) {
        final result = await _updateComponentUseCase.execute(state, action);
        return result.isSuccess 
          ? Success(result.data!) 
          : Failure(result.error!);
      } else if (action is RestartLevelAction) {
        final result = await _restartLevelUseCase.execute(state, action);
        return result.isSuccess 
          ? Success(result.data!) 
          : Failure(result.error!);
      } else if (action is SelectPaletteComponentAction) {
        final result = await _selectPaletteComponentUseCase.execute(state, action);
        return result.isSuccess 
          ? Success(result.data!) 
          : Failure(result.error!);
      } else if (action is TogglePauseAction) {
        final result = await _togglePauseUseCase.execute(state, action);
        return result.isSuccess 
          ? Success(result.data!) 
          : Failure(result.error!);
      } else if (action is UndoAction) {
        final result = await _undoUseCase.execute(state, action);
        return result.isSuccess 
          ? Success(result.data!) 
          : Failure(result.error!);
      } else {
        return const Failure('Unknown action type');
      }
    } catch (e) {
      return Failure(e.toString());
    }
  }

  

  

  

  

  // Input event handlers
  void _handleTap(ComponentModel comp) {
    executeAction(TapComponentAction(componentId: comp.id));
  }

  void _moveComponent(String id, int r, int c) {
    if (id.endsWith('_palette')) {
      executeAction(CreateComponentFromTemplateAction(
        templateId: id, 
        row: r, 
        col: c
      ));
    } else {
      executeAction(MoveComponentAction(
        componentId: id,
        newRow: r,
        newCol: c,
      ));
    }
  }

  // Public API methods (all now use action system)
  void updateComponent(ComponentModel component) {
    executeAction(UpdateComponentAction(
      componentId: component.id, 
      newState: component.state
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

  // Getters for managers (backward compatibility)
  InputManager get inputManager => input;
}
