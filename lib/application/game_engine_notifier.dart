import 'package:flutter_riverpod/flutter_riverpod.dart';

// Domain entities
import '../domain/entities/level_definition.dart';
import '../domain/entities/grid.dart';
import '../domain/entities/component.dart';

// Application layer
import 'game_engine_state.dart';
import '../infrastructure/audio/audio_service.dart';
import '../common/logger.dart';
import 'audio_manager.dart';
import 'input_manager.dart';
import 'animation_scheduler.dart';
import 'transaction.dart';

// V2 Use Cases
import 'use_cases/component_action.dart';
import 'use_cases/providers.dart';

// Middleware
import 'middleware/middleware.dart';
import 'middleware/logging_middleware.dart';
import 'middleware/validation_middleware.dart';
import 'middleware/performance_middleware.dart';

// Core
import 'core/result.dart';
import 'grid_notifier.dart';
import 'history_notifier.dart';
import 'game_progress_notifier.dart';
import 'component_selection_notifier.dart';
import 'interaction_state_notifier.dart';

import 'use_cases/notifier_integrated_use_case.dart';

class GameEngineNotifier extends StateNotifier<GameEngineState> {
  final InputManager input;
  final AudioManager audio;
  final AnimationScheduler animationScheduler;
  final Ref ref;

  final List<GameEngineMiddleware> _middleware;

  GameEngineNotifier({
    required AudioService audioService,
    required this.animationScheduler,
    required this.ref,
  })  : input = InputManager(),
        audio = AudioManager(audioService),
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
          interactionState: InteractionState.initial(),
          history: HistoryState.initial(),
        )) {
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

  Future<Result<void>> loadLevel(LevelDefinition level) async {
    return await executeAction(LoadLevelAction(level));
  }

  Future<Result<void>> executeAction(ComponentAction action) async {
    final transaction = GameTransaction();
    final notifierContext = NotifierContext(
      grid: ref.read(gridNotifierProvider.notifier),
      history: ref.read(historyNotifierProvider.notifier),
      progress: ref.read(gameProgressNotifierProvider.notifier),
      selection: ref.read(componentSelectionNotifierProvider.notifier),
      interaction: ref.read(interactionStateNotifierProvider.notifier),
      paletteManager: ref.read(componentPaletteManagerProvider),
    );

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
          await transaction.rollback();
          Logger.log('Action execution failed: $error');
          return Failure(error);
        },
      );
    } catch (e, s) {
      await transaction.rollback();
      Logger.log('Action execution error: $e\n$s');
      return Failure('Action execution error: $e');
    }
  }

  Future<Result<void>> _executeUseCase(
      ComponentAction action, NotifierContext context, GameTransaction transaction) async {
    switch (action.runtimeType) {
      case LoadLevelAction _:
        return ref.read(loadLevelUseCaseV2Provider).executeWithNotifiers(action as LoadLevelAction, context, transaction);
      case CreateComponentFromTemplateAction _:
        return ref.read(createComponentUseCaseV2Provider).executeWithNotifiers(action as CreateComponentFromTemplateAction, context, transaction);
      case RotateComponentAction _:
        return ref.read(rotateComponentUseCaseV2Provider).executeWithNotifiers(action as RotateComponentAction, context, transaction);
      case MoveComponentAction _:
        return ref.read(moveComponentUseCaseV2Provider).executeWithNotifiers(action as MoveComponentAction, context, transaction);
      case TapComponentAction _:
        return ref.read(tapComponentUseCaseV2Provider).executeWithNotifiers(action as TapComponentAction, context, transaction);
      case UpdateComponentAction _:
        return ref.read(updateComponentUseCaseV2Provider).executeWithNotifiers(action as UpdateComponentAction, context, transaction);
      case RestartLevelAction _:
        return ref.read(restartLevelUseCaseV2Provider).executeWithNotifiers(action as RestartLevelAction, context, transaction);
      case SelectPaletteComponentAction _:
        return ref.read(selectPaletteComponentUseCaseV2Provider).executeWithNotifiers(action as SelectPaletteComponentAction, context, transaction);
      case TogglePauseAction _:
        return ref.read(togglePauseUseCaseV2Provider).executeWithNotifiers(action as TogglePauseAction, context, transaction);
      case UndoAction _:
        return ref.read(undoUseCaseV2Provider).executeWithNotifiers(action as UndoAction, context, transaction);
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
}