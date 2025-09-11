import 'dart:ui';
import 'dart:math' as math;
import '../../../core/services/unified_coordinate_service.dart';

/// Handles coordinate translation between screen coordinates and grid coordinates
class CoordinateTranslator {
  final double _gridCellSize;
  final double _panX;
  final double _panY;
  final double _scale;

  const CoordinateTranslator({
    required double gridCellSize,
    required double panX,
    required double panY,
    required double scale,
  })  : _gridCellSize = gridCellSize,
        _panX = panX,
        _panY = panY,
        _scale = scale;

  /// Convert screen coordinates to grid coordinates
  Offset screenToGrid(Offset screenPos) {
    final config = GridConfiguration(
      rows: 6, // Default or passed
      cols: 8,
      cellSize: _gridCellSize,
      scale: _scale,
      panOffset: Offset(_panX, _panY),
    );
    return UnifiedCoordinateService().screenToGrid(screenPos, config);
  }

  /// Convert grid coordinates to screen coordinates
  Offset gridToScreen(Offset gridPos) {
    final screenX = (gridPos.dx * _gridCellSize * _scale) + _panX;
    final screenY = (gridPos.dy * _gridCellSize * _scale) + _panY;
    
    return Offset(screenX, screenY);
  }

  /// Snap screen coordinates to the nearest grid cell center
  Offset snapToGrid(Offset screenPos) {
    final config = GridConfiguration(
      rows: 6, // Default or passed
      cols: 8,
      cellSize: _gridCellSize,
      scale: _scale,
      panOffset: Offset(_panX, _panY),
    );
    return UnifiedCoordinateService().snapToGrid(screenPos, config);
  }

  /// Get the center position of a grid cell in screen coordinates
  Offset getGridCellCenter(int gridX, int gridY) {
    return gridToScreen(Offset(gridX + 0.5, gridY + 0.5));
  }

  /// Calculate the scaled grid cell size
  double get scaledCellSize => _gridCellSize * _scale;

  /// Check if a point is within the grid bounds
  bool isInGridBounds(Offset gridPos, Size gridSize) {
    final config = GridConfiguration(
      rows: gridSize.height.toInt(),
      cols: gridSize.width.toInt(),
      cellSize: _gridCellSize,
      scale: _scale,
      panOffset: Offset(_panX, _panY),
    );
    return UnifiedCoordinateService().isInGridBounds(gridPos, config);
  }

  /// Calculate the distance between two grid positions
  double gridDistance(Offset pos1, Offset pos2) {
    final dx = pos1.dx - pos2.dx;
    final dy = pos1.dy - pos2.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Get the bounding box of a component in screen coordinates
  Rect getComponentBounds(Offset gridPos, Size componentSize) {
    final screenPos = gridToScreen(gridPos);
    final scaledSize = Size(
      componentSize.width * _scale,
      componentSize.height * _scale,
    );
    
    return Rect.fromCenter(
      center: screenPos,
      width: scaledSize.width,
      height: scaledSize.height,
    );
  }

  /// Convert a size from grid units to screen pixels
  Size gridSizeToScreen(Size gridSize) {
    return Size(
      gridSize.width * _gridCellSize * _scale,
      gridSize.height * _gridCellSize * _scale,
    );
  }

  /// Convert a size from screen pixels to grid units
  Size screenSizeToGrid(Size screenSize) {
    return Size(
      screenSize.width / (_gridCellSize * _scale),
      screenSize.height / (_gridCellSize * _scale),
    );
  }

  /// Get the grid position that encompasses a screen area
  Rect getGridRect(Rect screenRect) {
    final config = GridConfiguration(
      rows: 6, // Default or passed
      cols: 8,
      cellSize: _gridCellSize,
      scale: _scale,
      panOffset: Offset(_panX, _panY),
    );
    final topLeft = UnifiedCoordinateService().screenToGrid(screenRect.topLeft, config);
    final bottomRight = UnifiedCoordinateService().screenToGrid(screenRect.bottomRight, config);
    
    return Rect.fromPoints(
      Offset(topLeft.dx.floor().toDouble(), topLeft.dy.floor().toDouble()),
      Offset(bottomRight.dx.ceil().toDouble(), bottomRight.dy.ceil().toDouble()),
    );
  }

  /// Create a new translator with updated transformation parameters
  CoordinateTranslator copyWith({
    double? gridCellSize,
    double? panX,
    double? panY,
    double? scale,
  }) {
    return CoordinateTranslator(
      gridCellSize: gridCellSize ?? _gridCellSize,
      panX: panX ?? _panX,
      panY: panY ?? _panY,
      scale: scale ?? _scale,
    );
  }

  /// Current transformation parameters
  double get gridCellSize => _gridCellSize;
  double get panX => _panX;
  double get panY => _panY;
  double get scale => _scale;
}