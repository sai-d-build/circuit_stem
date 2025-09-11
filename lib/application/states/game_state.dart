import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/core/simulation/simulation_result.dart';
import 'interaction_state.dart';
import 'history_state.dart';

// part 'game_state.freezed.dart';
// part 'game_state.g.dart';

class GameState {
  final Grid grid;
  final bool isPaused;
  final bool isWin;
  final LevelDefinition? currentLevel;
  final SimulationResult? simulationResult;
  final DateTime lastUpdated;
  final bool isDebugOverlayVisible;
  final InteractionState interactionState;
  final HistoryState history;

  const GameState({
    required this.grid,
    required this.isPaused,
    required this.isWin,
    this.currentLevel,
    this.simulationResult,
    required this.lastUpdated,
    this.isDebugOverlayVisible = false,
    required this.interactionState,
    required this.history,
  });

  factory GameState.initial(LevelDefinition? level) => GameState(
        grid: Grid(
          rows: level?.grid.height ?? 20,  // ✅ Fix: Use standard 20x20 grid instead of 0x0
          cols: level?.grid.width ?? 20,   // ✅ Fix: Use standard 20x20 grid instead of 0x0
          components: {}, // Will be populated from level data
        ),
        isPaused: false,
        isWin: false,
        currentLevel: level,
        simulationResult: null,
        lastUpdated: DateTime.now(),
        isDebugOverlayVisible: false,
        interactionState: InteractionState.initial(),
        history: HistoryState.initial(),
      );

  GameState copyWith({
    Grid? grid,
    bool? isPaused,
    bool? isWin,
    LevelDefinition? currentLevel,
    SimulationResult? simulationResult,
    DateTime? lastUpdated,
    bool? isDebugOverlayVisible,
    InteractionState? interactionState,
    HistoryState? history,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      isPaused: isPaused ?? this.isPaused,
      isWin: isWin ?? this.isWin,
      currentLevel: currentLevel ?? this.currentLevel,
      simulationResult: simulationResult ?? this.simulationResult,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isDebugOverlayVisible: isDebugOverlayVisible ?? this.isDebugOverlayVisible,
      interactionState: interactionState ?? this.interactionState,
      history: history ?? this.history,
    );
  }
}