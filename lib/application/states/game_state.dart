import 'package:flutter/material.dart'; // For Offset
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparkcircuit/core/simulation/simulation_result.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

import 'history_state.dart';
import 'interaction_state.dart';

part 'game_state.freezed.dart';

@freezed
class GameState with _$GameState {
  const factory GameState({
    required Grid grid,
    required bool isPaused,
    required bool isWin,
    LevelDefinition? currentLevel,
    SimulationResult? simulationResult,
    required DateTime lastUpdated,
    @Default(false) bool isDebugOverlayVisible,
    required InteractionState interactionState,
    required HistoryState history,
    String? error, // ✅ REQUIRED: Error handling
    @Default([]) List<Wire> wires, // ✅ REQUIRED: Wire management
    Offset? wireDrawStartPos, // ✅ REQUIRED: Wire drawing state
    @Default(false) bool isDrawingWire, // ✅ REQUIRED: Wire interaction
    int? hoveredCellIndex, // 🆕 Hover state management
  }) = _GameState;

  factory GameState.initial(LevelDefinition? level) => GameState(
        grid: Grid(
          rows: level?.grid.height ?? 20,
          cols: level?.grid.width ?? 20,
          components: {},
        ),
        isPaused: false,
        isWin: false,
        currentLevel: level,
        simulationResult: null,
        lastUpdated: DateTime.now(),
        interactionState: InteractionState.initial(),
        history: HistoryState.initial(),
      );
}
