import 'package:flutter/material.dart';

// ================================
// 🔧 GRID DIMENSIONS CLASS (FIRST)
@immutable
class GridDimensions {
  final int width;
  final int height;

  const GridDimensions(this.width, this.height);

  // Computed properties
  int get cellCount => width * height;
  int get maxValidIndex => cellCount - 1;

  // Bounds checking
  bool contains(int row, int col) =>
    row >= 0 && row < height && col >= 0 && col < width;

  bool containsPoint(int row, int col) =>
    row >= 0 && row < height && col >= 0 && col < width;

  // Factory constructors
  static const GridDimensions visual = GridDimensions(20, 20);         // 20×20 visual grid
  static const GridDimensions gameplay = GridDimensions(6, 8);         // 6×8 gameplay area

  // Level-specific dimension creation
  factory GridDimensions.fromLevel(Map<String, dynamic>? levelGrid) {
    if (levelGrid != null &&
        levelGrid.containsKey('width') &&
        levelGrid.containsKey('height')) {
      final levelWidth = levelGrid['width'] as int?;
      final levelHeight = levelGrid['height'] as int?;

      if (levelWidth != null && levelHeight != null &&
          levelWidth >= 6 && levelWidth <= 50 &&
          levelHeight >= 6 && levelHeight <= 50 &&
          levelWidth <= 20 && levelHeight <= 20) { // Must fit within visual grid

        return GridDimensions(levelWidth, levelHeight);
      }
    }

    return GridConfigConstants.defaultGameplayBounds;
  }

  // Equality and hashing
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is GridDimensions && other.width == width && other.height == height;

  @override
  int get hashCode => width.hashCode ^ height.hashCode;

  @override
  String toString() => '${width}×${height}';

  // Conversion methods
  Size toSize() => Size(width.toDouble(), height.toDouble());
  Offset toOffset() => Offset(width.toDouble(), height.toDouble());
}

// ================================
// 🔧 VALIDATION UTILITIES
class GridValidationUtils {
  /// Check if position is within visual bounds
  static bool isWithinVisualBounds(int row, int col) {
    return row >= 0 && row < GridConfigConstants.visualGridHeight &&
           col >= 0 && col < GridConfigConstants.visualGridWidth;
  }

  /// Check if position is within gameplay bounds
  static bool isWithinGameplayBounds(int row, int col) {
    return row >= 0 && row < GridConfigConstants.defaultGameplayHeight &&
           col >= 0 && col < GridConfigConstants.defaultGameplayWidth;
  }

  /// Validate multiple positions using int instead of GridPosition
  static ValidationResult validateMultiplePositionsUsingInts(
    List<({int row, int col})> positions,
    GridDimensions bounds
  ) {
    final validPositions = positions.where((pos) => bounds.contains(pos.row, pos.col)).toList();
    final invalidPositions = positions.where((pos) => !bounds.contains(pos.row, pos.col)).toList();

    if (invalidPositions.isEmpty) {
      return ValidationResult.valid(
        context: {'validCount': validPositions.length}
      );
    }

    return ValidationResult.invalid(
      'Multiple positions out of bounds: ${invalidPositions.length} invalid, ${validPositions.length} valid',
      context: {
        'validCount': validPositions.length,
        'invalidCount': invalidPositions.length,
        'invalidPositions': invalidPositions.take(5).toList(),
        'bounds': bounds.toString(),
      }
    );
  }
}

// ================================
// 🔧 VALIDATION RESULT CLASS
enum ValidationLevel { info, warning, error }

class ValidationResult {
  final bool isValid;
  final String? error;
  final Map<String, dynamic>? context;
  final ValidationLevel level;

  const ValidationResult(
    this.isValid, {
    this.error,
    this.context,
    this.level = ValidationLevel.info,
  });

  factory ValidationResult.valid({
    String? message,
    Map<String, dynamic>? context,
  }) => ValidationResult(
    true,
    context: context,
    level: ValidationLevel.info,
  );

  factory ValidationResult.invalid(
    String errorMessage, {
    Map<String, dynamic>? context,
  }) => ValidationResult(
    false,
    error: errorMessage,
    context: context,
    level: ValidationLevel.error,
  );

  bool get hasError => !isValid && error != null;
  bool get hasWarnings => level == ValidationLevel.warning;
  bool get isInfo => level == ValidationLevel.info;

  @override
  String toString() {
    if (isValid) return 'VALID${context != null ? ': $context' : ''}';
    return 'INVALID[${error}]${context != null ? ': $context' : ''}';
  }
}

// ================================
// 🔧 GRID CONFIGURATION CONSTANTS CLASS
/// Core grid configuration constants that control the entire grid system
class GridConfigConstants {
  // ================================
  // 🔧 PRIMARY CONFIGURATION VALUES (FIXED FOR 20×20 + 6×8 GAMEPLAY)
  // ================================

  // Visual Canvas Grid Dimensions (20×20)
  static const int visualGridWidth = 20;           // Canvas width in cells
  static const int visualGridHeight = 20;          // Canvas height in cells

  // Gameplay Boundary Within Visual Grid (6×8 - MATCHING EXISTING GAME LOGIC)
  static const int defaultGameplayWidth = 6;       // Playable width (corrected from 20)
  static const int defaultGameplayHeight = 8;      // Playable height (corrected from 20)

  // Cell Rendering
  static const double gridCellSize = 60.0;     // Pixel size of each grid cell

  // Boundary Detection
  static const int boundaryWarningDistance = 1;    // Cells away from boundary before warning

  // Feature Flags
  static const bool levelCanOverrideBounds = true; // Allow level files to specify custom boundaries
  static const bool enableGridSnap = true;          // Enable snapping to grid points
  static const bool enableBoundaryWarnings = true;  // Show warnings near boundaries

  // ================================
  // 🔧 COMPUTED VALUES (derived from above)
  // ================================

  // Visual grid properties
  static int get visualCellCount => visualGridWidth * visualGridHeight;
  static int get visualMaxValidIndex => visualCellCount - 1;

  // Default gameplay properties
  static int get gameplayCellCount => defaultGameplayWidth * defaultGameplayHeight;
  static int get gameplayMaxValidIndex => gameplayCellCount - 1;

  // ================================
  // 🔧 BOUNDARY VALIDATION HELPERS (ADDED)
  // ================================

  /// Check if position is within visual bounds (0-19, 0-19)
  static bool isWithinVisualBounds(int row, int col) {
    return row >= 0 && row < visualGridHeight &&
           col >= 0 && col < visualGridWidth;
  }

  /// Check if position is within gameplay bounds (0-5 row, 0-7 col)
  static bool isWithinGameplayBounds(int row, int col) {
    return row >= 0 && row < defaultGameplayHeight &&
           col >= 0 && col < defaultGameplayWidth;
  }

  /// Get boundary warning threshold
  static bool isNearBoundary(int row, int col) {
    return row <= boundaryWarningDistance ||
           row >= defaultGameplayHeight - boundaryWarningDistance - 1 ||
           col <= boundaryWarningDistance ||
           col >= defaultGameplayWidth - boundaryWarningDistance - 1;
  }

  // ================================
  // 🔧 CACHE KEY GENERATORS
  // ================================

  /// Generate cache keys for coordinate transformations
  static String coordinateCacheKey(Offset pos, int? levelHash) {
    return 'coord_${pos.dx.round()}_${pos.dy.round()}_${levelHash ?? 0}';
  }

  // ================================
  // 🔧 DEBUGGING HELPERS
  // ================================

  static Map<String, dynamic> getDebugInfo() {
    return {
      'visualDimensions': '$visualGridWidth×$visualGridHeight',
      'gameplayDimensions': '$defaultGameplayWidth×$defaultGameplayHeight',
      'cellSizePx': gridCellSize,
      'visualCellCount': visualCellCount,
      'gameplayCellCount': gameplayCellCount,
      'boundaryWarningDistance': boundaryWarningDistance,
      'maxValidIndex': {
        'visual': visualMaxValidIndex,
        'gameplay': gameplayMaxValidIndex,
      },
    };
  }

  // ================================
  // 🔧 CONVENIENCE GETTERS FOR MIGRATION
  // ================================

  static Size get visualSize => Size(visualGridWidth.toDouble(), visualGridHeight.toDouble());
  static Size get gameplaySize => Size(defaultGameplayWidth.toDouble(), defaultGameplayHeight.toDouble());
  static int get visualWidth => visualGridWidth;
  static int get visualHeight => visualGridHeight;
  static int get gameplayWidth => defaultGameplayWidth;
  static int get gameplayHeight => defaultGameplayHeight;
  static double get cellSize => gridCellSize;

  // Dimensions objects - computed from static values
  static GridDimensions get visualDimensions => const GridDimensions(visualGridWidth, visualGridHeight);
  static GridDimensions get defaultGameplayBounds => const GridDimensions(defaultGameplayWidth, defaultGameplayHeight);
}

// Create a singleton instance for easy access
final gridConfigConstants = GridConfigConstants();