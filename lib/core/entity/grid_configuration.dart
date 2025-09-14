import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎯 CANONICAL GridConfiguration - Consolidated Implementation
///
/// This is the single source of truth for GridConfiguration across the entire application.
/// Consolidates features from three sources:
/// 1. State management (JSON serialization) → Simple constructors with defaults
/// 2. Coordinate services (complex operations) → Transformation methods
/// 3. Provider definitions (DI integration) → Provider consortium
class GridConfiguration {
  final int rows;
  final int cols;
  final double cellSize;
  final double scale;
  final Offset panOffset;

  /// Standard 20×20 visual grid configuration
  const GridConfiguration({
    this.rows = 20,
    this.cols = 20,
    this.cellSize = 60.0,
    this.scale = 1.0,
    this.panOffset = Offset.zero,
  });

  /// Gameplay configuration (6×8 grid for gameplay bounds)
  factory GridConfiguration.gameplayBounds() => const GridConfiguration(
        rows: 6,
        cols: 8,
        cellSize: 60.0,
        scale: 1.0,
        panOffset: Offset.zero,
      );

  /// Standard 20×20 configuration (backward compatibility)
  factory GridConfiguration.standard() => const GridConfiguration();

  /// Factory constructor from controller parameters
  factory GridConfiguration.fromController({
    required int rows,
    required int cols,
    required double cellSize,
    required double scale,
    required Offset panOffset,
  }) => GridConfiguration(
        rows: rows,
        cols: cols,
        cellSize: cellSize,
        scale: scale,
        panOffset: panOffset,
      );

  /// Create from JSON (for backward compatibility)
  factory GridConfiguration.fromJson(Map<String, dynamic> json) => GridConfiguration(
        rows: json['rows'] as int? ?? 20,
        cols: json['cols'] as int? ?? 20,
        cellSize: (json['cellSize'] as num?)?.toDouble() ?? 60.0,
        scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
        panOffset: Offset(
          (json['panOffsetDx'] as num?)?.toDouble() ?? 0.0,
          (json['panOffsetDy'] as num?)?.toDouble() ?? 0.0,
        ),
      );

  /// Convert to JSON (for serialization)
  Map<String, dynamic> toJson() => {
        'rows': rows,
        'cols': cols,
        'cellSize': cellSize,
        'scale': scale,
        'panOffsetDx': panOffset.dx,
        'panOffsetDy': panOffset.dy,
      };

  /// Create a copy with modified values
  GridConfiguration copyWith({
    int? rows,
    int? cols,
    double? cellSize,
    double? scale,
    Offset? panOffset,
  }) => GridConfiguration(
        rows: rows ?? this.rows,
        cols: cols ?? this.cols,
        cellSize: cellSize ?? this.cellSize,
        scale: scale ?? this.scale,
        panOffset: panOffset ?? this.panOffset,
      );

  /// Calculate total grid cells
  int get totalCells => rows * cols;

  /// Check if grid coordinates are within bounds
  bool contains(int row, int col) =>
      row >= 0 && row < rows && col >= 0 && col < cols;

  /// Check if screen coordinates are within grid bounds
  bool containsScreenPosition(Offset screenPos) {
    final gridPos = screenToGrid(screenPos);
    return contains(gridPos.dx.toInt(), gridPos.dy.toInt());
  }

  /// Coordinate transformation: screen to grid coordinates
  Offset screenToGrid(Offset screenPos) {
    final adjustedX = (screenPos.dx - panOffset.dx) / (cellSize * scale);
    final adjustedY = (screenPos.dy - panOffset.dy) / (cellSize * scale);
    final gridX = adjustedX.clamp(0.0, cols - 1.0);
    final gridY = adjustedY.clamp(0.0, rows - 1.0);
    return Offset(gridX, gridY);
  }

  /// Coordinate transformation: grid to screen coordinates
  Offset gridToScreen(Offset gridPos) {
    final screenX = (gridPos.dx * cellSize * scale) + panOffset.dx;
    final screenY = (gridPos.dy * cellSize * scale) + panOffset.dy;
    return Offset(screenX, screenY);
  }

  /// Get center position of a grid cell in screen coordinates
  Offset getCellCenter(int gridX, int gridY) {
    return gridToScreen(Offset(gridX + 0.5, gridY + 0.5));
  }

  /// Check if grid coordinates are within 20×20 visual grid bounds
  static bool isInVisualBounds(int x, int y) => x >= 0 && x < 20 && y >= 0 && y < 20;

  /// Convert to visual grid offset (clamped to 20×20)
  Offset toVisualGridOffset(int x, int y) {
    final clampedX = x.clamp(0, 19);
    final clampedY = y.clamp(0, 19);
    return Offset(clampedX.toDouble(), clampedY.toDouble());
  }

  /// Get visual grid bounds as Rect
  Rect getVisualGridBounds() {
    return Rect.fromLTWH(0, 0, cols.toDouble(), rows.toDouble());
  }

  /// Check if configuration is valid
  bool get isValid =>
      rows > 0 && cols > 0 && cellSize > 0 && scale > 0 && scale <= 3.0;

  /// String representation
  @override
  String toString() {
    return 'GridConfiguration(rows: $rows, cols: $cols, cellSize: $cellSize, scale: $scale)';
  }

  /// Equality comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridConfiguration &&
          rows == other.rows &&
          cols == other.cols &&
          cellSize == other.cellSize &&
          scale == other.scale &&
          panOffset == other.panOffset;

  /// Hash code for collections
  @override
  int get hashCode =>
      Object.hash(rows, cols, cellSize, scale, panOffset);
}

// 🎯 CANONICAL PROVIDER DEFINITIONS - Single Source of Truth

/// Provider for default grid configuration
/// This is the primary configuration provider used throughout the application
final gridConfigurationProvider = Provider<GridConfiguration>((ref) {
  return const GridConfiguration(); // 20×20 default
});

/// Provider for gameplay-specific grid configuration
/// Use this for restricting component placement to gameplay bounds (6×8)
final gameplayGridConfigurationProvider = Provider<GridConfiguration>((ref) {
  return GridConfiguration.gameplayBounds(); // 6×8 gameplay bounds
});

/// Provider for visual grid configuration (always 20×20)
/// This ensures consistent visual grid coverage regardless of gameplay bounds
final visualGridConfigurationProvider = Provider<GridConfiguration>((ref) {
  return const GridConfiguration(
    rows: 20,
    cols: 20,
    cellSize: 60.0,
    scale: 1.0,
    panOffset: Offset.zero,
  );
});

// 🎯 FACTORY METHODS FOR INTEGRATION
abstract class GridConfigurationFactory {
  /// Create configuration for specific level
  static GridConfiguration forLevel(String levelId) {
    switch (levelId) {
      case 'tutorial':
        return GridConfiguration.gameplayBounds(); // 6×8 for simple levels
      case 'beginner':
        return GridConfiguration.gameplayBounds();
      default:
        return const GridConfiguration(); // 20×20 for complex levels
    }
  }
}

// 🎯 LEVEL-ID SPECIFIC PROVIDERS
/// Provider for level-specific grid configuration
final levelGridConfigurationProvider = Provider.family<GridConfiguration, String>((ref, levelId) {
  return GridConfigurationFactory.forLevel(levelId);
});

// 🎯 BACKWARD COMPATIBILITY ALIASES
/// @deprecated Use gridConfigurationProvider instead
@deprecated
final GridConfigurationProvider = gridConfigurationProvider;

/// @deprecated Use visualGridConfigurationProvider instead
@deprecated
final visualGridConfigProvider = visualGridConfigurationProvider;