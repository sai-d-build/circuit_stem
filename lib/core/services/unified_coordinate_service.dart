import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'secure_coordinate_validator.dart';

// Cache entry classes for performance optimization
class _CacheEntry {
  final dynamic value;
  final DateTime timestamp;

  const _CacheEntry(this.value, this.timestamp);
}

class _ValidationEntry {
  final bool isValid;
  final DateTime timestamp;

  const _ValidationEntry(this.isValid, this.timestamp);
}

/// Unified coordinate service that consolidates all coordinate-related operations
/// This service provides a single interface for all coordinate transformations
/// while maintaining backward compatibility with existing GridService usage
class UnifiedCoordinateService {
  static final UnifiedCoordinateService _instance = UnifiedCoordinateService._();
  factory UnifiedCoordinateService() => _instance;
  UnifiedCoordinateService._();

  // Performance optimization: LRU cache for coordinate transformations
  final Map<String, _CacheEntry> _coordinateCache = {};
  static const int _maxCacheSize = 1000;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // Security: Input sanitization cache to prevent repeated validation
  final Map<String, _ValidationEntry> _validationCache = {};
  static const int _maxValidationCacheSize = 500;

  // Grid configuration constants
  static const double defaultCellSize = 60.0;
  static const double minCellSize = 20.0;
  static const double maxCellSize = 100.0;
  static const double minScale = 0.5;
  static const double maxScale = 3.0;

  // Cache management
  void _manageCacheSize() {
    if (_coordinateCache.length > _maxCacheSize) {
      // Remove oldest entries (simple LRU approximation)
      final keysToRemove = _coordinateCache.keys.take(_coordinateCache.length - _maxCacheSize + 100);
      for (final key in keysToRemove) {
        _coordinateCache.remove(key);
      }
    }

    if (_validationCache.length > _maxValidationCacheSize) {
      final keysToRemove = _validationCache.keys.take(_validationCache.length - _maxValidationCacheSize + 50);
      for (final key in keysToRemove) {
        _validationCache.remove(key);
      }
    }
  }

  // Clean expired cache entries
  void _cleanExpiredCache() {
    final now = DateTime.now();
    _coordinateCache.removeWhere((key, entry) => now.difference(entry.timestamp) > _cacheExpiration);
    _validationCache.removeWhere((key, entry) => now.difference(entry.timestamp) > _cacheExpiration);
  }

  /// Coordinate translation: screen coordinates to grid coordinates
  Offset screenToGrid(Offset screenPos, GridConfiguration config) {
    // Check cache first for performance
    final cacheKey = 'screenToGrid_${screenPos.dx}_${screenPos.dy}_${config.hashCode}';
    final cached = _coordinateCache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheExpiration) {
      return cached.value as Offset;
    }

    // 🛡️ SECURITY: Sanitize input position
    final sanitizedPos = SecureCoordinateValidator.sanitizePosition(screenPos);

    // Reverse pan and scale transformations
    final adjustedX = (sanitizedPos.dx - config.panOffset.dx) / config.scale;
    final adjustedY = (sanitizedPos.dy - config.panOffset.dy) / config.scale;

    // Convert to grid coordinates
    final gridX = adjustedX / config.cellSize;
    final gridY = adjustedY / config.cellSize;

    final result = Offset(gridX, gridY);

    // Cache the result
    _coordinateCache[cacheKey] = _CacheEntry(result, DateTime.now());
    _manageCacheSize();

    return result;
  }

  /// Coordinate translation: grid coordinates to screen coordinates
  Offset gridToScreen(Offset gridPos, GridConfiguration config) {
    // Check cache first for performance
    final cacheKey = 'gridToScreen_${gridPos.dx}_${gridPos.dy}_${config.hashCode}';
    final cached = _coordinateCache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheExpiration) {
      return cached.value as Offset;
    }

    final screenX = (gridPos.dx * config.cellSize * config.scale) + config.panOffset.dx;
    final screenY = (gridPos.dy * config.cellSize * config.scale) + config.panOffset.dy;

    final result = Offset(screenX, screenY);

    // Cache the result
    _coordinateCache[cacheKey] = _CacheEntry(result, DateTime.now());
    _manageCacheSize();

    return result;
  }

  /// Snap screen coordinates to nearest grid cell center
  Offset snapToGrid(Offset screenPos, GridConfiguration config) {
    final gridPos = screenToGrid(screenPos, config);
    final snappedGridPos = Offset(
      gridPos.dx.round().toDouble(),
      gridPos.dy.round().toDouble(),
    );
    return gridToScreen(snappedGridPos, config); // Return screen coordinates
  }

  /// Get the center position of a grid cell in screen coordinates
  Offset getGridCellCenter(int gridX, int gridY, GridConfiguration config) {
    return gridToScreen(Offset(gridX.toDouble() + 0.5, gridY.toDouble() + 0.5), config);
  }

  /// Check if a grid position is within grid bounds
  bool isInGridBounds(Offset gridPos, GridConfiguration config) {
    return gridPos.dx >= 0 &&
           gridPos.dy >= 0 &&
           gridPos.dx < config.cols &&
           gridPos.dy < config.rows;
  }

  /// Check if screen coordinates are within visible grid bounds
  bool isWithinGridBounds(Offset screenPosition, GridConfiguration config) {
    final gridPos = screenToGrid(screenPosition, config);
    return isInGridBounds(gridPos, config);
  }

  /// Get valid grid position from screen coordinates (returns null if out of bounds)
  Offset? getValidGridPosition(Offset screenPosition, GridConfiguration config) {
    final gridPos = screenToGrid(screenPosition, config);
    final snappedPos = Offset(
      gridPos.dx.floor().toDouble(),  // Use floor instead of round for boundary handling
      gridPos.dy.floor().toDouble(),
    );

    if (isInGridBounds(snappedPos, config)) {
      return snappedPos;
    }
    return null;
  }

  /// Calculate distance between two grid positions
  double gridDistance(Offset pos1, Offset pos2) {
    final dx = pos1.dx - pos2.dx;
    final dy = pos1.dy - pos2.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Find all valid grid positions in a screen area
  List<Offset> getGridPositionsInScreenRect(Rect screenRect, GridConfiguration config) {
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

  /// Calculate visible grid bounds based on screen size
  Rect calculateVisibleGridBounds(GridConfiguration config, Size screenSize) {
    final topLeft = screenToGrid(Offset.zero, config);
    final bottomRight = screenToGrid(Offset(screenSize.width, screenSize.height), config);

    return Rect.fromLTRB(
      topLeft.dx.floor().toDouble(),
      topLeft.dy.floor().toDouble(),
      bottomRight.dx.ceil().toDouble(),
      bottomRight.dy.ceil().toDouble(),
    );
  }

  /// Check if a grid position is visible on screen
  bool isGridPositionVisible(Offset gridPosition, GridConfiguration config, Size screenSize) {
    final visibleBounds = calculateVisibleGridBounds(config, screenSize);
    return visibleBounds.contains(gridPosition);
  }

  void clearCache() {
    _coordinateCache.clear();
    _validationCache.clear();
  }
}

/// Configuration for grid operations (consolidated from GridService)
class GridConfiguration {
  final int rows;
  final int cols;
  final double cellSize;
  final double scale;
  final Offset panOffset;

  const GridConfiguration({
    required this.rows,
    required this.cols,
    required this.cellSize,
    required this.scale,
    required this.panOffset,
  });

  /// Create configuration from canvas controller parameters
  factory GridConfiguration.fromCanvas({
    required int rows,
    required int cols,
    required double cellSize,
    required double scale,
    required Offset panOffset,
  }) {
    return GridConfiguration(
      rows: rows,
      cols: cols,
      cellSize: cellSize,
      scale: scale,
      panOffset: panOffset,
    );
  }

  /// Create a copy with modified values
  GridConfiguration copyWith({
    int? rows,
    int? cols,
    double? cellSize,
    double? scale,
    Offset? panOffset,
  }) {
    return GridConfiguration(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      cellSize: cellSize ?? this.cellSize,
      scale: scale ?? this.scale,
      panOffset: panOffset ?? this.panOffset,
    );
  }

  /// Check if grid coordinates are valid
  static bool isValidGridCoordinate(int x, int y, int gridWidth, int gridHeight) {
    return x >= 0 && x < gridWidth && y >= 0 && y < gridHeight;
  }
}