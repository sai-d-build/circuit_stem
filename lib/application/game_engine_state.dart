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
  const GameEngineState._(); // Add this line

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
    required DateTime lastUpdated,
    @Default(false) bool isDebugOverlayVisible,
  }) = _GameEngineState;

  factory GameEngineState.initial(LevelDefinition? level) => GameEngineState(
        grid: Grid(
          rows: level?.rows ?? 0,
          cols: level?.cols ?? 0,
          components: level?.initialComponents ?? [], // Add initial components to the grid
        ),
        isPaused: false,
        isWin: false,
        currentLevel: level,
        isShortCircuit: false,
        draggedComponentId: null,
        selectedComponentId: null,
        dragPosition: null,
        paletteComponents:
            level?.paletteComponents ?? [], // Keep for coexistence
        paletteManager: ComponentPaletteManager(level?.paletteComponents ?? []),
        poweredBuzzerIds: const {},
        history: const [],
        lastUpdated: DateTime.now(),
        isDebugOverlayVisible: false,
      );

  factory GameEngineState.empty() => GameEngineState(
        grid: const Grid(rows: 0, cols: 0),
        isPaused: false,
        isWin: false,
        currentLevel: null,
        isShortCircuit: false,
        draggedComponentId: null,
        selectedComponentId: null,
        dragPosition: null,
        paletteComponents: const [],
        paletteManager: const ComponentPaletteManager([]),
        poweredBuzzerIds: const {},
        history: const [],
        lastUpdated: DateTime.now(),
        isDebugOverlayVisible: false,
      );

  // Enhanced state validation methods
  bool isValidState() {
    // Check grid bounds
    if (currentLevel != null) {
      if (grid.rows != currentLevel!.rows || grid.cols != currentLevel!.cols) {
        return false;
      }

      // Check all components are within bounds
      for (final component in grid.components) {
        if (component.r < 0 ||
            component.r >= grid.rows ||
            component.c < 0 ||
            component.c >= grid.cols) {
          return false;
        }
      }
    }

    // Check for duplicate component IDs
    final ids = grid.components.map((c) => c.id).toList();
    final uniqueIds = ids.toSet();
    if (ids.length != uniqueIds.length) {
      return false;
    }

    // Check selected component exists in palette
    if (selectedComponentId != null) {
      final exists = paletteComponents.any((c) => c.id == selectedComponentId);
      if (!exists) {
        return false;
      }
    }

    return true;
  }

  bool hasGridChanged(GameEngineState other) {
    return grid != other.grid;
  }

  bool hasPowerStatesChanged(GameEngineState other) {
    if (grid.components.length != other.grid.components.length) {
      return true;
    }

    for (int i = 0; i < grid.components.length; i++) {
      if (grid.components[i].isPowered != other.grid.components[i].isPowered) {
        return true;
      }
    }

    return false;
  }

  bool get hasLevel => currentLevel != null;
  bool get isPlaying => hasLevel && !isPaused && !isWin;
  bool get isDragging => draggedComponentId != null;
  bool get isInteractable => hasLevel && !isPaused && !isWin && !isShortCircuit;
  String? get currentLevelId => currentLevel?.id;
  String get gridDimensions => '${grid.rows}x${grid.cols}';
}
