
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparkcircuit/domain/entities/grid.dart';
import 'package:sparkcircuit/domain/entities/level_definition.dart';
import 'package:sparkcircuit/core/simulation/simulation_result.dart';
import 'package:flutter/material.dart'; // For Offset

part 'enhanced_game_state.freezed.dart';
part 'enhanced_game_state.g.dart';

// Helper functions for Offset serialization
Map<String, dynamic>? _offsetToJson(Offset? offset) =>
    offset == null ? null : {'dx': offset.dx, 'dy': offset.dy};

Offset? _offsetFromJson(Map<String, dynamic>? json) =>
    json == null ? null : Offset(json['dx'] as double, json['dy'] as double);

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
  }) = _GameState;

  factory GameState.initial(LevelDefinition? level) => GameState(
        grid: Grid(
          rows: level?.rows ?? 0,
          cols: level?.cols ?? 0,
          components: level?.initialComponentsList != null
              ? {for (final comp in level!.initialComponentsList) comp.id: comp}
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
      );

  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);
}

@freezed
class InteractionState with _$InteractionState {
  const factory InteractionState({
    String? selectedComponentId,
    String? draggedComponentId,
    @JsonKey(toJson: _offsetToJson, fromJson: _offsetFromJson) Offset? dragStartLocalPosition,
    @JsonKey(toJson: _offsetToJson, fromJson: _offsetFromJson) Offset? dragUpdateLocalPosition,
    @Default(false) bool isDragging,
  }) = _InteractionState;

  factory InteractionState.initial() => const InteractionState();

  factory InteractionState.fromJson(Map<String, dynamic> json) =>
      _$InteractionStateFromJson(json);
}

@freezed
class HistoryState with _$HistoryState {
  const factory HistoryState({
    @Default([]) List<String> commands, // Simplified for now
  }) = _HistoryState;

  factory HistoryState.initial() => const HistoryState();

  factory HistoryState.fromJson(Map<String, dynamic> json) =>
      _$HistoryStateFromJson(json);
}
