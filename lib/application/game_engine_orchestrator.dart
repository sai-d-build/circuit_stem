import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_engine_state.dart';
import 'use_cases/component_action.dart';
import 'use_cases/base_use_case.dart';
import 'use_cases/notifier_integrated_use_case.dart';
import 'grid_notifier.dart';
import 'history_notifier.dart';
import 'game_progress_notifier.dart';
import 'component_selection_notifier.dart';
import 'interaction_state_notifier.dart';
import 'core/result.dart';
import 'services/component_palette_manager.dart';

import 'transaction.dart';
class GameEngineOrchestrator extends StateNotifier<GameEngineState> {
  final GridNotifier _grid;
  final HistoryNotifier _history;
  final GameProgressNotifier _progress;
  final ComponentSelectionNotifier _selection;
  final InteractionStateNotifier _interaction;
  ComponentPaletteManager _paletteManager;
  
  GameEngineOrchestrator(
    this._grid,
    this._history,
    this._progress,
    this._selection,
    this._interaction,
    this._paletteManager,
  ) : super(GameEngineState.empty());

  Future<Result<GameEngineState>> executeAction(ComponentAction action) async {
    // Begin transaction
    final transaction = _beginTransaction();
    
    try {
      // Execute across notifiers - they register their changes with the transaction
      await _grid.executeInTransaction(action, transaction);
      await _history.executeInTransaction(action, transaction);
      await _progress.executeInTransaction(action, transaction);
      await _selection.executeInTransaction(action, transaction);
      await _interaction.executeInTransaction(action, transaction);
      
      // Commit all changes atomically - this triggers all registered commit handlers
      await transaction.commit();
      
      // Update composite state after successful commit
      state = _buildCompositeState();
      
      return Success(state);
    } catch (e) {
      // Rollback triggers all registered rollback handlers
      await transaction.rollback();
      return Failure(e.toString());
    }
  }

  /// Execute a UseCase (legacy or notifier-integrated) and apply changes to granular notifiers
  Future<Result<GameEngineState>> executeUseCase<TAction extends ComponentAction>(
    dynamic useCase,
    TAction action
  ) async {
    // Begin transaction
    final transaction = _beginTransaction();
    
    try {
      // Check if this is a notifier-integrated use case
      if (useCase is NotifierIntegratedUseCase<TAction>) {
        return await _executeNotifierIntegratedUseCase(useCase, action, transaction);
      } else if (useCase is UseCase<TAction>) {
        return await _executeLegacyUseCase(useCase, action, transaction);
      } else {
        return Failure('Unknown use case type: ${useCase.runtimeType}');
      }
    } catch (e) {
      // Rollback triggers all registered rollback handlers
      await transaction.rollback();
      return Failure(e.toString());
    }
  }

  /// Execute a notifier-integrated use case (more efficient)
  Future<Result<GameEngineState>> _executeNotifierIntegratedUseCase<TAction extends ComponentAction>(
    NotifierIntegratedUseCase<TAction> useCase,
    TAction action,
    GameTransaction transaction,
  ) async {
    final notifierContext = NotifierContext(
      grid: _grid,
      history: _history,
      progress: _progress,
      selection: _selection,
      interaction: _interaction,
      paletteManager: _paletteManager,
    );

    // Validate action
    final validationResult = useCase.validate(action, notifierContext);
    if (validationResult.isFailure) {
      return Failure(validationResult.error!);
    }

    // Execute use case with notifiers
    final result = await useCase.executeWithNotifiers(action, notifierContext, transaction);
    if (result.isFailure) {
      return Failure(result.error!);
    }

    // Commit all changes atomically
    await transaction.commit();
    
    // Execute post-commit handlers (orchestrator-level updates)
    transaction.executePostCommitHandlers();

    // Update composite state after successful commit
    state = _buildCompositeState();

    return Success(state);
  }

  /// Execute a legacy use case (compatibility path)
  Future<Result<GameEngineState>> _executeLegacyUseCase<TAction extends ComponentAction>(
    UseCase<TAction> useCase,
    TAction action,
    GameTransaction transaction,
  ) async {
    // Build current composite state from all notifiers
    final currentState = _buildCompositeState();
    
    // Execute the use case against current state
    final useCaseResult = await useCase.execute(currentState, action);
    
    if (useCaseResult.isFailure) {
      return Failure(useCaseResult.error!);
    }
    
    final newState = useCaseResult.data!;
    
    // Apply state diff to individual notifiers within transaction
    await _applyStateDiff(currentState, newState, transaction);
    
    // Commit all changes atomically
    await transaction.commit();
    
    // Execute post-commit handlers (orchestrator-level updates)
    transaction.executePostCommitHandlers();
    
    // Update composite state after successful commit
    state = _buildCompositeState();
    
    return Success(state);
  }

  /// Apply differences between old and new state to individual notifiers
  Future<void> _applyStateDiff(
    GameEngineState oldState,
    GameEngineState newState,
    GameTransaction transaction
  ) async {
    // Grid changes
    if (oldState.grid != newState.grid) {
      transaction.onCommit(() async {
        _grid.state = newState.grid;
      });
    }
    
    // Progress changes
    if (oldState.isPaused != newState.isPaused) {
      transaction.onCommit(() async {
        if (newState.isPaused != oldState.isPaused) {
          _progress.togglePause();
        }
      });
    }
    
    if (oldState.isWin != newState.isWin) {
      transaction.onCommit(() async {
        _progress.setWinState(newState.isWin);
      });
    }
    
    // Selection changes
    if (oldState.selectedComponentId != newState.selectedComponentId) {
      transaction.onCommit(() async {
        if (newState.selectedComponentId != null) {
          _selection.selectComponent(newState.selectedComponentId!);
        } else {
          _selection.clearSelection();
        }
      });
    }
    
    // Interaction state changes
    if (oldState.draggedComponentId != newState.draggedComponentId ||
        oldState.dragPosition != newState.dragPosition) {
      transaction.onCommit(() async {
        if (newState.draggedComponentId != null && newState.dragPosition != null) {
          _interaction.startDrag(newState.draggedComponentId!, newState.dragPosition!);
        } else {
          _interaction.endDrag();
        }
      });
    }
    
    // History changes
    if (oldState.history != newState.history) {
      transaction.onCommit(() async {
        _history.state = newState.history;
      });
    }
  }
  
  GameTransaction _beginTransaction() {
    return GameTransaction();
  }

  /// Update the orchestrator's palette manager reference.
  /// Call this from use-cases that change the current level/palette (e.g., load/restart).
  void updatePaletteManager(ComponentPaletteManager paletteManager) {
    _paletteManager = paletteManager;
  }
  
  GameEngineState _buildCompositeState() {
    return GameEngineState(
      grid: _grid.state,
      isPaused: _progress.state.isPaused,
      isWin: _progress.state.isWin,
      selectedComponentId: _selection.state,
      draggedComponentId: _interaction.state.draggedComponentId,
      dragPosition: _interaction.state.dragPosition,
      paletteManager: _paletteManager,
      history: _history.state,
      lastUpdated: DateTime.now(),
    );
  }
}