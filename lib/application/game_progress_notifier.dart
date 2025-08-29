import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a simple GameProgressState class
class GameProgressState {
  final bool isWin;
  final int score;
  final bool isPaused;

  const GameProgressState({
    required this.isWin,
    required this.score,
    required this.isPaused,
  });

  static GameProgressState initial() {
    return const GameProgressState(
      isWin: false,
      score: 0,
      isPaused: false,
    );
  }

  GameProgressState copyWith({
    bool? isWin,
    int? score,
    bool? isPaused,
  }) {
    return GameProgressState(
      isWin: isWin ?? this.isWin,
      score: score ?? this.score,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class GameProgressNotifier extends StateNotifier<GameProgressState> {
  GameProgressNotifier() : super(GameProgressState.initial());

  // Public snapshot getter for safe read access
  GameProgressState get current => state;

  // Public setter for controlled writes
  void setState(GameProgressState newState) => state = newState;

  // Update win state
  void setWinState(bool isWin) {
    state = state.copyWith(isWin: isWin);
  }

  // Update score
  void updateScore(int newScore) {
    state = state.copyWith(score: newScore);
  }

  // Toggle pause state
  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  // Reset progress
  void reset() {
    state = GameProgressState.initial();
  }

  // Method to execute actions in transaction
  Future<void> executeInTransaction(dynamic action, dynamic transaction) async {
    // Store current state for rollback
    final previousState = state;
    
    // Register rollback handler
    transaction.onRollback(() {
      state = previousState;
    });
    
    // Register commit handler - execute progress updates
    transaction.onCommit(() async {
      // Update progress based on action type
      if (action.toString().contains('CheckWin')) {
        // TODO: Implement win condition checking
        // This would evaluate the current grid state and update isWin
      } else if (action.toString().contains('TogglePause')) {
        togglePause();
      } else if (action.toString().contains('Restart')) {
        reset();
      }
      // Score updates would be handled based on specific action types
    });
  }
}