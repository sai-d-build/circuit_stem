import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/level_definition.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import '../../domain/entities/component.dart';
import 'render_state.dart';

part 'game_engine_state.freezed.dart';

/// Immutable state object for the game engine
/// Contains all necessary state information for the game
@freezed
class GameEngineState with _$GameEngineState {
  const factory GameEngineState({
    required Grid grid,
    required bool isPaused,
    required bool isWin,
    LevelDefinition? currentLevel,
    String? draggedComponentId,
    String? selectedComponentId,
    Offset? dragPosition,
    @Default(false) bool isShortCircuit,
    RenderState? renderState,
    @Default([]) List<ComponentModel> paletteComponents,
  @Default({}) Set<String> poweredBuzzerIds,
  }) = _GameEngineState;

  /// Factory constructor for initial state
  factory GameEngineState.initial(LevelDefinition? level) => GameEngineState(
    grid: Grid(
      rows: level?.rows ?? 0, 
      cols: level?.cols ?? 0,
    ),
    isPaused: false,
    isWin: false,
    currentLevel: level,
    isShortCircuit: false,
    draggedComponentId: null,
    selectedComponentId: null,
    dragPosition: null,
    renderState: RenderState(
      grid: Grid(
        rows: level?.rows ?? 0, 
        cols: level?.cols ?? 0,
      ),
      poweredComponentIds: const {},
      draggedComponentId: null,
      dragPosition: null,
    ),
  );

  /// Factory constructor for empty state (no level loaded)
  factory GameEngineState.empty() => const GameEngineState(
    grid: Grid(rows: 0, cols: 0),
    isPaused: false,
    isWin: false,
    currentLevel: null,
    isShortCircuit: false,
    draggedComponentId: null,
    selectedComponentId: null,
    dragPosition: null,
    renderState: RenderState(
      grid: Grid(rows: 0, cols: 0),
      poweredComponentIds: {},
      draggedComponentId: null,
      dragPosition: null,
    ),
  );
}

/// Extension methods for GameEngineState to provide convenient getters
extension GameEngineStateExtensions on GameEngineState {
  /// Whether a level is currently loaded
  bool get hasLevel => currentLevel != null;
  
  /// Whether the game is currently being played (has level and not paused)
  bool get isPlaying => hasLevel && !isPaused && !isWin;
  
  /// Whether drag operation is in progress
  bool get isDragging => draggedComponentId != null;
  
  /// Whether the game can be interacted with
  bool get isInteractable => hasLevel && !isPaused && !isWin && !isShortCircuit;
  
  /// Get the current level's ID (null if no level loaded)
  String? get currentLevelId => currentLevel?.id;
  
  /// Get grid dimensions as a string for debugging
  String get gridDimensions => '${grid.rows}x${grid.cols}';
}