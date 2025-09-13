import 'package:flutter/material.dart'; // For Offset
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparkcircuit/core/simulation/simulation_result.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

import '../common/converters.dart';

part 'enhanced_game_state.freezed.dart';

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
    String? error,
    // ✅ ADDED: Fields needed for InteractionEngine
    @Default([]) List<Wire> wires,
    Offset? wireDrawStartPos,
    @Default(false) bool isDrawingWire,
  }) = _GameState;

  factory GameState.initial(LevelDefinition? level) => GameState(
        grid: Grid(
          rows: level?.grid.height ?? 0,
          cols: level?.grid.width ?? 0,
          components: level?.components.preplaced != null
              ? {
                  for (final pos in level!.components.preplaced)
                    '${pos.row}_${pos.col}_${DateTime.now().millisecondsSinceEpoch}':
                        ComponentModel(
                      id: '${pos.row}_${pos.col}_${DateTime.now().millisecondsSinceEpoch}',
                      type: ComponentType.wire, // Default to wire
                      row: pos.row,
                      col: pos.col,
                    )
                }
              : {},
        ),
        isPaused: false,
        isWin: false,
        currentLevel: level,
        simulationResult: null,
        lastUpdated: DateTime.now(),
        isDebugOverlayVisible: false,
        interactionState: InteractionState.initial(),
        history: HistoryState.initial(),
        error: null,
      );
}

@freezed
class InteractionState with _$InteractionState {
  const factory InteractionState({
    String? selectedComponentId,
    String? draggedComponentId,
    @OffsetConverter() Offset? dragStartLocalPosition,
    @OffsetConverter() Offset? dragUpdateLocalPosition,
    @Default(false) bool isDragging,
  }) = _InteractionState;

  factory InteractionState.initial() => const InteractionState();
}

@freezed
class HistoryState with _$HistoryState {
  const factory HistoryState({
    @Default([]) List<String> commands, // Simplified for now
  }) = _HistoryState;

  factory HistoryState.initial() => const HistoryState();
}
