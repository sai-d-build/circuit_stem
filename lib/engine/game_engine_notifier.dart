import 'package:flutter/material.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:collection/collection.dart';
import '../models/level_definition.dart';
import '../models/grid.dart';
import '../models/component.dart';

import 'render_state.dart';
import '../services/audio_service.dart';
import 'animation_scheduler.dart';
import '../common/logger.dart';
import '../common/constants.dart';
import '../models/goal.dart';
import 'game_engine_state.dart';
import '../common/assets.dart';

/// GameEngineNotifier: Immutable state management for the game engine
class GameEngineNotifier extends StateNotifier<GameEngineState> {
  final LogicEngine _logicEngine;
  final AudioService _audioService;
  @visibleForTesting
  final AnimationScheduler animationScheduler;
  final void Function(EvaluationResult)? onEvaluate;
  final VoidCallback? onWin;

  GameEngineNotifier({
    LevelDefinition? initialLevel,
    this.onEvaluate,
    this.onWin,
    LogicEngine? logicEngine,
    AudioService? audioService,
    AnimationScheduler? animationScheduler,
  }) : _logicEngine = logicEngine ?? LogicEngine(),
       _audioService = audioService ?? AudioService(),
       animationScheduler = animationScheduler ?? AnimationScheduler(),
       super(GameEngineState.initial(initialLevel)) {
    _initializeEngine(initialLevel);
  }

  GameEngineNotifier.forNoLevel({
    this.onEvaluate,
    this.onWin,
    LogicEngine? logicEngine,
    AudioService? audioService,
    AnimationScheduler? animationScheduler,
  }) : _logicEngine = logicEngine ?? LogicEngine(),
       _audioService = audioService ?? AudioService(),
       animationScheduler = animationScheduler ?? AnimationScheduler(),
       super(GameEngineState.initial(null));

  void _initializeEngine(LevelDefinition? initialLevel) {
    animationScheduler.addCallback((dt) {
      if (!state.isPaused) {
        _evaluateAndUpdateRenderState();
      }
    });
    if (initialLevel != null) {
      loadLevel(initialLevel);
    }
  }

  void loadLevel(LevelDefinition level) {
    Logger.log('GameEngine: Loading new level ${level.id}');
    Logger.log('GameEngine: Initial components from LevelDefinition: ${level.initialComponents}');
    animationScheduler.reset();

    final initialComponentsMap = <String, ComponentModel>{};
    for (final comp in level.initialComponents) {
      initialComponentsMap[comp.id] = comp;
    }

    state = GameEngineState(
      currentLevel: level,
      grid: Grid(rows: level.rows, cols: level.cols, componentsById: initialComponentsMap),
      isPaused: false,
      isWin: false,
      paletteComponents: level.paletteComponents,
    );

    _evaluateAndUpdateRenderState();
    Logger.log('GameEngine: Level setup complete.');
  }

  void _evaluateAndUpdateRenderState() {
    if (state.currentLevel == null) return;

    final evalResult = _logicEngine.evaluate(state.grid);
    final newRenderState = RenderState.fromEvaluation(
      grid: state.grid,
      eval: evalResult,
      bulbIntensity: animationScheduler.bulbIntensity,
      wireOffset: animationScheduler.wireOffset,
      draggedComponentId: state.draggedComponentId,
      dragPosition: state.dragPosition,
    );

    final currentPoweredBuzzers = state.grid.componentsById.values
        .where((c) =>
            c.type == "Component.Buzzer" &&
            evalResult.poweredComponentIds.contains(c.id))
        .map((c) => c.id)
        .toSet();

    final newlyPoweredBuzzers = currentPoweredBuzzers.difference(state.poweredBuzzerIds);

    for (final _ in newlyPoweredBuzzers) {
      _audioService.play(AppAssets.audioToggle);
    }

    state = state.copyWith(
      renderState: newRenderState,
      isShortCircuit: evalResult.isShortCircuit,
      poweredBuzzerIds: currentPoweredBuzzers,
    );

    onEvaluate?.call(evalResult);
    _checkWinCondition(evalResult);
  }

  void _checkWinCondition() {
    if (state.currentLevel == null || state.isWin || state.isShortCircuit) return;

    bool allGoalsMet = true;
    for (final goal in state.currentLevel!.goals) {
      final checker = goal.getBehavior<GoalCheckingBehavior>();
      if (checker != null) {
        if (!checker.isMet(state)) {
          allGoalsMet = false;
          break;
        }
      } else {
        // Legacy goal checking for now
        Logger.log('Warning: Goal type ${goal.type} does not have a behavior.');
        allGoalsMet = false; // Or handle with old _isGoalMet
        break;
      }
    }

    if (allGoalsMet) {
      state = state.copyWith(isWin: true);
      _audioService.play(AppAssets.audioSuccess);
      onWin?.call();
      Logger.log('GameEngine: Win condition met!');
    }
  }

  void setPaused(bool paused) {
    if (state.isPaused == paused) return;
    state = state.copyWith(isPaused: paused);
    if (paused) {
      animationScheduler.pause();
    } else {
      animationScheduler.resume();
    }
  }

  void togglePause() => setPaused(!state.isPaused);

  void startDrag(String componentId, Offset position) {
    final component = state.grid.componentsById[componentId];
    Logger.log('GameEngineNotifier: startDrag for component $componentId of type ${component?.type}');
    state = state.copyWith(draggedComponentId: componentId, dragPosition: position);
  }

  void updateDrag(String componentId, Offset position) {
    if (state.draggedComponentId != componentId) return;
    state = state.copyWith(dragPosition: position);
    _evaluateAndUpdateRenderState();
  }

  void endDrag(String componentId) {
    Logger.log('GameEngineNotifier: endDrag for component $componentId');
    if (state.draggedComponentId != componentId || state.dragPosition == null) {
      state = state.copyWith(draggedComponentId: null, dragPosition: null);
      return;
    }

    final newCol = (state.dragPosition!.dx / cellSize).floor();
    final newRow = (state.dragPosition!.dy / cellSize).floor();
    Logger.log('GameEngineNotifier: new position ($newRow, $newCol)');

    final componentToMove = state.grid.componentsById[componentId];
    if (componentToMove != null) {
      // Create a temporary grid without the component being moved to check for collisions
      final tempComponents = Map<String, ComponentModel>.from(state.grid.componentsById);
      tempComponents.remove(componentId);
      final tempGrid = state.grid.copyWith(componentsById: tempComponents);

      if (tempGrid.canPlaceComponent(componentToMove, newRow, newCol)) {
        Logger.log('GameEngineNotifier: new position is valid');
        final newComponent = componentToMove.copyWith(r: newRow, c: newCol);
        final newComponents = Map<String, ComponentModel>.from(state.grid.componentsById);
        newComponents[componentId] = newComponent;
        state = state.copyWith(
          grid: state.grid.copyWith(componentsById: newComponents),
          draggedComponentId: null,
          dragPosition: null,
        );
      } else {
        Logger.log('GameEngineNotifier: new position is invalid');
        _audioService.play(AppAssets.audioWarning);
        state = state.copyWith(draggedComponentId: null, dragPosition: null);
      }
    } else {
      state = state.copyWith(draggedComponentId: null, dragPosition: null);
    }

    _evaluateAndUpdateRenderState();
  }

  void toggleSwitch(String componentId) {
    final component = state.grid.componentsById[componentId];
    if (component == null || component.type != ComponentType.sw) return;

    final currentState = component.state['closed'] as bool? ?? false;
    final newComponentState = Map<String, dynamic>.from(component.state);
    newComponentState['closed'] = !currentState;

    final updatedComponent = component.copyWith(state: newComponentState);
    final newComponents = Map<String, ComponentModel>.from(state.grid.componentsById);
    newComponents[componentId] = updatedComponent;

    state = state.copyWith(grid: state.grid.copyWith(componentsById: newComponents));
    _audioService.play(AppAssets.audioToggle);
    _evaluateAndUpdateRenderState();
  }

  void handleTap(int r, int c) {
    final component = state.grid.componentsAt(r, c).firstOrNull;
    if (component != null) {
      if (component.type == ComponentType.sw) {
        toggleSwitch(component.id);
      } else {
        selectComponent(component);
      }
    }
  }

  void addComponent(ComponentModel component, int r, int c) {
    Logger.log('GameEngineNotifier: addComponent ${component.id} of type ${component.type} at ($r, $c)');
    if (state.grid.canPlaceComponent(component, r, c)) {
      final newComponent = component.copyWith(r: r, c: c);
      final newComponents = Map<String, ComponentModel>.from(state.grid.componentsById);
      newComponents[newComponent.id] = newComponent;
      state = state.copyWith(grid: state.grid.copyWith(componentsById: newComponents));
    } else {
      _audioService.play(AppAssets.audioWarning);
    }
    _evaluateAndUpdateRenderState();
  }

  void updateComponent(ComponentModel component) {
    final newComponents = Map<String, ComponentModel>.from(state.grid.componentsById);
    newComponents[component.id] = component;
    state = state.copyWith(grid: state.grid.copyWith(componentsById: newComponents));
    _evaluateAndUpdateRenderState();
  }

  void rotateComponent(String componentId) {
    final component = state.grid.componentsById[componentId];
    if (component == null || !component.isDraggable) return;

    final newRotation = (component.rotation + 90) % 360;
    final updatedComponent = component.copyWith(rotation: newRotation);
    final newComponents = Map<String, ComponentModel>.from(state.grid.componentsById);
    newComponents[componentId] = updatedComponent;

    state = state.copyWith(grid: state.grid.copyWith(componentsById: newComponents));
    _evaluateAndUpdateRenderState();
  }

  void selectComponent(ComponentModel component) {
    if (state.selectedComponentId == component.id) {
      state = state.copyWith(selectedComponentId: null);
    } else {
      state = state.copyWith(selectedComponentId: component.id);
    }
  }

  void reset() {
    if (state.currentLevel != null) {
      loadLevel(state.currentLevel!);
    }
  }

  @override
  void dispose() {
    animationScheduler.dispose();
    super.dispose();
  }
}
