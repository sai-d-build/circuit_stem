import 'dart:math';
import '../entity/grid_configuration.dart';

import 'package:flutter/material.dart';
import 'package:sparkcircuit/core/services/coordinate_service.dart';
import 'package:sparkcircuit/core/services/unified_coordinate_service.dart';

/// Interaction modes for the canvas
enum CanvasInteractionMode {
  idle,
  panning,
  draggingExisting,
  placingFromPalette,
  drawingWire,
}

/// Gesture state machine for canvas interactions
class CanvasInteractionState {
  CanvasInteractionMode mode;
  Offset? dragStartPosition;
  String? draggedComponentId;
  String? placingComponentType;

  CanvasInteractionState({
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

class GameCanvasController extends ChangeNotifier {
  static const double _defaultCellSize = 60;
  static const double _minScale = 0.5;
  static const double _maxScale = 3;

  double _gridCellSize = _defaultCellSize;
  double _scale = 1;
  Offset _panOffset = Offset.zero;
  bool _isScaling = false;
  double _lastScale = 1;

  // Grid properties
  Size _canvasSize = Size.zero;
  int _gridWidth = 8; // Default to level size, will be updated
  int _gridHeight = 6; // Default to level size, will be updated

  // Interaction state machine
  CanvasInteractionState _interactionState = CanvasInteractionState();

  // FSM methods
  void transitionToIdle() {
    _interactionState = _interactionState.copyWith(
      mode: CanvasInteractionMode.idle,
      dragStartPosition: null,
      draggedComponentId: null,
      placingComponentType: null,
    );
    notifyListeners();
  }

  void startDraggingComponent(String componentId, Offset startPosition) {
    _interactionState = _interactionState.copyWith(
      mode: CanvasInteractionMode.draggingExisting,
      dragStartPosition: startPosition,
      draggedComponentId: componentId,
    );
    notifyListeners();
  }

  void startPlacingFromPalette(String componentType, Offset startPosition) {
    _interactionState = _interactionState.copyWith(
      mode: CanvasInteractionMode.placingFromPalette,
      dragStartPosition: startPosition,
      placingComponentType: componentType,
    );
    notifyListeners();
  }

  void startPanning(Offset startPosition) {
    _interactionState = _interactionState.copyWith(
      mode: CanvasInteractionMode.panning,
      dragStartPosition: startPosition,
    );
    notifyListeners();
  }

  void startDrawingWire(Offset startPosition) {
    _interactionState = _interactionState.copyWith(
      mode: CanvasInteractionMode.drawingWire,
      dragStartPosition: startPosition,
    );
    notifyListeners();
  }

  void updateDragPosition(Offset currentPosition) {
    // Update drag position but don't change mode
    _interactionState = _interactionState.copyWith(
      dragStartPosition: currentPosition,
    );
    // Don't notify listeners for performance - let caller handle
  }

  void endCurrentInteraction() {
    transitionToIdle();
  }

  // Query methods for FSM state
  bool get isIdle => _interactionState.mode == CanvasInteractionMode.idle;
  bool get isDraggingComponent =>
      _interactionState.mode == CanvasInteractionMode.draggingExisting;
  bool get isPlacingFromPalette =>
      _interactionState.mode == CanvasInteractionMode.placingFromPalette;
  bool get isPanning => _interactionState.mode == CanvasInteractionMode.panning;
  bool get isDrawingWire =>
      _interactionState.mode == CanvasInteractionMode.drawingWire;

  // Getters
  double get gridCellSize => _gridCellSize;
  double get scale => _scale;
  Offset get panOffset => _panOffset;
  Size get canvasSize => _canvasSize;
  int get gridWidth => _gridWidth;
  int get gridHeight => _gridHeight;
  bool get isScaling => _isScaling;
  CanvasInteractionState get interactionState => _interactionState;

  // Coordinate service getter
  CoordinateService get coordinateService =>
      CoordinateService.fromController(this);

  // Calculated properties
  double get scaledCellSize => _gridCellSize * _scale;
  Size get gridPixelSize => Size(
        _gridWidth * scaledCellSize,
        _gridHeight * scaledCellSize,
      );

  void updateCanvasSize(Size size) {
    if (_canvasSize != size) {
      _canvasSize = size;
      _constrainPan();
      notifyListeners();
    }
  }

  void updateGridSize(int width, int height) {
    if (_gridWidth != width || _gridHeight != height) {
      _gridWidth = width;
      _gridHeight = height;
      _constrainPan();
      notifyListeners();
    }
  }

  void updatePan(Offset delta) {
    _panOffset = _panOffset + delta;
    _constrainPan();
    notifyListeners();
  }

  void setPan(Offset newPan) {
    _panOffset = newPan;
    _constrainPan();
    notifyListeners();
  }

  void startScale() {
    _isScaling = true;
    _lastScale = _scale;
  }

  void updateScale(double scaleValue) {
    if (!_isScaling) return;

    final newScale = (_lastScale * scaleValue).clamp(_minScale, _maxScale);
    if (newScale != _scale) {
      _scale = newScale;
      _constrainPan();
      notifyListeners();
    }
  }

  void endScale() {
    _isScaling = false;
  }

  void zoomIn() {
    final newScale = (_scale * 1.2).clamp(_minScale, _maxScale);
    if (newScale != _scale) {
      _scale = newScale;
      _constrainPan();
      notifyListeners();
    }
  }

  void zoomOut() {
    final newScale = (_scale / 1.2).clamp(_minScale, _maxScale);
    if (newScale != _scale) {
      _scale = newScale;
      _constrainPan();
      notifyListeners();
    }
  }

  void resetZoom() {
    _scale = 1.0;
    _constrainPan();
    notifyListeners();
  }

  void centerGrid() {
    if (_canvasSize == Size.zero) return;

    final gridPixelSize = this.gridPixelSize;
    _panOffset = Offset(
      (_canvasSize.width - gridPixelSize.width) / 2,
      (_canvasSize.height - gridPixelSize.height) / 2,
    );
    notifyListeners();
  }

  void focusOnComponent(Offset gridPosition) {
    if (_canvasSize == Size.zero) return;

    final screenPosition = Offset(
      gridPosition.dx * scaledCellSize,
      gridPosition.dy * scaledCellSize,
    );

    _panOffset = Offset(
      _canvasSize.width / 2 - screenPosition.dx,
      _canvasSize.height / 2 - screenPosition.dy,
    );

    _constrainPan();
    notifyListeners();
  }

  void _constrainPan() {
    if (_canvasSize == Size.zero) return;

    final gridPixelSize = this.gridPixelSize;

    // Calculate bounds for panning
    final rawMinPanX = _canvasSize.width - gridPixelSize.width - 50;
    const rawMaxPanX = 50.0;
    final rawMinPanY = _canvasSize.height - gridPixelSize.height - 50;
    const rawMaxPanY = 50.0;

    final minPanX = min(rawMinPanX, rawMaxPanX);
    final maxPanX = max(rawMinPanX, rawMaxPanX);
    final minPanY = min(rawMinPanY, rawMaxPanY);
    final maxPanY = max(rawMinPanY, rawMaxPanY);

    _panOffset = Offset(
      _panOffset.dx.clamp(minPanX, maxPanX),
      _panOffset.dy.clamp(minPanY, maxPanY),
    );
  }

  // Convert screen coordinates to grid coordinates
  Offset screenToGrid(Offset screenPosition) {
    return UnifiedCoordinateService().screenToGrid(
      screenPosition,
      GridConfiguration(
        rows: _gridHeight,
        cols: _gridWidth,
        cellSize: _gridCellSize,
        scale: _scale,
        panOffset: _panOffset,
      ),
    );
  }

  // Convert grid coordinates to screen coordinates
  Offset gridToScreen(Offset gridPosition) {
    final config = GridConfiguration(
      rows: _gridHeight,
      cols: _gridWidth,
      cellSize: _gridCellSize,
      scale: _scale,
      panOffset: _panOffset,
    );
    return UnifiedCoordinateService().gridToScreen(gridPosition, config);
  }

  // Snap screen coordinates to grid with bounds checking
  Offset snapToGrid(Offset screenPosition) {
    final config = GridConfiguration(
      rows: _gridHeight,
      cols: _gridWidth,
      cellSize: _gridCellSize,
      scale: _scale,
      panOffset: _panOffset,
    );
    return UnifiedCoordinateService().snapToGrid(screenPosition, config);
  }

  // Check if screen coordinates are within grid bounds
  bool isWithinGridBounds(Offset screenPosition) {
    final config = GridConfiguration(
      rows: _gridHeight,
      cols: _gridWidth,
      cellSize: _gridCellSize,
      scale: _scale,
      panOffset: _panOffset,
    );
    return UnifiedCoordinateService()
        .isWithinGridBounds(screenPosition, config);
  }

  // Get valid grid position from screen coordinates (returns null if out of bounds)
  Offset? getValidGridPosition(Offset screenPosition) {
    final config = GridConfiguration(
      rows: _gridHeight,
      cols: _gridWidth,
      cellSize: _gridCellSize,
      scale: _scale,
      panOffset: _panOffset,
    );
    return UnifiedCoordinateService()
        .getValidGridPosition(screenPosition, config);
  }

  // Get the grid bounds visible on screen
  Rect getVisibleGridBounds() {
    final config = GridConfiguration(
      rows: _gridHeight,
      cols: _gridWidth,
      cellSize: _gridCellSize,
      scale: _scale,
      panOffset: _panOffset,
    );
    return UnifiedCoordinateService()
        .calculateVisibleGridBounds(config, _canvasSize);
  }

  // Check if a grid position is visible
  bool isGridPositionVisible(Offset gridPosition) {
    final visibleBounds = getVisibleGridBounds();
    return visibleBounds.contains(gridPosition);
  }

  // Animation support
  void animatePanTo(
    Offset targetPan, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    // This would be implemented with an AnimationController
    // For now, we'll just set the pan directly
    setPan(targetPan);
  }

  void animateScaleTo(
    double targetScale, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    // This would be implemented with an AnimationController
    // For now, we'll just set the scale directly
    final constrainedScale = targetScale.clamp(_minScale, _maxScale);
    _scale = constrainedScale;
    _constrainPan();
    notifyListeners();
  }

  // Interaction state management (FSM)
  void setInteractionMode(
    CanvasInteractionMode mode, {
    Offset? dragStartPosition,
    String? draggedComponentId,
    String? placingComponentType,
  }) {
    _interactionState = _interactionState.copyWith(
      mode: mode,
      dragStartPosition: dragStartPosition,
      draggedComponentId: draggedComponentId,
      placingComponentType: placingComponentType,
    );
    notifyListeners();
  }

  void reset() {
    _gridCellSize = _defaultCellSize;
    _scale = 1.0;
    _panOffset = Offset.zero;
    _isScaling = false;
    _lastScale = 1.0;
    _interactionState = CanvasInteractionState(); // Reset FSM

    // Center the grid after reset
    if (_canvasSize != Size.zero) {
      centerGrid();
    } else {
      notifyListeners();
    }
  }

  // Debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'gridCellSize': _gridCellSize,
      'scale': _scale,
      'panOffset': _panOffset,
      'scaledCellSize': scaledCellSize,
      'canvasSize': _canvasSize,
      'gridPixelSize': gridPixelSize,
      'isScaling': _isScaling,
      'visibleBounds': getVisibleGridBounds(),
    };
  }
}
