import 'package:flutter/material.dart';
import 'dart:math';

class GameCanvasController extends ChangeNotifier {
  static const double _defaultCellSize = 60.0;
  static const double _minScale = 0.5;
  static const double _maxScale = 3.0;

  double _gridCellSize = _defaultCellSize;
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;
  bool _isScaling = false;
  double _lastScale = 1.0;

  // Grid properties
  Size _canvasSize = Size.zero;
  int _gridWidth = 8;  // Default to level size, will be updated
  int _gridHeight = 6; // Default to level size, will be updated
  
  // Getters
  double get gridCellSize => _gridCellSize;
  double get scale => _scale;
  Offset get panOffset => _panOffset;
  Size get canvasSize => _canvasSize;
  int get gridWidth => _gridWidth;
  int get gridHeight => _gridHeight;
  bool get isScaling => _isScaling;
  
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
    final rawMaxPanX = 50.0;
    final rawMinPanY = _canvasSize.height - gridPixelSize.height - 50;
    final rawMaxPanY = 50.0;

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
    final adjustedX = (screenPosition.dx - _panOffset.dx) / scaledCellSize;
    final adjustedY = (screenPosition.dy - _panOffset.dy) / scaledCellSize;
    
    return Offset(
      adjustedX.clamp(0, _gridWidth.toDouble() - 1),
      adjustedY.clamp(0, _gridHeight.toDouble() - 1),
    );
  }
  
  // Convert grid coordinates to screen coordinates
  Offset gridToScreen(Offset gridPosition) {
    return Offset(
      gridPosition.dx * scaledCellSize + _panOffset.dx,
      gridPosition.dy * scaledCellSize + _panOffset.dy,
    );
  }
  
  // Snap screen coordinates to grid
  Offset snapToGrid(Offset screenPosition) {
    final gridPos = screenToGrid(screenPosition);
    final snappedGridPos = Offset(
      gridPos.dx.round().toDouble(),
      gridPos.dy.round().toDouble(),
    );
    return gridToScreen(snappedGridPos);
  }
  
  // Get the grid bounds visible on screen
  Rect getVisibleGridBounds() {
    final topLeft = screenToGrid(Offset.zero);
    final bottomRight = screenToGrid(Offset(_canvasSize.width, _canvasSize.height));
    
    return Rect.fromLTRB(
      topLeft.dx.floor().toDouble(),
      topLeft.dy.floor().toDouble(),
      bottomRight.dx.ceil().toDouble(),
      bottomRight.dy.ceil().toDouble(),
    );
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
  
  void reset() {
    _gridCellSize = _defaultCellSize;
    _scale = 1.0;
    _panOffset = Offset.zero;
    _isScaling = false;
    _lastScale = 1.0;
    
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
  
  @override
  void dispose() {
    super.dispose();
  }
}