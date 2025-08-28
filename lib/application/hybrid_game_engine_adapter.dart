import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'game_engine_state.dart';
import 'game_engine_orchestrator.dart';
import 'component_selection_notifier.dart';
import 'interaction_state_notifier.dart';
import 'use_cases/component_action.dart';
import 'core/result.dart';
import 'audio_manager.dart';
import 'input_manager.dart';
import 'animation_scheduler.dart';
import 'hybrid_providers.dart';

/// Hybrid adapter that maintains the existing GameEngineNotifier API
/// while delegating to the new orchestrator and granular notifiers internally.
/// This allows for gradual migration without breaking existing UI code.
class HybridGameEngineAdapter extends StateNotifier<GameEngineState> {
  final GameEngineOrchestrator _orchestrator;
  final ComponentSelectionNotifier _selectionNotifier;
  final InteractionStateNotifier _interactionNotifier;
  final AudioManager _audioManager;
  final InputManager _inputManager;
  final AnimationScheduler _animationScheduler;

  HybridGameEngineAdapter({
    required GameEngineOrchestrator orchestrator,
    required ComponentSelectionNotifier selectionNotifier,
    required InteractionStateNotifier interactionNotifier,
    required AudioManager audioManager,
    required InputManager inputManager,
    required AnimationScheduler animationScheduler,
  })  : _orchestrator = orchestrator,
        _selectionNotifier = selectionNotifier,
        _interactionNotifier = interactionNotifier,
        _audioManager = audioManager,
        _inputManager = inputManager,
        _animationScheduler = animationScheduler,
        super(GameEngineState.empty()) {
    _init();
  }

  void _init() {
    // Set up input manager callbacks
    _inputManager.onComponentTapped = _handleTap;
    _inputManager.onComponentMoved = _moveComponent;

    // Listen to orchestrator state changes
    _orchestrator.addListener((orchestratorState) {
      _updateCompositeState();
    });

    // Listen to selection changes
    _selectionNotifier.addListener((selectedId) {
      _updateCompositeState();
    });

    // Listen to interaction changes
    _interactionNotifier.addListener((interactionState) {
      _updateCompositeState();
    });
  }

  void _updateCompositeState() {
    // Build composite state from all notifiers
    final orchestratorState = _orchestrator.state;
    final selectedComponentId = _selectionNotifier.state;
    final interactionState = _interactionNotifier.state;

    state = orchestratorState.copyWith(
      selectedComponentId: selectedComponentId,
      draggedComponentId: interactionState.draggedComponentId,
      dragPosition: interactionState.dragPosition,
    );
  }

  // =============================================================================
  // EXISTING API METHODS - Maintained for backward compatibility
  // =============================================================================

  Grid get grid => state.grid;
  LevelDefinition? get currentLevel => state.currentLevel;
  bool get canUndo => state.history.isNotEmpty;
  bool get isGamePaused => state.isPaused;

  Future<Result<GameEngineState>> loadLevel(LevelDefinition level) async {
    return await _orchestrator.executeAction(LoadLevelAction(level));
  }

  Future<Result<GameEngineState>> executeAction(ComponentAction action) async {
    // Delegate to orchestrator for core game actions
    final result = await _orchestrator.executeAction(action);
    
    // Handle UI-specific actions locally
    if (action is SelectPaletteComponentAction) {
      _selectionNotifier.selectComponent(action.componentId);
    }
    
    return result;
  }

  void updateComponent(ComponentModel component) {
    executeAction(UpdateComponentAction(
      componentId: component.id,
      newState: component.state,
    ));
  }

  void selectPaletteComponent(ComponentModel component) {
    _selectionNotifier.selectComponent(component.id);
    _audioManager.playSelection();
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

  void toggleDebugOverlay() {
    state = state.copyWith(isDebugOverlayVisible: !state.isDebugOverlayVisible);
  }

  // =============================================================================
  // INPUT HANDLING - Delegates to interaction notifier
  // =============================================================================

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

  // =============================================================================
  // DRAG AND DROP HANDLING - Delegates to interaction notifier
  // =============================================================================

  void startDrag(String componentId, Offset position) {
    _interactionNotifier.startDrag(componentId, position);
  }

  void updateDragPosition(Offset position) {
    _interactionNotifier.updateDragPosition(position);
  }

  void endDrag() {
    _interactionNotifier.endDrag();
  }

  void cancelDrag() {
    _interactionNotifier.cancelDrag();
  }

  // =============================================================================
  // GETTERS - For backward compatibility
  // =============================================================================

  InputManager get inputManager => _inputManager;
  AudioManager get audioManager => _audioManager;
  AnimationScheduler get animationScheduler => _animationScheduler;
}

// =============================================================================
// PROVIDER FOR THE HYBRID ADAPTER
// =============================================================================

final hybridGameEngineProvider =
    StateNotifierProvider<HybridGameEngineAdapter, GameEngineState>((ref) {
  final orchestrator = ref.watch(gameEngineOrchestratorProvider.notifier);
  final selectionNotifier = ref.watch(componentSelectionNotifierProvider.notifier);
  final interactionNotifier = ref.watch(interactionStateNotifierProvider.notifier);
  final audioService = ref.watch(audioServiceProvider);
  final animationScheduler = ref.watch(animationSchedulerProvider);

  return HybridGameEngineAdapter(
    orchestrator: orchestrator,
    selectionNotifier: selectionNotifier,
    interactionNotifier: interactionNotifier,
    audioManager: AudioManager(audioService),
    inputManager: InputManager(),
    animationScheduler: animationScheduler,
  );
});