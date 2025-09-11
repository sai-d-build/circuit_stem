import 'dart:ui';
import 'dart:math' as math;
import '../../domain/entities/core/grid.dart';
import '../../domain/entities/core/component.dart';
import 'unified_coordinate_service.dart';

// Re-export GridConfiguration from unified_coordinate_service for backward compatibility
export 'unified_coordinate_service.dart' show GridConfiguration;

/// Configuration for grid rendering
class RenderConfiguration {
  final Color gridLineColor;
  final Color majorGridLineColor;
  final double strokeWidth;
  final double majorStrokeWidth;
  final int majorGridInterval;
  final bool showCoordinates;
  final bool showOrigin;

  const RenderConfiguration({
    required this.gridLineColor,
    required this.majorGridLineColor,
    this.strokeWidth = 0.5,
    this.majorStrokeWidth = 1.0,
    this.majorGridInterval = 5,
    this.showCoordinates = false,
    this.showOrigin = true,
  });
}

/// Centralized service for all grid-related operations
class GridService {
  /// Coordinate translation: screen coordinates to grid coordinates
  static Offset screenToGrid(Offset screenPos, GridConfiguration config) {
    return UnifiedCoordinateService().screenToGrid(screenPos, config);
  }

  /// Coordinate translation: grid coordinates to screen coordinates
  static Offset gridToScreen(Offset gridPos, GridConfiguration config) {
    final screenX = (gridPos.dx * config.cellSize * config.scale) + config.panOffset.dx;
    final screenY = (gridPos.dy * config.cellSize * config.scale) + config.panOffset.dy;

    return Offset(screenX, screenY);
  }

  /// Snap screen coordinates to nearest grid cell center
  static Offset snapToGrid(Offset screenPos, GridConfiguration config) {
    return UnifiedCoordinateService().snapToGrid(screenPos, config); // Returns screen coordinates as per original implementation
  }

  /// Get the center position of a grid cell in screen coordinates
  static Offset getGridCellCenter(int gridX, int gridY, GridConfiguration config) {
    return gridToScreen(Offset(gridX.toDouble() + 0.5, gridY.toDouble() + 0.5), config);
  }

  /// Check if a grid position is within grid bounds
  static bool isInGridBounds(Offset gridPos, GridConfiguration config) {
    return gridPos.dx >= 0 &&
           gridPos.dy >= 0 &&
           gridPos.dx < config.cols &&
           gridPos.dy < config.rows;
  }

  /// Check if screen coordinates are within visible grid bounds
  static bool isWithinGridBounds(Offset screenPosition, GridConfiguration config) {
    return UnifiedCoordinateService().isWithinGridBounds(screenPosition, config);
  }

  /// Get valid grid position from screen coordinates (returns null if out of bounds)
  static Offset? getValidGridPosition(Offset screenPosition, GridConfiguration config) {
    return UnifiedCoordinateService().getValidGridPosition(screenPosition, config);
  }

  /// Calculate distance between two grid positions
  static double gridDistance(Offset pos1, Offset pos2) {
    final dx = pos1.dx - pos2.dx;
    final dy = pos1.dy - pos2.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Check if a position is valid for component placement
  static bool canPlaceComponent(ComponentModel component, Grid grid) {
    return grid.canPlaceComponent(component.row, component.col);
  }

  /// Check if a component can be moved to a new position
  static bool canMoveComponent(ComponentModel component, int newRow, int newCol, Grid grid) {
    return grid.canPlaceComponent(newRow, newCol);
  }

  /// Get the bounding box of a component in screen coordinates
  static Rect getComponentBounds(Offset gridPos, Size componentSize, GridConfiguration config) {
    final screenPos = gridToScreen(gridPos, config);
    final scaledSize = Size(
      componentSize.width * config.scale,
      componentSize.height * config.scale,
    );

    return Rect.fromCenter(
      center: screenPos,
      width: scaledSize.width,
      height: scaledSize.height,
    );
  }

  /// Get the scaled grid cell size
  static double getScaledCellSize(GridConfiguration config) {
    return config.cellSize * config.scale;
  }

  /// Find all valid grid positions in a screen area
  static List<Offset> getGridPositionsInScreenRect(Rect screenRect, GridConfiguration config) {
    final topLeft = screenToGrid(screenRect.topLeft, config);
    final bottomRight = screenToGrid(screenRect.bottomRight, config);

    final startRow = topLeft.dy.floor();
    final endRow = bottomRight.dy.ceil();
    final startCol = topLeft.dx.floor();
    final endCol = bottomRight.dx.ceil();

    final positions = <Offset>[];
    for (int row = startRow; row <= endRow; row++) {
      for (int col = startCol; col <= endCol; col++) {
        final gridPos = Offset(col.toDouble(), row.toDouble());
        if (isInGridBounds(gridPos, config)) {
          positions.add(gridPos);
        }
      }
    }

    return positions;
  }

  /// Render grid lines on canvas
  static void paintGridLines(
    Canvas canvas,
    Size size,
    GridConfiguration config,
    RenderConfiguration renderConfig,
  ) {
    final regularPaint = Paint()
      ..color = renderConfig.gridLineColor
      ..strokeWidth = renderConfig.strokeWidth
      ..style = PaintingStyle.stroke;

    final majorPaint = Paint()
      ..color = renderConfig.majorGridLineColor
      ..strokeWidth = renderConfig.majorStrokeWidth
      ..style = PaintingStyle.stroke;

    final scaledCellSize = getScaledCellSize(config);

    // Draw vertical lines
    for (int i = 0; i <= config.cols; i++) {
      final x = i * scaledCellSize + config.panOffset.dx;
      if (x >= -renderConfig.strokeWidth && x <= size.width + renderConfig.strokeWidth) {
        final paint = (i % renderConfig.majorGridInterval == 0) ? majorPaint : regularPaint;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }

    // Draw horizontal lines
    for (int i = 0; i <= config.rows; i++) {
      final y = i * scaledCellSize + config.panOffset.dy;
      if (y >= -renderConfig.strokeWidth && y <= size.height + renderConfig.strokeWidth) {
        final paint = (i % renderConfig.majorGridInterval == 0) ? majorPaint : regularPaint;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
    }
  }

  /// Render grid origin marker
  static void paintGridOrigin(
    Canvas canvas,
    Size size,
    GridConfiguration config,
  ) {
    final originX = config.panOffset.dx;
    final originY = config.panOffset.dy;

    if (originX >= -20 && originX <= size.width + 20 &&
        originY >= -20 && originY <= size.height + 20) {

      final originPaint = Paint()
        ..color = const Color(0xFFFF0000).withValues(alpha: 0.8)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final originCenter = Paint()
        ..color = const Color(0xFFFF0000).withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(originX, originY), 4, originCenter);
      canvas.drawCircle(Offset(originX, originY), 4, originPaint);

      // Draw axes
      const axisLength = 15.0;
      canvas.drawLine(
        Offset(originX - axisLength, originY),
        Offset(originX + axisLength, originY),
        originPaint,
      );
      canvas.drawLine(
        Offset(originX, originY - axisLength),
        Offset(originX, originY + axisLength),
        originPaint,
      );
    }
  }

  /// Calculate visible grid bounds based on screen size
  static Rect calculateVisibleGridBounds(GridConfiguration config, Size screenSize) {
    return UnifiedCoordinateService().calculateVisibleGridBounds(config, screenSize);
  }

  /// Check if a grid position is visible on screen
  static bool isGridPositionVisible(Offset gridPosition, GridConfiguration config, Size screenSize) {
    final visibleBounds = calculateVisibleGridBounds(config, screenSize);
    return visibleBounds.contains(gridPosition);
  }
}

/// Core grid service with consolidated coordinate operations
/// GridConfiguration exported from unified_coordinate_service.dart for system-wide access

/// Constants used throughout grid operations
class GridConstants {
  static const double defaultCellSize = 60.0;
  static const double minCellSize = 20.0;
  static const double maxCellSize = 100.0;
  static const double minScale = 0.5;
  static const double maxScale = 3.0;
  static const int defaultMajorGridInterval = 5;
  static const Color defaultGridLineColor = Color(0xFFE0E0E0);
  static const Color defaultMajorGridLineColor = Color(0xFFBBBBBB);
}