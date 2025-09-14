import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/config/grid_config_constants.dart';

/// Simple coordinate conversion strategy for 20×20 grid system
class GridConversionStrategy {
  /// Convert screen position to grid coordinates (always 20×20)
  GridPosition screenToGrid(Offset screenPos, ViewportState viewport) {
    // Apply viewport transformations
    final adjustedX = (screenPos.dx - viewport.panOffset.dx) / viewport.scale;
    final adjustedY = (screenPos.dy - viewport.panOffset.dy) / viewport.scale;

    // Convert to grid coordinates using floor() for consistency
    final col = (adjustedX / viewport.cellSize).floor().clamp(0, 19);
    final row = (adjustedY / viewport.cellSize).floor().clamp(0, 19);

    logConversion('screenToGrid', screenPos, viewport, GridPosition(row: row, col: col));

    return GridPosition(row: row, col: col);
  }

  /// Convert grid position back to screen coordinates
  Offset gridToScreen(GridPosition gridPos, ViewportState viewport) {
    final screenX = (gridPos.col * viewport.cellSize * viewport.scale) + viewport.panOffset.dx;
    final screenY = (gridPos.row * viewport.cellSize * viewport.scale) + viewport.panOffset.dy;

    return Offset(screenX, screenY);
  }

  /// Check if position is within visual grid bounds
  bool isWithinBounds(GridPosition pos) {
    return GridConfigConstants.isWithinVisualBounds(pos.row, pos.col);
  }

  /// Snap position to nearest valid grid cell
  GridPosition snapToGrid(Offset screenPos, ViewportState viewport) {
    final gridPos = screenToGrid(screenPos, viewport);
    return gridPos; // Already clamped in screenToGrid
  }

  // Helper method for logging conversions
  void logConversion(String operation, Offset input, ViewportState viewport, GridPosition output) {
    StructuredLogger.trace('$operation conversion', context: {
      'operation': operation,
      'input': '${input.dx.toInt()},${input.dy.toInt()}',
      'output': '${output.row},${output.col}',
      'scale': viewport.scale,
      'cellSize': viewport.cellSize,
      'index': output.row * 20 + output.col,
    });
  }
}

/// Grid position with row and column for 20×20 grid
class GridPosition {
  final int row;
  final int col;

  const GridPosition({
    required this.row,
    required this.col,
  });

  // Computed properties
  int get index => row * 20 + col;

  // Bounds checking
  bool get isValid => GridConfigConstants.isWithinVisualBounds(row, col);

  // Distance calculation
  double distanceTo(GridPosition other) {
    final dx = (col - other.col).toDouble();
    final dy = (row - other.row).toDouble();
    return math.sqrt(dx * dx + dy * dy);
  }

  // Equality
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition && other.row == row && other.col == col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'GridPosition($row, $col)';

  /// Convert to Offset for compatibility
  Offset toOffset() => Offset(col.toDouble(), row.toDouble());
}

/// Viewport state for coordinate transformations
class ViewportState {
  final double scale;
  final Offset panOffset;
  final double cellSize;

  const ViewportState({
    required this.scale,
    required this.panOffset,
    required this.cellSize,
  });

  // Default state
  static const ViewportState defaultState = ViewportState(
    scale: 1.0,
    panOffset: Offset.zero,
    cellSize: GridConfigConstants.gridCellSize,
  );
}