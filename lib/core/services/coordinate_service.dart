import 'package:flutter/material.dart';
import '../entity/grid_configuration.dart';
import 'unified_coordinate_service.dart';
import '../entity/grid_configuration.dart';

/// Canonical coordinate conversion service that provides a single source of truth
/// for all screen ↔ grid transformations in the application.
class CoordinateService {
  static const double defaultCellSize = 60;

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

  /// Create from provided parameters (breaks circular dependency)
  factory CoordinateService.fromParameters({
    required double cellSize,
    required double scale,
    required Offset panOffset,
    required int gridWidth,
    required int gridHeight,
  }) {
    return CoordinateService(
      cellSize: cellSize,
      scale: scale,
      panOffset: panOffset,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
    );
  }

  /// Get the scaled cell size
  double get scaledCellSize => cellSize * scale;

  /// Convert screen coordinates to grid coordinates
  Offset screenToGrid(Offset screenPos) {
    final config = GridConfiguration(
      rows: gridHeight,
      cols: gridWidth,
      cellSize: cellSize,
      scale: scale,
      panOffset: panOffset,
    );
    return UnifiedCoordinateService().screenToGrid(screenPos, config);
  }

  /// Convert grid coordinates to screen coordinates
  Offset gridToScreen(Offset gridPos) {
    final config = GridConfiguration(
      rows: gridHeight,
      cols: gridWidth,
      cellSize: cellSize,
      scale: scale,
      panOffset: panOffset,
    );
    return UnifiedCoordinateService().gridToScreen(gridPos, config);
  }

  /// Snap screen coordinates to nearest grid cell center
  Offset snapScreenToGrid(Offset screenPos) {
    final config = GridConfiguration(
      rows: gridHeight,
      cols: gridWidth,
      cellSize: cellSize,
      scale: scale,
      panOffset: panOffset,
    );
    return UnifiedCoordinateService().snapToGrid(screenPos, config);
  }

  /// Get valid grid position from screen coordinates (returns null if out of bounds)
  Offset? getValidGridPosition(Offset screenPosition) {
    final config = GridConfiguration(
      rows: gridHeight,
      cols: gridWidth,
      cellSize: cellSize,
      scale: scale,
      panOffset: panOffset,
    );
    return UnifiedCoordinateService()
        .getValidGridPosition(screenPosition, config);
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
    final config = GridConfiguration(
      rows: gridHeight,
      cols: gridWidth,
      cellSize: cellSize,
      scale: scale,
      panOffset: panOffset,
    );
    return UnifiedCoordinateService()
        .isWithinGridBounds(screenPosition, config);
  }

  /// Get the center position of a grid cell in screen coordinates
  Offset getGridCellCenter(int gridX, int gridY) {
    return gridToScreen(Offset(gridX.toDouble() + 0.5, gridY.toDouble() + 0.5));
  }

  /// Calculate visible grid bounds based on screen size
  Rect calculateVisibleGridBounds(Size screenSize) {
    final config = GridConfiguration(
      rows: gridHeight,
      cols: gridWidth,
      cellSize: cellSize,
      scale: scale,
      panOffset: panOffset,
    );
    return UnifiedCoordinateService()
        .calculateVisibleGridBounds(config, screenSize);
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
