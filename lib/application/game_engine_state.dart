import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/application/services/component_palette_manager.dart';
import 'render_state.dart';

part 'game_engine_state.freezed.dart';

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
    @Default([]) List<ComponentModel> paletteComponents, // Keep for now
    required ComponentPaletteManager paletteManager,
    @Default({}) Set<String> poweredBuzzerIds,
    @Default([]) List<GameEngineState> history,
  }) = _GameEngineState;

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
        paletteComponents: level?.paletteComponents ?? [], // Keep for coexistence
        paletteManager: ComponentPaletteManager(level?.paletteComponents ?? []),
        poweredBuzzerIds: const {},
        history: const [],
      );

  factory GameEngineState.empty() => const GameEngineState(
        grid: Grid(rows: 0, cols: 0),
        isPaused: false,
        isWin: false,
        currentLevel: null,
        isShortCircuit: false,
        draggedComponentId: null,
        selectedComponentId: null,
        dragPosition: null,
        paletteComponents: [],
        paletteManager: ComponentPaletteManager([]),
        poweredBuzzerIds: {},
        history: [],
      );
}

extension GameEngineStateExtensions on GameEngineState {
  bool get hasLevel => currentLevel != null;
  bool get isPlaying => hasLevel && !isPaused && !isWin;
  bool get isDragging => draggedComponentId != null;
  bool get isInteractable => hasLevel && !isPaused && !isWin && !isShortCircuit;
  String? get currentLevelId => currentLevel?.id;
  String get gridDimensions => '${grid.rows}x${grid.cols}';
}
