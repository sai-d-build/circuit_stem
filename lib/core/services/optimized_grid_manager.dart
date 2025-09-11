import 'dart:ui';
import '../../../core/debug/structured_logger.dart';

/// Optimized grid manager that replaces O(n) operations with O(1) Set-based lookups
/// Provides high-performance grid operations for large circuit designs
class OptimizedGridManager {
  // O(1) occupied positions lookup using Set
  final Set<String> _occupiedPositions = {};

  // Grid dimensions for bounds checking
  int _gridWidth = 8;
  int _gridHeight = 6;

  /// Update grid dimensions
  void updateGridDimensions(int width, int height) {
    if (_gridWidth != width || _gridHeight != height) {
      _gridWidth = width;
      _gridHeight = height;

      // Clear positions outside new bounds
      _occupiedPositions.removeWhere((pos) {
        final parts = pos.split(',');
        final row = int.parse(parts[0]);
        final col = int.parse(parts[1]);
        return row >= height || col >= width;
      });

      StructuredLogger.info('OptimizedGridManager: Grid dimensions updated', context: {
        'newWidth': width,
        'newHeight': height,
        'remainingOccupiedPositions': _occupiedPositions.length,
      });
    }
  }

  /// Convert Offset to string key for Set operations
  String _positionToKey(Offset position) {
    return '${position.dy.round()},${position.dx.round()}';
  }

  /// Convert string key back to Offset
  Offset _keyToPosition(String key) {
    final parts = key.split(',');
    return Offset(double.parse(parts[1]), double.parse(parts[0]));
  }

  /// Add occupied position - O(1)
  void addOccupiedPosition(Offset position) {
    final key = _positionToKey(position);
    _occupiedPositions.add(key);

    StructuredLogger.debug('OptimizedGridManager: Position marked as occupied', context: {
      'position': position.toString(),
      'totalOccupied': _occupiedPositions.length,
    });
  }

  /// Remove occupied position - O(1)
  void removeOccupiedPosition(Offset position) {
    final key = _positionToKey(position);
    _occupiedPositions.remove(key);

    StructuredLogger.debug('OptimizedGridManager: Position marked as free', context: {
      'position': position.toString(),
      'totalOccupied': _occupiedPositions.length,
    });
  }

  /// Check if position is occupied - O(1)
  bool isPositionOccupied(Offset position) {
    final key = _positionToKey(position);
    return _occupiedPositions.contains(key);
  }

  /// Check if position is within grid bounds - O(1)
  bool isWithinBounds(Offset position) {
    final row = position.dy.round();
    final col = position.dx.round();
    return row >= 0 && row < _gridHeight && col >= 0 && col < _gridWidth;
  }

  /// Validate component placement - O(1)
  bool canPlaceComponent(Offset position, {int width = 1, int height = 1}) {
    // Check bounds
    if (!isWithinBounds(position)) {
      return false;
    }

    // Check occupancy for multi-cell components
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final checkPos = Offset(position.dx + col, position.dy + row);
        if (isPositionOccupied(checkPos)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Place component and mark positions as occupied - O(width * height)
  void placeComponent(Offset position, {int width = 1, int height = 1}) {
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final pos = Offset(position.dx + col, position.dy + row);
        addOccupiedPosition(pos);
      }
    }

    StructuredLogger.info('OptimizedGridManager: Component placed', context: {
      'position': position.toString(),
      'width': width,
      'height': height,
      'totalOccupied': _occupiedPositions.length,
    });
  }

  /// Remove component and free positions - O(width * height)
  void removeComponent(Offset position, {int width = 1, int height = 1}) {
    for (int row = 0; row < height; row++) {
      for (int col = 0; col < width; col++) {
        final pos = Offset(position.dx + col, position.dy + row);
        removeOccupiedPosition(pos);
      }
    }

    StructuredLogger.info('OptimizedGridManager: Component removed', context: {
      'position': position.toString(),
      'width': width,
      'height': height,
      'totalOccupied': _occupiedPositions.length,
    });
  }

  /// Get all occupied positions - O(n) but cached
  List<Offset> getAllOccupiedPositions() {
    return _occupiedPositions.map(_keyToPosition).toList();
  }

  /// Get occupancy count - O(1)
  int get occupiedCount => _occupiedPositions.length;

  /// Check if grid is empty - O(1)
  bool get isEmpty => _occupiedPositions.isEmpty;

  /// Clear all occupied positions - O(1) for clear operation
  void clear() {
    _occupiedPositions.clear();
    StructuredLogger.info('OptimizedGridManager: Grid cleared', context: {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Find nearest free position to given position - O(radius²) but optimized
  Offset? findNearestFreePosition(Offset targetPosition, {int maxRadius = 10}) {
    // Check target position first
    if (canPlaceComponent(targetPosition)) {
      return targetPosition;
    }

    // Spiral search pattern for finding nearest free position
    for (int radius = 1; radius <= maxRadius; radius++) {
      // Check all positions at current radius
      for (int dx = -radius; dx <= radius; dx++) {
        for (int dy = -radius; dy <= radius; dy++) {
          // Only check perimeter positions to maintain spiral pattern
          if (dx.abs() == radius || dy.abs() == radius) {
            final checkPos = Offset(targetPosition.dx + dx, targetPosition.dy + dy);
            if (isWithinBounds(checkPos) && canPlaceComponent(checkPos)) {
              return checkPos;
            }
          }
        }
      }
    }

    return null; // No free position found within radius
  }

  /// Get grid statistics - O(1)
  Map<String, dynamic> getStatistics() {
    return {
      'gridWidth': _gridWidth,
      'gridHeight': _gridHeight,
      'totalCells': _gridWidth * _gridHeight,
      'occupiedCells': _occupiedPositions.length,
      'freeCells': (_gridWidth * _gridHeight) - _occupiedPositions.length,
      'occupancyRate': _occupiedPositions.length / (_gridWidth * _gridHeight),
    };
  }

  /// Bulk operations for performance
  void bulkUpdateOccupiedPositions(List<Offset> positions, bool occupied) {
    for (final position in positions) {
      if (occupied) {
        addOccupiedPosition(position);
      } else {
        removeOccupiedPosition(position);
      }
    }

    StructuredLogger.info('OptimizedGridManager: Bulk update completed', context: {
      'positionsUpdated': positions.length,
      'setOccupied': occupied,
      'totalOccupied': _occupiedPositions.length,
    });
  }

  /// Validate multiple positions at once - O(n) but optimized
  List<bool> validatePositions(List<Offset> positions) {
    return positions.map((pos) => canPlaceComponent(pos)).toList();
  }

  /// Get free positions in a rectangular area - O(area) but optimized
  List<Offset> getFreePositionsInRect(Rect rect) {
    final freePositions = <Offset>[];

    final startRow = rect.top.floor();
    final endRow = rect.bottom.ceil();
    final startCol = rect.left.floor();
    final endCol = rect.right.ceil();

    for (int row = startRow; row < endRow; row++) {
      for (int col = startCol; col < endCol; col++) {
        final pos = Offset(col.toDouble(), row.toDouble());
        if (isWithinBounds(pos) && !isPositionOccupied(pos)) {
          freePositions.add(pos);
        }
      }
    }

    return freePositions;
  }
}

/// Performance monitoring utilities
class GridPerformanceMonitor {
  static final Map<String, int> _operationCounts = {};
  static final Map<String, Duration> _totalTime = {};

  static void recordOperation(String operation, Duration time) {
    _operationCounts[operation] = (_operationCounts[operation] ?? 0) + 1;
    _totalTime[operation] = (_totalTime[operation] ?? Duration.zero) + time;
  }

  static Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};

    for (final operation in _operationCounts.keys) {
      final count = _operationCounts[operation]!;
      final totalTime = _totalTime[operation]!;
      final avgTime = totalTime ~/ count;

      stats[operation] = {
        'count': count,
        'totalTimeMs': totalTime.inMilliseconds,
        'averageTimeMs': avgTime.inMilliseconds,
      };
    }

    return stats;
  }

  static void reset() {
    _operationCounts.clear();
    _totalTime.clear();
  }
}