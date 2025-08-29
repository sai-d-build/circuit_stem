import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_engine_state.dart';

class HistoryNotifier extends StateNotifier<List<GameEngineState>> {
  HistoryNotifier() : super([]);

  // Public snapshot getter for safe read access
  List<GameEngineState> get current => state;

  // Public setter for controlled writes
  void setState(List<GameEngineState> newState) => state = newState;

  // Add a new state to history
  void addToHistory(GameEngineState state) {
    this.state = [...this.state, state];
  }

  // Clear history
  void clearHistory() {
    state = [];
  }

  // Get the last state from history
  GameEngineState? getLastState() {
    if (state.isEmpty) return null;
    return state.last;
  }

  // Remove the last state from history (for undo)
  GameEngineState? popLastState() {
    if (state.isEmpty) return null;
    final lastState = state.last;
    state = state.sublist(0, state.length - 1);
    return lastState;
  }

  // Method to execute actions in transaction
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    // Store current state for rollback
    final previousState = state;
    
    // Register rollback handler
    transaction.onRollback(() {
      state = previousState;
    });
    
    // Register commit handler - execute the history update
    transaction.onCommit(() async {
      // History management: only add to history for non-undo actions
      if (!action.toString().contains('Undo')) {
        // TODO: Add current game state to history
        // This will be properly implemented when we have the full game state
        // For now, this is a placeholder
      }
    });
  }
}