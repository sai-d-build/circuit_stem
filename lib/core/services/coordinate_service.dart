import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/game_canvas_controller.dart';

/// Canonical coordinate conversion service that provides a single source of truth
/// for all screen ↔ grid transformations in the application.
class CoordinateService {
  static const double defaultCellSize = 60.0;

  /// Configuration for coordinate transformations
  final double cellSize;
  final double scale;
  final Offset panOffset;
  final int gridWidth;
  final int gridHeight;

  const CoordinateService({
    required this.cellSize,
    required this.scale,
    required this.panOffset,
    required this.gridWidth,
    required this.gridHeight,
  });

  /// Create from GameCanvasController (canonical source)
  factory CoordinateService.fromController(GameCanvasController controller) {
    return CoordinateService(
      cellSize: controller.gridCellSize,
      scale: controller.scale,
      panOffset: controller.panOffset,
      gridWidth: controller.gridWidth,
      gridHeight: controller.gridHeight,
    );
  }

  /// Get the scaled cell size
  double get scaledCellSize => cellSize * scale;

  /// Convert screen coordinates to grid coordinates
  Offset screenToGrid(Offset screenPos) {
    // Reverse pan and scale transformations
    final adjustedX = (screenPos.dx - panOffset.dx) / scaledCellSize;
    final adjustedY = (screenPos.dy - panOffset.dy) / scaledCellSize;

    return Offset(adjustedX, adjustedY);
  }

  /// Convert grid coordinates to screen coordinates
  Offset gridToScreen(Offset gridPos) {
    final screenX = (gridPos.dx * scaledCellSize) + panOffset.dx;
    final screenY = (gridPos.dy * scaledCellSize) + panOffset.dy;

    return Offset(screenX, screenY);
  }

  /// Snap screen coordinates to nearest grid cell center
  Offset snapScreenToGrid(Offset screenPos) {
    final gridPos = screenToGrid(screenPos);
    final snappedGridPos = Offset(
      gridPos.dx.round().toDouble(),
      gridPos.dy.round().toDouble(),
    );
    return gridToScreen(snappedGridPos);
  }

  /// Get valid grid position from screen coordinates (returns null if out of bounds)
  Offset? getValidGridPosition(Offset screenPosition) {
    final gridPos = screenToGrid(screenPosition);
    final snappedPos = Offset(
      gridPos.dx.round().toDouble(),
      gridPos.dy.round().toDouble(),
    );

    if (isValidGridPosition(snappedPos)) {
      return snappedPos;
    }
    return null;
  }

  /// Check if grid coordinates are within bounds
  bool isValidGridPosition(Offset gridPos) {
    return gridPos.dx >= 0 &&
           gridPos.dy >= 0 &&
           gridPos.dx < gridWidth &&
           gridPos.dy < gridHeight;
  }

  /// Check if screen coordinates are within grid bounds
  bool isWithinGridBounds(Offset screenPosition) {
    final gridPos = screenToGrid(screenPosition);
    return isValidGridPosition(gridPos);
  }

  /// Get the center position of a grid cell in screen coordinates
  Offset getGridCellCenter(int gridX, int gridY) {
    return gridToScreen(Offset(gridX.toDouble() + 0.5, gridY.toDouble() + 0.5));
  }

  /// Calculate visible grid bounds based on screen size
  Rect calculateVisibleGridBounds(Size screenSize) {
    final topLeft = screenToGrid(Offset.zero);
    final bottomRight = screenToGrid(Offset(screenSize.width, screenSize.height));

    return Rect.fromLTRB(
      topLeft.dx.floor().toDouble(),
      topLeft.dy.floor().toDouble(),
      bottomRight.dx.ceil().toDouble(),
      bottomRight.dy.ceil().toDouble(),
    );
  }

  /// Check if a grid position is visible on screen
  bool isGridPositionVisible(Offset gridPosition, Size screenSize) {
    final visibleBounds = calculateVisibleGridBounds(screenSize);
    return visibleBounds.contains(gridPosition);
  }

  /// Get Matrix4 transform for consistent rendering
  Matrix4 getTransformMatrix() {
    return Matrix4.identity()
      ..translate(panOffset.dx, panOffset.dy)
      ..scale(scale, scale);
  }

  /// Apply transform to canvas for consistent rendering
  void applyTransformToCanvas(Canvas canvas) {
    canvas.transform(getTransformMatrix().storage);
  }

  /// Create a copy with modified values
  CoordinateService copyWith({
    double? cellSize,
    double? scale,
    Offset? panOffset,
    int? gridWidth,
    int? gridHeight,
  }) {
    return CoordinateService(
      cellSize: cellSize ?? this.cellSize,
      scale: scale ?? this.scale,
      panOffset: panOffset ?? this.panOffset,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CoordinateService) return false;
    return cellSize == other.cellSize &&
           scale == other.scale &&
           panOffset == other.panOffset &&
           gridWidth == other.gridWidth &&
           gridHeight == other.gridHeight;
  }

  @override
  int get hashCode {
    return Object.hash(cellSize, scale, panOffset, gridWidth, gridHeight);
  }

  @override
  String toString() {
    return 'CoordinateService(cellSize: $cellSize, scale: $scale, panOffset: $panOffset, gridSize: ${gridWidth}x$gridHeight)';
  }
}