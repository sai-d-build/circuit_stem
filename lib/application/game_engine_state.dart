import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Domain entities
import 'package:sparkcircuit/domain/entities/entities.dart';

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
          rows: level?.grid.height ?? 0,
          cols: level?.grid.width ?? 0,
          components: {}, // Will be populated from level data
        ),
        isPaused: false,
        isWin: false,
        currentLevel: level,
        isShortCircuit: false,
        draggedComponentId: null,
        selectedComponentId: null,
        dragPosition: null,
        paletteComponents:
            (level?.components.available ?? []).map((availability) => ComponentModel(
              id: availability.toString(), // Convert ComponentAvailability to string ID
              type: _mapAvailabilityToComponentType(availability),
              row: -1, // Placeholder for palette components
              col: -1, // Placeholder for palette components
              properties: {},
            )).toList(),
        paletteManager: ComponentPaletteManager(
          availableTemplates: (level?.components.available ?? []).map((availability) => ComponentModel(
                id: availability.toString(), // Convert ComponentAvailability to string ID
                type: _mapAvailabilityToComponentType(availability),
                row: -1, // Placeholder for palette components
                col: -1, // Placeholder for palette components
                properties: {},
              )).toList(),
        ),
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
        paletteManager: const ComponentPaletteManager(availableTemplates: []),
        poweredBuzzerIds: const {},
        history: const [],
        lastUpdated: DateTime.now(),
        isDebugOverlayVisible: false,
      );

  // Enhanced state validation methods
  bool isValidState() {
    // Check grid bounds
    if (currentLevel != null) {
      if (grid.rows != currentLevel!.grid.height || grid.cols != currentLevel!.grid.width) {
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
  String? get currentLevelId => currentLevel?.levelId;
  String get gridDimensions => '${grid.rows}x${grid.cols}';

  static ComponentType _mapAvailabilityToComponentType(ComponentAvailability availability) {
    // Map ComponentAvailability.type string to ComponentType
    switch (availability.type) {
      case 'wire':
        return ComponentType.wire;
      case 'switch':
        return ComponentType.switch_;
      case 'capacitor':
        return ComponentType.capacitor;
      case 'resistor':
        return ComponentType.resistor;
      case 'bulb':
      case 'led':
        return ComponentType.bulb;
      case 'battery':
        return ComponentType.battery;
      case 'inductor':
        return ComponentType.inductor;
      case 'buzzer':
        return ComponentType.buzzer;
      default:
        // Fallback to wire as default
        return ComponentType.wire;
    }
  }
}
