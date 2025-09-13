import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../common/logger.dart';

/// Represents a game state snapshot for undo functionality
class GameStateSnapshot {
  final Map<String, dynamic> gridState;
  final Map<String, dynamic> componentStates;
  final DateTime timestamp;

  const GameStateSnapshot({
    required this.gridState,
    required this.componentStates,
    required this.timestamp,
  });
}

/// Notifier for managing game history and undo functionality
class HistoryNotifier extends StateNotifier<List<GameStateSnapshot>> {
  static const int maxHistorySize = 50;

  HistoryNotifier() : super([]);

  /// Add a new state to history
  void pushState(
      Map<String, dynamic> gridState, Map<String, dynamic> componentStates) {
    final snapshot = GameStateSnapshot(
      gridState: gridState,
      componentStates: componentStates,
      timestamp: DateTime.now(),
    );

    final newHistory = [...state, snapshot];

    // Keep only the most recent states
    if (newHistory.length > maxHistorySize) {
      newHistory.removeAt(0);
    }

    state = newHistory;
    Logger.log('History: Added state, total states: ${state.length}');
  }

  /// Get the most recent state for undo
  GameStateSnapshot? getLatestState() {
    return state.isNotEmpty ? state.last : null;
  }

  /// Remove and return the most recent state
  GameStateSnapshot? popState() {
    if (state.isEmpty) return null;

    final latest = state.last;
    state = state.sublist(0, state.length - 1);
    Logger.log('History: Popped state, remaining states: ${state.length}');
    return latest;
  }

  /// Clear all history
  void clearHistory() {
    state = [];
    Logger.log('History: Cleared all states');
  }

  /// Check if undo is available
  bool get canUndo => state.isNotEmpty;

  /// Get history size
  int get historySize => state.length;

  /// Get current state (for V2 API compatibility)
  List<GameStateSnapshot> get current => state;

  /// Get the last state (for V2 API compatibility)
  GameStateSnapshot? getLastState() => getLatestState();

  /// Pop and return the last state (for V2 API compatibility)
  GameStateSnapshot? popLastState() => popState();

  /// Set state directly (for V2 API compatibility)
  void setState(List<GameStateSnapshot> newState) {
    state = newState;
    Logger.log('History: State set directly, new size: ${state.length}');
  }
}

// Provider for HistoryNotifier
final historyNotifierProvider =
    StateNotifierProvider<HistoryNotifier, List<GameStateSnapshot>>((ref) {
  return HistoryNotifier();
});
