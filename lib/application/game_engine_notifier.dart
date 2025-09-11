import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sparkcircuit/domain/entities/entities.dart';

// Application layer
import 'game_engine_state.dart';
import '../infrastructure/audio/audio_service.dart';
import '../common/logger.dart';
import 'audio_manager.dart';
import 'input_manager.dart';
import 'animation_scheduler.dart';
import 'transaction.dart';
import 'services/component_palette_manager.dart';

import 'use_cases/component_action.dart';

// Middleware
import 'middleware/middleware.dart';
import 'middleware/logging_middleware.dart';
import 'middleware/validation_middleware.dart';
import 'middleware/performance_middleware.dart';

// Core
import 'core/result.dart';

import 'use_cases/notifier_integrated_use_case.dart';

class GameEngineNotifier extends StateNotifier<GameEngineState> {
  final InputManager input;
  final AudioManager audio;
  final AnimationScheduler animationScheduler;

  final List<GameEngineMiddleware> _middleware;

  // ✅ INJECTED: No longer using ref.read() - dependencies injected directly
  final dynamic gridNotifier;
  final dynamic historyNotifier;
  final dynamic progressNotifier;
  final dynamic selectionNotifier;
  final dynamic interactionNotifier;
  final dynamic paletteManager;

  // ✅ INJECTED: Use case instances injected directly
  final dynamic loadLevelUseCase;
  final dynamic createComponentUseCase;
  final dynamic rotateComponentUseCase;
  final dynamic moveComponentUseCase;
  final dynamic tapComponentUseCase;
  final dynamic updateComponentUseCase;
  final dynamic restartLevelUseCase;
  final dynamic selectPaletteComponentUseCase;
  final dynamic togglePauseUseCase;
  final dynamic undoUseCase;

  GameEngineNotifier({
    required AudioService audioService,
    required this.animationScheduler,
    required this.gridNotifier,
    required this.historyNotifier,
    required this.progressNotifier,
    required this.selectionNotifier,
    required this.interactionNotifier,
    required this.paletteManager,
    required this.loadLevelUseCase,
    required this.createComponentUseCase,
    required this.rotateComponentUseCase,
    required this.moveComponentUseCase,
    required this.tapComponentUseCase,
    required this.updateComponentUseCase,
    required this.restartLevelUseCase,
    required this.selectPaletteComponentUseCase,
    required this.togglePauseUseCase,
    required this.undoUseCase,
  })  : input = InputManager(),
        audio = AudioManager(),
        _middleware = [
          ValidationMiddleware(),
          const LoggingMiddleware(),
          const PerformanceMiddleware(),
        ],
        super(GameEngineState(
          grid: Grid(rows: 0, cols: 0, components: {}),
          isPaused: false,
          isWin: false,
          lastUpdated: DateTime.now(),
          isDebugOverlayVisible: false,
          paletteManager: const ComponentPaletteManager(availableTemplates: []),
        )) {
    _init();
  }


  Map<String, dynamic> _getUseCaseInstances() {
    // ✅ RETURN: Map of injected use case instances
    return {
      '_loadLevelUseCase': loadLevelUseCase,
      '_createComponentUseCase': createComponentUseCase,
      '_rotateComponentUseCase': rotateComponentUseCase,
      '_moveComponentUseCase': moveComponentUseCase,
      '_tapComponentUseCase': tapComponentUseCase,
      '_updateComponentUseCase': updateComponentUseCase,
      '_restartLevelUseCase': restartLevelUseCase,
      '_selectPaletteComponentUseCase': selectPaletteComponentUseCase,
      '_togglePauseUseCase': togglePauseUseCase,
      '_undoUseCase': undoUseCase,
    };
  }

  void _init() {
    input.onComponentTapped = _handleTap;
    input.onComponentMoved = _moveComponent;
  }

  Grid get grid => state.grid;
  LevelDefinition? get currentLevel => state.currentLevel;
  bool get canUndo => state.history.isNotEmpty;
  bool get isGamePaused => state.isPaused;

  Future<Result<void>> loadLevel(LevelDefinition level) async {
    return await executeAction(LoadLevelAction(level));
  }

  Future<Result<void>> executeAction(ComponentAction action) async {
    final transaction = GameTransaction();
    final notifierContext = _createNotifierContext();

    try {
      ComponentAction processedAction = action;

      // Middleware beforeAction
      for (final middleware in _middleware) {
        processedAction = await middleware.beforeAction(state, processedAction);
      }

      final result = await _executeUseCase(processedAction, notifierContext, transaction);

      return result.fold(
        (_) async {
          await transaction.commit();
          // Middleware afterAction
          for (final middleware in _middleware) {
            state = await middleware.afterAction(state, state, processedAction);
          }
          return const Success(null);
        },
        (error) async {
          transaction.rollback();
          Logger.log('Action execution failed: $error');
          return Failure(error);
        },
      );
    } catch (e, s) {
      transaction.rollback();
      Logger.log('Action execution error: $e\n$s');
      return Failure('Action execution error: $e');
    }
  }

  Future<Result<void>> _executeUseCase(
      ComponentAction action, NotifierContext context, GameTransaction transaction) async {
    // ✅ OPTIMIZED: Use injected use case instances
    final useCases = _getUseCaseInstances();
    switch (action.runtimeType) {
      case LoadLevelAction _:
        return useCases['_loadLevelUseCase']?.executeWithNotifiers(action as LoadLevelAction, context, transaction) ??
               const Failure('Load level use case not available');
      case CreateComponentFromTemplateAction _:
        return useCases['_createComponentUseCase']?.executeWithNotifiers(action as CreateComponentFromTemplateAction, context, transaction) ??
               const Failure('Create component use case not available');
      case RotateComponentAction _:
        return useCases['_rotateComponentUseCase']?.executeWithNotifiers(action as RotateComponentAction, context, transaction) ??
               const Failure('Rotate component use case not available');
      case MoveComponentAction _:
        return useCases['_moveComponentUseCase']?.executeWithNotifiers(action as MoveComponentAction, context, transaction) ??
               const Failure('Move component use case not available');
      case TapComponentAction _:
        return useCases['_tapComponentUseCase']?.executeWithNotifiers(action as TapComponentAction, context, transaction) ??
               const Failure('Tap component use case not available');
      case UpdateComponentAction _:
        return useCases['_updateComponentUseCase']?.executeWithNotifiers(action as UpdateComponentAction, context, transaction) ??
               const Failure('Update component use case not available');
      case RestartLevelAction _:
        return useCases['_restartLevelUseCase']?.executeWithNotifiers(action as RestartLevelAction, context, transaction) ??
               const Failure('Restart level use case not available');
      case SelectPaletteComponentAction _:
        return useCases['_selectPaletteComponentUseCase']?.executeWithNotifiers(action as SelectPaletteComponentAction, context, transaction) ??
               const Failure('Select palette component use case not available');
      case TogglePauseAction _:
        return useCases['_togglePauseUseCase']?.executeWithNotifiers(action as TogglePauseAction, context, transaction) ??
               const Failure('Toggle pause use case not available');
      case UndoAction _:
        return useCases['_undoUseCase']?.executeWithNotifiers(action as UndoAction, context, transaction) ??
               const Failure('Undo use case not available');
      default:
        return const Failure('Unknown action type');
    }
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
      newState: {'state': component.state.name},
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

  Future<void> undo() async {
    await executeAction(const UndoAction());
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

  NotifierContext _createNotifierContext() {
    // ✅ DECOUPLED: Using injected notifier instances
    return NotifierContext(
      grid: gridNotifier,
      history: historyNotifier,
      progress: progressNotifier,
      selection: selectionNotifier,
      interaction: interactionNotifier,
      paletteManager: paletteManager,
    );
  }
}