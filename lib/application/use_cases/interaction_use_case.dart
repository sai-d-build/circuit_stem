import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/domain/entities/components/wire.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';

// ✅ CLEAN: Single provider, no duplicates
final interactionEngineProvider =
    StateNotifierProvider.family<InteractionEngine, GameState, String>(
        (ref, levelId) => InteractionEngine(levelId));

class InteractionEngine extends StateNotifier<GameState> {
  late final CoordinateSystemService _coordinateService;

  InteractionEngine(String levelId) : super(GameState.initial(null)) {
    _coordinateService = CoordinateSystemService();
  }

  // ✅ CLEAN: Single implementation, no duplicate methods
  void handlePaletteDragEnd(ComponentDragData dragData, Offset globalPosition) {
    final gridPosition = _coordinateService.screenToGrid(
      globalPosition,
      CoordinateContext(
        gridDimensions:
            Size(state.grid.cols.toDouble(), state.grid.rows.toDouble()),
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: const Size(800, 600),
        devicePixelRatio: 1,
      ),
    );

    if (gridPosition == null) {
      state = state.copyWith(error: 'Invalid drop position');
      return;
    }

    // Check inventory and occupancy
    final occupiedPositions = state.grid.components.values
        .map(
            (component) => GridPosition(row: component.row, col: component.col))
        .toSet();

    if (occupiedPositions.contains(gridPosition)) {
      state = state.copyWith(error: 'Position already occupied');
      return;
    }

    // Create component and update state
    final componentId = 'component_${DateTime.now().millisecondsSinceEpoch}';
    final newComponent = ComponentModel(
      id: componentId,
      type: dragData.componentType,
      row: gridPosition.row,
      col: gridPosition.col,
      state: ComponentState.normal,
      properties: {},
      rotation: 0,
    );

    final newGrid = state.grid.copyWith(
        components: {...state.grid.components, componentId: newComponent});

    state = state.copyWith(
      grid: newGrid,
      error: null, // Clear any previous errors
    );
  }

  // ✅ CLEAN: Single wire drawing implementation
  void onWireDrawStart(Offset globalStart) {
    state = state.copyWith(
      wireDrawStartPos: globalStart,
      isDrawingWire: true,
      error: null,
    );
  }

  void onWireDrawEnd(Offset globalEnd) {
    if (state.wireDrawStartPos == null) return;

    final startNode = _coordinateService.screenToGrid(
      state.wireDrawStartPos!,
      CoordinateContext(
        gridDimensions:
            Size(state.grid.cols.toDouble(), state.grid.rows.toDouble()),
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: const Size(800, 600),
        devicePixelRatio: 1,
      ),
    );

    final endNode = _coordinateService.screenToGrid(
      globalEnd,
      CoordinateContext(
        gridDimensions:
            Size(state.grid.cols.toDouble(), state.grid.rows.toDouble()),
        cellSize: 60,
        scale: 1,
        panOffset: Offset.zero,
        canvasSize: const Size(800, 600),
        devicePixelRatio: 1,
      ),
    );

    if (startNode == null || endNode == null) {
      state = state.copyWith(
        error: 'Invalid wire endpoints',
        isDrawingWire: false,
      );
      return;
    }

    // Create wire segments along the path
    final wireId = 'wire_${DateTime.now().millisecondsSinceEpoch}';
    final wires = <Wire>[];

    // Simple straight line for now (can be enhanced with pathfinding later)
    final positions = [startNode, endNode];
    for (var i = 0; i < positions.length; i++) {
      final position = positions[i];
      final wire = Wire(
        id: '${wireId}_segment_$i',
        row: position.row,
        col: position.col,
      );
      wires.add(wire);
    }

    state = state.copyWith(
      wires: [...state.wires, ...wires],
      wireDrawStartPos: null,
      isDrawingWire: false,
      error: null,
    );
  }

  // ✅ CLEAN: Add missing setHoveredCell method for CircuitGrid integration
  void setHoveredCell(int? index) {
    // This method is called by CircuitGrid for hover state management
    // In a full implementation, this could update hover state in GameState
    // For now, it's a no-op to maintain compatibility
  }
}
