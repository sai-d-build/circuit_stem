import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_engine_state.dart';

class HistoryNotifier extends StateNotifier<List<GameEngineState>> {
  HistoryNotifier() : super([]);

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
    // Implementation for transaction-based history updates
    // This will be expanded based on the specific action types
  }
}