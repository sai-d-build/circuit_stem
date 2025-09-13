import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/core/services/unified_coordinate_service.dart';

/// Interaction modes for the canvas
enum CanvasInteractionMode {
  idle,
  panning,
  draggingExisting,
  placingFromPalette,
  drawingWire,
}

/// Immutable state for canvas interactions
class CanvasInteractionState {
  final CanvasInteractionMode mode;
  final Offset? dragStartPosition;
  final String? draggedComponentId;
  final String? placingComponentType;

  const CanvasInteractionState({
    this.mode = CanvasInteractionMode.idle,
    this.dragStartPosition,
    this.draggedComponentId,
    this.placingComponentType,
  });

  CanvasInteractionState copyWith({
    CanvasInteractionMode? mode,
    Offset? dragStartPosition,
    String? draggedComponentId,
    String? placingComponentType,
  }) {
    return CanvasInteractionState(
      mode: mode ?? this.mode,
      dragStartPosition: dragStartPosition ?? this.dragStartPosition,
      draggedComponentId: draggedComponentId ?? this.draggedComponentId,
      placingComponentType: placingComponentType ?? this.placingComponentType,
    );
  }
}

/// Immutable state for game canvas
class GameCanvasState {
  final double gridCellSize;
  final double scale;
  final Offset panOffset;
  final bool isScaling;
  final double lastScale;
  final Size canvasSize;
  final int gridWidth;
  final int gridHeight;
  final CanvasInteractionState interactionState;

  const GameCanvasState({
    this.gridCellSize = 60.0,
    this.scale = 1.0,
    this.panOffset = Offset.zero,
    this.isScaling = false,
    this.lastScale = 1.0,
    this.canvasSize = Size.zero,
    this.gridWidth = 8,
    this.gridHeight = 6,
    required this.interactionState,
  });

  /// Calculated properties
  double get scaledCellSize => gridCellSize * scale;
  Size get gridPixelSize => Size(
        gridWidth * scaledCellSize,
        gridHeight * scaledCellSize,
      );

  GameCanvasState copyWith({
    double? gridCellSize,
    double? scale,
    Offset? panOffset,
    bool? isScaling,
    double? lastScale,
    Size? canvasSize,
    int? gridWidth,
    int? gridHeight,
    CanvasInteractionState? interactionState,
  }) {
    return GameCanvasState(
      gridCellSize: gridCellSize ?? this.gridCellSize,
      scale: scale ?? this.scale,
      panOffset: panOffset ?? this.panOffset,
      isScaling: isScaling ?? this.isScaling,
      lastScale: lastScale ?? this.lastScale,
      canvasSize: canvasSize ?? this.canvasSize,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      interactionState: interactionState ?? this.interactionState,
    );
  }
}

/// StateNotifier for game canvas state management
class GameCanvasStateNotifier extends StateNotifier<GameCanvasState> {
  static const double _defaultCellSize = 60;
  static const double _minScale = 0.5;
  static const double _maxScale = 3;

  GameCanvasStateNotifier()
      : super(const GameCanvasState(
          interactionState: CanvasInteractionState(),
        ));

  // FSM methods
  void transitionToIdle() {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        mode: CanvasInteractionMode.idle,
        dragStartPosition: null,
        draggedComponentId: null,
        placingComponentType: null,
      ),
    );
  }

  void startDraggingComponent(String componentId, Offset startPosition) {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        mode: CanvasInteractionMode.draggingExisting,
        dragStartPosition: startPosition,
        draggedComponentId: componentId,
      ),
    );
  }

  void startPlacingFromPalette(String componentType, Offset startPosition) {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        mode: CanvasInteractionMode.placingFromPalette,
        dragStartPosition: startPosition,
        placingComponentType: componentType,
      ),
    );
  }

  void startPanning(Offset startPosition) {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        mode: CanvasInteractionMode.panning,
        dragStartPosition: startPosition,
      ),
    );
  }

  void startDrawingWire(Offset startPosition) {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        mode: CanvasInteractionMode.drawingWire,
        dragStartPosition: startPosition,
      ),
    );
  }

  void updateDragPosition(Offset currentPosition) {
    state = state.copyWith(
      interactionState: state.interactionState.copyWith(
        dragStartPosition: currentPosition,
      ),
    );
  }

  void endCurrentInteraction() {
    transitionToIdle();
  }

  // Query methods for FSM state
  bool get isIdle => state.interactionState.mode == CanvasInteractionMode.idle;
  bool get isDraggingComponent =>
      state.interactionState.mode == CanvasInteractionMode.draggingExisting;
  bool get isPlacingFromPalette =>
      state.interactionState.mode == CanvasInteractionMode.placingFromPalette;
  bool get isPanning =>
      state.interactionState.mode == CanvasInteractionMode.panning;
  bool get isDrawingWire =>
      state.interactionState.mode == CanvasInteractionMode.drawingWire;

  void updateCanvasSize(Size size) {
    if (state.canvasSize != size) {
      state = state.copyWith(canvasSize: size);
      _constrainPan();
    }
  }

  void updateGridSize(int width, int height) {
    if (state.gridWidth != width || state.gridHeight != height) {
      state = state.copyWith(gridWidth: width, gridHeight: height);
      _constrainPan();
    }
  }

  void updatePan(Offset delta) {
    final newPan = state.panOffset + delta;
    state = state.copyWith(panOffset: newPan);
    _constrainPan();
  }

  void setPan(Offset newPan) {
    state = state.copyWith(panOffset: newPan);
    _constrainPan();
  }

  void startScale() {
    state = state.copyWith(isScaling: true, lastScale: state.scale);
  }

  void updateScale(double scaleValue) {
    if (!state.isScaling) return;

    final newScale = (state.lastScale * scaleValue).clamp(_minScale, _maxScale);
    if (newScale != state.scale) {
      state = state.copyWith(scale: newScale);
      _constrainPan();
    }
  }

  void endScale() {
    state = state.copyWith(isScaling: false);
  }

  void zoomIn() {
    final newScale = (state.scale * 1.2).clamp(_minScale, _maxScale);
    if (newScale != state.scale) {
      state = state.copyWith(scale: newScale);
      _constrainPan();
    }
  }

  void zoomOut() {
    final newScale = (state.scale / 1.2).clamp(_minScale, _maxScale);
    if (newScale != state.scale) {
      state = state.copyWith(scale: newScale);
      _constrainPan();
    }
  }

  void resetZoom() {
    state = state.copyWith(scale: 1);
    _constrainPan();
  }

  void centerGrid() {
    if (state.canvasSize == Size.zero) return;

    final gridPixelSize = state.gridPixelSize;
    final newPan = Offset(
      (state.canvasSize.width - gridPixelSize.width) / 2,
      (state.canvasSize.height - gridPixelSize.height) / 2,
    );
    state = state.copyWith(panOffset: newPan);
  }

  void focusOnComponent(Offset gridPosition) {
    if (state.canvasSize == Size.zero) return;

    final screenPosition = Offset(
      gridPosition.dx * state.scaledCellSize,
      gridPosition.dy * state.scaledCellSize,
    );

    final newPan = Offset(
      state.canvasSize.width / 2 - screenPosition.dx,
      state.canvasSize.height / 2 - screenPosition.dy,
    );

    state = state.copyWith(panOffset: newPan);
    _constrainPan();
  }

  void _constrainPan() {
    if (state.canvasSize == Size.zero) return;

    final gridPixelSize = state.gridPixelSize;

    // Calculate bounds for panning
    final rawMinPanX = state.canvasSize.width - gridPixelSize.width - 50;
    const rawMaxPanX = 50.0;
    final rawMinPanY = state.canvasSize.height - gridPixelSize.height - 50;
    const rawMaxPanY = 50.0;

    final minPanX = min(rawMinPanX, rawMaxPanX);
    final maxPanX = max(rawMinPanX, rawMaxPanX);
    final minPanY = min(rawMinPanY, rawMaxPanY);
    final maxPanY = max(rawMinPanY, rawMaxPanY);

    final constrainedPan = Offset(
      state.panOffset.dx.clamp(minPanX, maxPanX),
      state.panOffset.dy.clamp(minPanY, maxPanY),
    );

    state = state.copyWith(panOffset: constrainedPan);
  }

  // Convert screen coordinates to grid coordinates
  Offset screenToGrid(Offset screenPosition) {
    final config = GridConfiguration(
      rows: state.gridHeight,
      cols: state.gridWidth,
      cellSize: state.gridCellSize,
      scale: state.scale,
      panOffset: state.panOffset,
    );
    return UnifiedCoordinateService().screenToGrid(screenPosition, config);
  }

  // Convert grid coordinates to screen coordinates
  Offset gridToScreen(Offset gridPosition) {
    return Offset(
      gridPosition.dx * state.scaledCellSize + state.panOffset.dx,
      gridPosition.dy * state.scaledCellSize + state.panOffset.dy,
    );
  }

  // Snap screen coordinates to grid with bounds checking
  Offset snapToGrid(Offset screenPosition) {
    final config = GridConfiguration(
      rows: state.gridHeight,
      cols: state.gridWidth,
      cellSize: state.gridCellSize,
      scale: state.scale,
      panOffset: state.panOffset,
    );
    return UnifiedCoordinateService().snapToGrid(screenPosition, config);
  }

  // Check if screen coordinates are within grid bounds
  bool isWithinGridBounds(Offset screenPosition) {
    final config = GridConfiguration(
      rows: state.gridHeight,
      cols: state.gridWidth,
      cellSize: state.gridCellSize,
      scale: state.scale,
      panOffset: state.panOffset,
    );
    return UnifiedCoordinateService()
        .isWithinGridBounds(screenPosition, config);
  }

  // Get valid grid position from screen coordinates (returns null if out of bounds)
  Offset? getValidGridPosition(Offset screenPosition) {
    final config = GridConfiguration(
      rows: state.gridHeight,
      cols: state.gridWidth,
      cellSize: state.gridCellSize,
      scale: state.scale,
      panOffset: state.panOffset,
    );
    return UnifiedCoordinateService()
        .getValidGridPosition(screenPosition, config);
  }

  // Get the grid bounds visible on screen
  Rect getVisibleGridBounds() {
    final config = GridConfiguration(
      rows: state.gridHeight,
      cols: state.gridWidth,
      cellSize: state.gridCellSize,
      scale: state.scale,
      panOffset: state.panOffset,
    );
    return UnifiedCoordinateService()
        .calculateVisibleGridBounds(config, state.canvasSize);
  }

  // Check if a grid position is visible
  bool isGridPositionVisible(Offset gridPosition) {
    final visibleBounds = getVisibleGridBounds();
    return visibleBounds.contains(gridPosition);
  }

  void reset() {
    state = const GameCanvasState(
      gridCellSize: _defaultCellSize,
      scale: 1,
      panOffset: Offset.zero,
      isScaling: false,
      lastScale: 1,
      interactionState: CanvasInteractionState(),
    );

    // Center the grid after reset
    if (state.canvasSize != Size.zero) {
      centerGrid();
    }
  }

  // Debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'gridCellSize': state.gridCellSize,
      'scale': state.scale,
      'panOffset': state.panOffset,
      'scaledCellSize': state.scaledCellSize,
      'canvasSize': state.canvasSize,
      'gridPixelSize': state.gridPixelSize,
      'isScaling': state.isScaling,
      'visibleBounds': getVisibleGridBounds(),
    };
  }
}

/// Provider for GameCanvasStateNotifier
final gameCanvasStateNotifierProvider =
    StateNotifierProvider<GameCanvasStateNotifier, GameCanvasState>(
  (ref) => GameCanvasStateNotifier(),
);
