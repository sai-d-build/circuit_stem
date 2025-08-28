import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_engine_state.dart';
import 'use_cases/component_action.dart';
import 'grid_notifier.dart';
import 'history_notifier.dart';
import 'game_progress_notifier.dart';
import 'core/result.dart';
import 'services/component_palette_manager.dart';

// Simple transaction class for coordinating changes
class GameTransaction {
  final Map<String, dynamic> _changes = {};
  bool _committed = false;
  
  void addChange(String key, dynamic value) {
    if (_committed) throw StateError('Transaction already committed');
    _changes[key] = value;
  }
  
  Future<void> commit() async {
    _committed = true;
    // Apply all changes atomically
  }
  
  Future<void> rollback() async {
    _changes.clear();
    _committed = true;
  }
  
  Map<String, dynamic> get changes => Map.unmodifiable(_changes);
}

class GameEngineOrchestrator extends StateNotifier<GameEngineState> {
  final GridNotifier _grid;
  final HistoryNotifier _history;
  final GameProgressNotifier _progress;
  
  GameEngineOrchestrator(this._grid, this._history, this._progress) : super(GameEngineState.empty());

  Future<Result<GameEngineState>> executeAction(ComponentAction action) async {
    // Begin transaction
    final transaction = await _beginTransaction();
    
    try {
      // Execute across notifiers
      await _grid.executeInTransaction(action, transaction);
      await _history.executeInTransaction(action, transaction);
      await _progress.executeInTransaction(action, transaction);
      
      // Commit all changes atomically
      await transaction.commit();
      
      // Update composite state
      state = _buildCompositeState();
      
      return Success(state);
    } catch (e) {
      await transaction.rollback();
      return Failure(e.toString());
    }
  }
  
  Future<GameTransaction> _beginTransaction() async {
    return GameTransaction();
  }
  
  GameEngineState _buildCompositeState() {
    return GameEngineState(
      grid: _grid.state,
      isPaused: _progress.state.isPaused,
      isWin: _progress.state.isWin,
      selectedComponentId: null, // Will be handled by separate notifiers
      draggedComponentId: null, // Will be handled by separate notifiers
      dragPosition: null, // Will be handled by separate notifiers
      paletteManager: const ComponentPaletteManager([]), // Default empty palette
      history: _history.state,
      lastUpdated: DateTime.now(),
    );
  }
}