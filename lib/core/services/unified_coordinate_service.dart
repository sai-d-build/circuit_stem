import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'secure_coordinate_validator.dart';
import '../../domain/entities/core/component.dart';
import '../../../presentation/features/game/controllers/game_canvas_controller.dart';

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

/// Grid footprint definition for component boundary calculation (PHASE 2 FEATURE)
class GridFootprint {
  final int width;
  final int height;

  const GridFootprint({
    required this.width,
    required this.height,
  });

  Size toSize() => Size(width.toDouble(), height.toDouble());
}

/// Phase 2: User configuration for grid density (ADVANCED BOUNDARY FEATURES)
class GridDensityConfig {
  final double cellSpacing; // In pixels
  final bool showMinorGrid; // Minor vs major grid lines
  final double boundaryTolerance; // Edge detection sensitivity (0.0-1.0)
  final bool showComponentFootprints; // Show grid occupation overlays
  final Color boundaryHighlightColor;

  const GridDensityConfig({
    this.cellSpacing = 60.0,
    this.showMinorGrid = true,
    this.boundaryTolerance = 0.1, // 10% tolerance
    this.showComponentFootprints = true,
    this.boundaryHighlightColor = const Color(0xFFFF5252), // Red highlight
  });

  /// Get effective boundary tolerance in pixels
  double effectiveTolerance(GridConfiguration config) {
    return boundaryTolerance * config.cellSize;
  }

  /// Calculate component spacing based on density preferences
  double componentSpacing(double baseSize) {
    return cellSpacing > 0 ? cellSpacing : baseSize;
  }

  /// Validate density configuration against grid constraints
  bool isConfigurationValid(GridConfiguration config) {
    final effectiveCellSize = componentSpacing(config.cellSize);
    return effectiveCellSize > 0 &&
           effectiveCellSize <= (config.cellSize * 2) && // Prevent excessive scaling
           boundaryTolerance >= 0.0 &&
           boundaryTolerance <= 1.0;
  }
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
  /// Supports optional RenderBox for globalToLocal conversion (consolidated from coordinate_system_service)
  Offset screenToGrid(Offset screenPos, GridConfiguration config, {RenderBox? renderBox}) {
    // Check cache first for performance
    final cacheKey = 'screenToGrid_${screenPos.dx}_${screenPos.dy}_${config.hashCode}';
    final cached = _coordinateCache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheExpiration) {
      return cached.value as Offset;
    }

    // 🛡️ SECURITY: Sanitize input position
    Offset localPos = screenPos;
    if (renderBox != null) {
      localPos = renderBox.globalToLocal(screenPos);
    }
    final sanitizedPos = SecureCoordinateValidator.sanitizePosition(localPos);

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
  Offset snapToGrid(Offset screenPos, GridConfiguration config, {RenderBox? renderBox}) {
    final gridPos = screenToGrid(screenPos, config, renderBox: renderBox);
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

  /// Enhanced component-sized boundary checks (PHASE 2 FEATURE)
  bool canComponentFitAt(int row, int col, ComponentType type, GridConfiguration config) {
    final componentSize = _getComponentGridFootprint(type);
    return (col + componentSize.width) <= config.cols &&
           (row + componentSize.height) <= config.rows &&
           col >= 0 && row >= 0;
  }

  /// Get component's grid footprint for boundary calculation
  GridFootprint _getComponentGridFootprint(ComponentType type) {
    switch (type) {
      case ComponentType.wire:
        return GridFootprint(width: 1, height: 1); // Wires can span segments
      case ComponentType.resistor:
      case ComponentType.bulb:
      case ComponentType.capacitor:
      case ComponentType.inductor:
        return GridFootprint(width: 1, height: 1); // Standard components
      case ComponentType.battery:
        return GridFootprint(width: 1, height: 1); // Battery terminal footprint
      default:
        return GridFootprint(width: 1, height: 1); // Default to 1x1
    }
  }

  /// Check if a grid position is within grid bounds
  bool isInGridBounds(Offset gridPos, GridConfiguration config) {
    return gridPos.dx >= 0 &&
           gridPos.dy >= 0 &&
           gridPos.dx < config.cols &&
           gridPos.dy < config.rows;
  }

  /// Check if screen coordinates are within visible grid bounds
  bool isWithinGridBounds(Offset screenPosition, GridConfiguration config, {RenderBox? renderBox}) {
    final gridPos = screenToGrid(screenPosition, config, renderBox: renderBox);
    return isInGridBounds(gridPos, config);
  }

  /// Get valid grid position from screen coordinates (returns null if out of bounds)
  /// Consolidated to use round() for consistency across implementations
  Offset? getValidGridPosition(Offset screenPosition, GridConfiguration config, {RenderBox? renderBox}) {
    final gridPos = screenToGrid(screenPosition, config, renderBox: renderBox);
    final snappedPos = Offset(
      gridPos.dx.round().toDouble(),  // Unified to round for nearest cell
      gridPos.dy.round().toDouble(),
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
  List<Offset> getGridPositionsInScreenRect(Rect screenRect, GridConfiguration config, {RenderBox? renderBox}) {
    final topLeft = screenToGrid(screenRect.topLeft, config, renderBox: renderBox);
    final bottomRight = screenToGrid(screenRect.bottomRight, config, renderBox: renderBox);

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

  /// Phase 3: Viewport-culling boundary validation (PERFORMANCE OPTIMIZATION)
  bool isComponentWithinViewportBoundaries(
    Offset componentPos,
    GridConfiguration config,
    Size screenSize, {
    double viewportThreshold = 0.1, // 10% buffer
  }) {
    // Calculate visible grid bounds with buffer
    final visibleBounds = calculateVisibleGridBounds(config, screenSize);

    // Expand bounds by viewport threshold for smooth scrolling
    final bufferedBounds = Rect.fromLTRB(
      visibleBounds.left - (visibleBounds.width * viewportThreshold),
      visibleBounds.top - (visibleBounds.height * viewportThreshold),
      visibleBounds.right + (visibleBounds.width * viewportThreshold),
      visibleBounds.bottom + (visibleBounds.height * viewportThreshold),
    );

    // Check if component position is within viewport + buffer
    return bufferedBounds.contains(componentPos);
  }

  /// Check if a grid position is visible on screen
  bool isGridPositionVisible(Offset gridPosition, GridConfiguration config, Size screenSize) {
    final visibleBounds = calculateVisibleGridBounds(config, screenSize);
    return visibleBounds.contains(gridPosition);
  }

  /// Factory to create config from GameCanvasController for easy integration
  static GridConfiguration createConfigFromController(GameCanvasController controller) {
    return GridConfiguration(
      rows: controller.gridHeight,
      cols: controller.gridWidth,
      cellSize: controller.gridCellSize,
      scale: controller.scale,
      panOffset: controller.panOffset,
    );
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

// Phase 2: Extension methods for GridDensityConfig integration
extension GridDensityConfigExtensions on GridDensityConfig {

  /// Apply density configuration to a grid position
  Offset applyDensityToPosition(Offset position) {
    return Offset(
      position.dx * (cellSpacing / 60.0), // Scale relative to default 60px
      position.dy * (cellSpacing / 60.0),
    );
  }

  /// Check if position is within density-configured tolerances
  bool isPositionWithinBoundaryTolerance(Offset position, Offset boundary) {
    final distance = (position - boundary).distance;
    return distance <= effectiveTolerance(GridConfiguration(
      rows: 8, // Default values for tolerance calculation
      cols: 6,
      cellSize: 60.0,
      scale: 1.0,
      panOffset: Offset.zero,
    ));
  }
}