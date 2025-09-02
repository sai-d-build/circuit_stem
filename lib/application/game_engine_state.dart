import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Domain entities
import '../domain/entities/component.dart';
import '../domain/entities/grid.dart';
import '../domain/entities/level_definition.dart';

// Application services
import 'services/component_palette_manager.dart';
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
          components: level?.initialComponentsList != null
              ? {for (final comp in level!.initialComponentsList) comp.id: comp}
              : {}, // Convert List to Map
        ),
        isPaused: false,
        isWin: false,
        currentLevel: level,
        isShortCircuit: false,
        draggedComponentId: null,
        selectedComponentId: null,
        dragPosition: null,
        paletteComponents:
            (level?.components.available ?? []).map((template) => ComponentModel(
              id: template.type, // Using type as ID for palette components
              type: ComponentType.values.firstWhere((e) => e.toString().split('.').last == template.type),
              row: -1, // Placeholder for palette components
              col: -1, // Placeholder for palette components
              properties: template.properties ?? {},
            )).toList(),
        paletteManager: ComponentPaletteManager((level?.components.available ?? []).map((template) => ComponentModel(
              id: template.type, // Using type as ID for palette components
              type: ComponentType.values.firstWhere((e) => e.toString().split('.').last == template.type),
              row: -1, // Placeholder for palette components
              col: -1, // Placeholder for palette components
              properties: template.properties ?? {},
            )).toList()),
        poweredBuzzerIds: const {},
        history: const [],
        lastUpdated: DateTime.now(),
        isDebugOverlayVisible: false,
      );

  factory GameEngineState.empty() => GameEngineState(
        grid: Grid(rows: 0, cols: 0),
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
      for (final component in grid.components.values) {
        if (component.row < 0 ||
            component.row >= grid.rows ||
            component.col < 0 ||
            component.col >= grid.cols) {
          return false;
        }
      }
    }

    // Check for duplicate component IDs
    final ids = grid.components.values.map((c) => c.id).toList();
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

    // Compare power states for components with same IDs
    for (final entry in grid.components.entries) {
      final otherComponent = other.grid.components[entry.key];
      if (otherComponent == null || entry.value.isPowered != otherComponent.isPowered) {
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
