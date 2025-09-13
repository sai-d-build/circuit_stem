import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// Unified bounds management system for SparkCircuit
enum BoundsStrategy {
  strict,      // Block all out-of-bounds placement
  warning,     // Allow but warn about out-of-bounds
  flexible     // Allow placement anywhere in visual grid
}

enum BoundsType {
  level,       // 6x8 level bounds
  visual,      // 20x20 visual bounds
  extended     // Custom extended bounds
}

enum BoundaryStyle {
  solid,       // Solid boundary line
  dashed,      // Dashed boundary line
  dotted,      // Dotted boundary line
  gradient,    // Gradient boundary effect
  animated     // Animated boundary effect
}

enum BoundaryBehavior {
  standard,    // Standard boundary behavior
  expanding,   // Boundary expands as level progresses
  contracting, // Boundary contracts as level progresses
  dynamic,     // Boundary changes based on game state
  tutorial     // Special tutorial boundary behavior
}

class BoundsConfiguration {
  final BoundsStrategy strategy;
  final BoundsType primaryBounds;
  final Size levelBounds;
  final Size visualBounds;
  final Size? extendedBounds;
  final bool showBoundaryWarnings;
  final bool showBoundaryIndicators;
  final Color boundaryColor;
  final double boundaryWidth;
  final bool enableCaching;
  final Duration cacheExpiration;

  // Enhanced boundary configuration
  final BoundaryStyle boundaryStyle;
  final BoundaryBehavior boundaryBehavior;
  final Map<String, dynamic>? levelSpecificSettings;

  const BoundsConfiguration({
    this.strategy = BoundsStrategy.warning,
    this.primaryBounds = BoundsType.level,
    this.levelBounds = const Size(20, 20),     // 20x20 level bounds
    this.visualBounds = const Size(50, 50),    // 50x50 visual bounds for full-screen
    this.extendedBounds,
    this.showBoundaryWarnings = true,
    this.showBoundaryIndicators = true,
    this.boundaryColor = Colors.blue,
    this.boundaryWidth = 3.0,
    this.enableCaching = true,
    this.cacheExpiration = const Duration(seconds: 30),
    this.boundaryStyle = BoundaryStyle.solid,
    this.boundaryBehavior = BoundaryBehavior.standard,
    this.levelSpecificSettings,
  });

  // Factory constructors for different level types
  factory BoundsConfiguration.tutorial() => const BoundsConfiguration(
    strategy: BoundsStrategy.strict,
    showBoundaryWarnings: true,
    showBoundaryIndicators: true,
    boundaryColor: Colors.red,
    boundaryStyle: BoundaryStyle.dashed,
    boundaryBehavior: BoundaryBehavior.tutorial,
    levelSpecificSettings: {
      'showHints': true,
      'highlightBoundaries': true,
      'tutorialMode': true,
    },
  );

  factory BoundsConfiguration.beginner() => const BoundsConfiguration(
    strategy: BoundsStrategy.warning,
    showBoundaryWarnings: true,
    showBoundaryIndicators: true,
    boundaryColor: Colors.orange,
    boundaryStyle: BoundaryStyle.solid,
    boundaryBehavior: BoundaryBehavior.expanding,
    levelSpecificSettings: {
      'showHints': false,
      'highlightBoundaries': true,
      'progressiveExpansion': false,
    },
  );

  factory BoundsConfiguration.intermediate() => const BoundsConfiguration(
    strategy: BoundsStrategy.warning,
    showBoundaryWarnings: true,
    showBoundaryIndicators: true,
    boundaryColor: Colors.blue,
    boundaryStyle: BoundaryStyle.solid,
    boundaryBehavior: BoundaryBehavior.expanding,
    levelSpecificSettings: {
      'showHints': false,
      'highlightBoundaries': false,
      'progressiveExpansion': true,
      'expansionRate': 0.1,
    },
  );

  factory BoundsConfiguration.advanced() => const BoundsConfiguration(
    strategy: BoundsStrategy.flexible,
    showBoundaryWarnings: false,
    showBoundaryIndicators: false,
    boundaryColor: Colors.green,
    boundaryStyle: BoundaryStyle.dotted,
    boundaryBehavior: BoundaryBehavior.dynamic,
    levelSpecificSettings: {
      'showHints': false,
      'highlightBoundaries': false,
      'dynamicBoundaries': true,
      'adaptiveSizing': true,
      'disableBoundsChecking': true, // Allow placement anywhere
      'allowFullScreen': true,
    },
  );

  factory BoundsConfiguration.expert() => const BoundsConfiguration(
    strategy: BoundsStrategy.flexible,
    showBoundaryWarnings: false,
    showBoundaryIndicators: false,
    boundaryColor: Colors.purple,
    boundaryStyle: BoundaryStyle.gradient,
    boundaryBehavior: BoundaryBehavior.contracting,
    levelSpecificSettings: {
      'showHints': false,
      'highlightBoundaries': false,
      'challengingMode': true,
      'timePressure': true,
    },
  );

  // Custom configuration from level data
  factory BoundsConfiguration.fromLevelData(Map<String, dynamic> levelData) {
    final grid = levelData['grid'] as Map<String, dynamic>? ?? {};
    final boundaries = grid['boundaries'] as Map<String, dynamic>? ?? {};

    // Extract boundary configuration from level data
    final playableArea = boundaries['playableArea'] as Map<String, dynamic>?;
    final visualArea = boundaries['visualArea'] as Map<String, dynamic>?;
    final style = boundaries['style'] as String?;
    final behavior = boundaries['behavior'] as String?;
    final difficulty = levelData['metadata']?['difficulty'] as String? ?? 'beginner';

    // Determine base configuration based on difficulty
    late BoundsConfiguration baseConfig;
    switch (difficulty.toLowerCase()) {
      case 'tutorial':
        baseConfig = BoundsConfiguration.tutorial();
        break;
      case 'beginner':
        baseConfig = BoundsConfiguration.beginner();
        break;
      case 'intermediate':
        baseConfig = BoundsConfiguration.intermediate();
        break;
      case 'advanced':
        baseConfig = BoundsConfiguration.advanced();
        break;
      case 'expert':
        baseConfig = BoundsConfiguration.expert();
        break;
      default:
        baseConfig = BoundsConfiguration.beginner();
    }

    // Override with level-specific settings
    return baseConfig.copyWith(
      levelBounds: playableArea != null
          ? Size(
              (playableArea['width'] as num?)?.toDouble() ?? baseConfig.levelBounds.width,
              (playableArea['height'] as num?)?.toDouble() ?? baseConfig.levelBounds.height,
            )
          : baseConfig.levelBounds,
      visualBounds: visualArea != null
          ? Size(
              (visualArea['width'] as num?)?.toDouble() ?? baseConfig.visualBounds.width,
              (visualArea['height'] as num?)?.toDouble() ?? baseConfig.visualBounds.height,
            )
          : baseConfig.visualBounds,
      boundaryStyle: _parseBoundaryStyle(style),
      boundaryBehavior: _parseBoundaryBehavior(behavior),
      levelSpecificSettings: {
        ...?baseConfig.levelSpecificSettings,
        ...?boundaries['settings'] as Map<String, dynamic>?,
      },
    );
  }

  static BoundaryStyle _parseBoundaryStyle(String? style) {
    switch (style?.toLowerCase()) {
      case 'solid':
        return BoundaryStyle.solid;
      case 'dashed':
        return BoundaryStyle.dashed;
      case 'dotted':
        return BoundaryStyle.dotted;
      case 'gradient':
        return BoundaryStyle.gradient;
      case 'animated':
        return BoundaryStyle.animated;
      default:
        return BoundaryStyle.solid;
    }
  }

  static BoundaryBehavior _parseBoundaryBehavior(String? behavior) {
    switch (behavior?.toLowerCase()) {
      case 'standard':
        return BoundaryBehavior.standard;
      case 'expanding':
        return BoundaryBehavior.expanding;
      case 'contracting':
        return BoundaryBehavior.contracting;
      case 'dynamic':
        return BoundaryBehavior.dynamic;
      case 'tutorial':
        return BoundaryBehavior.tutorial;
      default:
        return BoundaryBehavior.standard;
    }
  }

  BoundsConfiguration copyWith({
    BoundsStrategy? strategy,
    BoundsType? primaryBounds,
    Size? levelBounds,
    Size? visualBounds,
    Size? extendedBounds,
    bool? showBoundaryWarnings,
    bool? showBoundaryIndicators,
    Color? boundaryColor,
    double? boundaryWidth,
    bool? enableCaching,
    Duration? cacheExpiration,
    BoundaryStyle? boundaryStyle,
    BoundaryBehavior? boundaryBehavior,
    Map<String, dynamic>? levelSpecificSettings,
  }) {
    return BoundsConfiguration(
      strategy: strategy ?? this.strategy,
      primaryBounds: primaryBounds ?? this.primaryBounds,
      levelBounds: levelBounds ?? this.levelBounds,
      visualBounds: visualBounds ?? this.visualBounds,
      extendedBounds: extendedBounds ?? this.extendedBounds,
      showBoundaryWarnings: showBoundaryWarnings ?? this.showBoundaryWarnings,
      showBoundaryIndicators: showBoundaryIndicators ?? this.showBoundaryIndicators,
      boundaryColor: boundaryColor ?? this.boundaryColor,
      boundaryWidth: boundaryWidth ?? this.boundaryWidth,
      enableCaching: enableCaching ?? this.enableCaching,
      cacheExpiration: cacheExpiration ?? this.cacheExpiration,
      boundaryStyle: boundaryStyle ?? this.boundaryStyle,
      boundaryBehavior: boundaryBehavior ?? this.boundaryBehavior,
      levelSpecificSettings: levelSpecificSettings ?? this.levelSpecificSettings,
    );
  }
}

class BoundsValidationResult {
  final bool isValid;
  final bool isWithinLevelBounds;
  final bool isWithinVisualBounds;
  final bool isWithinExtendedBounds;
  final BoundsStrategy strategy;
  final String? warningMessage;
  final String? errorMessage;

  const BoundsValidationResult({
    required this.isValid,
    required this.isWithinLevelBounds,
    required this.isWithinVisualBounds,
    this.isWithinExtendedBounds = false,
    required this.strategy,
    this.warningMessage,
    this.errorMessage,
  });

  factory BoundsValidationResult.valid({
    required bool withinLevelBounds,
    required bool withinVisualBounds,
    required BoundsStrategy strategy,
    bool withinExtendedBounds = false,
  }) => BoundsValidationResult(
    isValid: true,
    isWithinLevelBounds: withinLevelBounds,
    isWithinVisualBounds: withinVisualBounds,
    isWithinExtendedBounds: withinExtendedBounds,
    strategy: strategy,
  );

  factory BoundsValidationResult.invalid({
    required bool withinLevelBounds,
    required bool withinVisualBounds,
    required BoundsStrategy strategy,
    bool withinExtendedBounds = false,
    String? warningMessage,
    String? errorMessage,
  }) => BoundsValidationResult(
    isValid: false,
    isWithinLevelBounds: withinLevelBounds,
    isWithinVisualBounds: withinVisualBounds,
    isWithinExtendedBounds: withinExtendedBounds,
    strategy: strategy,
    warningMessage: warningMessage,
    errorMessage: errorMessage,
  );
}

class BoundsCacheEntry {
  final BoundsValidationResult result;
  final DateTime timestamp;

  const BoundsCacheEntry(this.result, this.timestamp);

  bool isExpired(Duration expiration) =>
    DateTime.now().difference(timestamp) > expiration;
}

// Unified bounds manager with caching and configuration
class UnifiedBoundsManager {
  static final UnifiedBoundsManager _instance = UnifiedBoundsManager._internal();
  factory UnifiedBoundsManager() => _instance;

  UnifiedBoundsManager._internal();

  final Map<String, BoundsCacheEntry> _cache = {};
  BoundsConfiguration _configuration = const BoundsConfiguration();

  // Configuration management
  void updateConfiguration(BoundsConfiguration config) {
    _configuration = config;
    // Always clear cache when configuration changes to ensure consistency
    clearCache();
  }

  BoundsConfiguration getConfiguration() => _configuration;

  // Core bounds validation with caching
  BoundsValidationResult validatePosition(
    int row,
    int col, {
    Set<String>? occupiedPositions,
    bool checkOccupied = true,
  }) {
    final cacheKey = _generateCacheKey(row, col, occupiedPositions, checkOccupied);

    // Check cache first
    if (_configuration.enableCaching) {
      final cached = _cache[cacheKey];
      if (cached != null && !cached.isExpired(_configuration.cacheExpiration)) {
        return cached.result;
      }
    }

    // Perform validation
    final result = _performValidation(row, col, occupiedPositions, checkOccupied);

    // Cache result
    if (_configuration.enableCaching) {
      _cache[cacheKey] = BoundsCacheEntry(result, DateTime.now());
    }

    return result;
  }

  BoundsValidationResult _performValidation(
    int row,
    int col,
    Set<String>? occupiedPositions,
    bool checkOccupied,
  ) {
    // Check bounds for different types
    final withinLevelBounds = _isWithinBounds(row, col, _configuration.levelBounds);
    final withinVisualBounds = _isWithinBounds(row, col, _configuration.visualBounds);
    final withinExtendedBounds = _configuration.extendedBounds != null
        ? _isWithinBounds(row, col, _configuration.extendedBounds!)
        : false;

    // Check occupied positions
    final isOccupied = checkOccupied && occupiedPositions != null
        ? occupiedPositions.contains('$row,$col')
        : false;

    // Check if bounds checking is disabled (full screen mode)
    final disableBoundsChecking = _configuration.levelSpecificSettings?['disableBoundsChecking'] as bool? ?? false;
    final allowFullScreen = _configuration.levelSpecificSettings?['allowFullScreen'] as bool? ?? false;

    if (disableBoundsChecking || allowFullScreen) {
      // Allow placement anywhere, only check occupancy
      if (isOccupied) {
        return BoundsValidationResult.invalid(
          withinLevelBounds: withinLevelBounds,
          withinVisualBounds: withinVisualBounds,
          withinExtendedBounds: withinExtendedBounds,
          strategy: _configuration.strategy,
          errorMessage: 'Position ($row, $col) is already occupied',
        );
      }
      return BoundsValidationResult.valid(
        withinLevelBounds: withinLevelBounds,
        withinVisualBounds: withinVisualBounds,
        withinExtendedBounds: withinExtendedBounds,
        strategy: _configuration.strategy,
      );
    }

    // Apply strategy-based validation
    switch (_configuration.strategy) {
      case BoundsStrategy.strict:
        if (!withinLevelBounds || isOccupied) {
          return BoundsValidationResult.invalid(
            withinLevelBounds: withinLevelBounds,
            withinVisualBounds: withinVisualBounds,
            withinExtendedBounds: withinExtendedBounds,
            strategy: _configuration.strategy,
            errorMessage: isOccupied
                ? 'Position ($row, $col) is already occupied'
                : 'Position ($row, $col) is outside level bounds',
          );
        }
        return BoundsValidationResult.valid(
          withinLevelBounds: withinLevelBounds,
          withinVisualBounds: withinVisualBounds,
          withinExtendedBounds: withinExtendedBounds,
          strategy: _configuration.strategy,
        );

      case BoundsStrategy.warning:
        if (isOccupied) {
          return BoundsValidationResult.invalid(
            withinLevelBounds: withinLevelBounds,
            withinVisualBounds: withinVisualBounds,
            withinExtendedBounds: withinExtendedBounds,
            strategy: _configuration.strategy,
            errorMessage: 'Position ($row, $col) is already occupied',
          );
        }
        // Allow placement anywhere within visual bounds
        if (withinVisualBounds) {
          return BoundsValidationResult.valid(
            withinLevelBounds: withinLevelBounds,
            withinVisualBounds: withinVisualBounds,
            withinExtendedBounds: withinExtendedBounds,
            strategy: _configuration.strategy,
          );
        }
        // Reject if outside visual bounds
        return BoundsValidationResult.invalid(
          withinLevelBounds: withinLevelBounds,
          withinVisualBounds: withinVisualBounds,
          withinExtendedBounds: withinExtendedBounds,
          strategy: _configuration.strategy,
          errorMessage: 'Position ($row, $col) is outside visual bounds',
        );

      case BoundsStrategy.flexible:
        if (isOccupied) {
          return BoundsValidationResult.invalid(
            withinLevelBounds: withinLevelBounds,
            withinVisualBounds: withinVisualBounds,
            withinExtendedBounds: withinExtendedBounds,
            strategy: _configuration.strategy,
            errorMessage: 'Position ($row, $col) is already occupied',
          );
        }
        // Allow placement anywhere within visual bounds
        if (withinVisualBounds) {
          return BoundsValidationResult.valid(
            withinLevelBounds: withinLevelBounds,
            withinVisualBounds: withinVisualBounds,
            withinExtendedBounds: withinExtendedBounds,
            strategy: _configuration.strategy,
          );
        }
        // Reject if outside visual bounds
        return BoundsValidationResult.invalid(
          withinLevelBounds: withinLevelBounds,
          withinVisualBounds: withinVisualBounds,
          withinExtendedBounds: withinExtendedBounds,
          strategy: _configuration.strategy,
          errorMessage: 'Position ($row, $col) is outside visual bounds',
        );
    }
  }

  // Utility methods
  bool _isWithinBounds(int row, int col, Size bounds) {
    return row >= 0 && row < bounds.height.toInt() &&
           col >= 0 && col < bounds.width.toInt();
  }

  String _generateCacheKey(int row, int col, Set<String>? occupiedPositions, bool checkOccupied) {
    final occupiedHash = occupiedPositions?.join(',') ?? '';
    return '$row,$col,$occupiedHash,$checkOccupied,${_configuration.strategy}';
  }

  // Cache management
  void clearCache() {
    _cache.clear();
  }

  int getCacheSize() => _cache.length;

  // Dynamic boundary behavior methods
  Size getEffectiveLevelBounds({
    double progress = 0.0,
    int timeElapsed = 0,
    int componentsPlaced = 0,
  }) {
    switch (_configuration.boundaryBehavior) {
      case BoundaryBehavior.expanding:
        return _calculateExpandingBounds(progress, timeElapsed);
      case BoundaryBehavior.contracting:
        return _calculateContractingBounds(progress, timeElapsed);
      case BoundaryBehavior.dynamic:
        return _calculateDynamicBounds(componentsPlaced, timeElapsed);
      case BoundaryBehavior.tutorial:
        return _calculateTutorialBounds(progress);
      case BoundaryBehavior.standard:
      default:
        return _configuration.levelBounds;
    }
  }

  Size _calculateExpandingBounds(double progress, int timeElapsed) {
    final settings = _configuration.levelSpecificSettings ?? {};
    final expansionRate = settings['expansionRate'] as double? ?? 0.5; // Increased default
    final initialDelay = settings['initialExpansionDelay'] as int? ?? 30;

    if (timeElapsed < initialDelay) {
      return _configuration.levelBounds;
    }

    final expansionFactor = 1.0 + (progress * expansionRate);
    return Size(
      _configuration.levelBounds.width * expansionFactor,
      _configuration.levelBounds.height * expansionFactor,
    );
  }

  Size _calculateContractingBounds(double progress, int timeElapsed) {
    final settings = _configuration.levelSpecificSettings ?? {};
    final contractionRate = settings['contractionRate'] as double? ?? 0.1;

    final contractionFactor = 1.0 - (progress * contractionRate);
    return Size(
      math.max(8.0, _configuration.levelBounds.width * contractionFactor),
      math.max(6.0, _configuration.levelBounds.height * contractionFactor),
    );
  }

  Size _calculateDynamicBounds(int componentsPlaced, int timeElapsed) {
    final settings = _configuration.levelSpecificSettings ?? {};
    final adaptiveSizing = settings['adaptiveSizing'] as bool? ?? true;

    if (!adaptiveSizing) {
      return _configuration.levelBounds;
    }

    // Adaptive sizing based on component count
    final baseSize = _configuration.levelBounds;
    final componentFactor = math.min(1.5, 1.0 + (componentsPlaced * 0.1));

    return Size(
      baseSize.width * componentFactor,
      baseSize.height * componentFactor,
    );
  }

  Size _calculateTutorialBounds(double progress) {
    // Tutorial mode: start small, expand gradually
    final baseSize = _configuration.levelBounds;
    final tutorialFactor = 0.7 + (progress * 0.3); // Start at 70%, expand to 100%

    return Size(
      baseSize.width * tutorialFactor,
      baseSize.height * tutorialFactor,
    );
  }

  // Boundary style rendering methods
  Paint getBoundaryPaint() {
    final paint = Paint()
      ..color = _configuration.boundaryColor
      ..strokeWidth = _configuration.boundaryWidth
      ..style = PaintingStyle.stroke;

    switch (_configuration.boundaryStyle) {
      case BoundaryStyle.solid:
        // Default solid paint
        break;
      case BoundaryStyle.dashed:
        paint.strokeCap = StrokeCap.round;
        // Note: Dashed effect would be handled in the painter
        break;
      case BoundaryStyle.dotted:
        paint.strokeCap = StrokeCap.round;
        // Note: Dotted effect would be handled in the painter
        break;
      case BoundaryStyle.gradient:
        // Gradient effect would be handled in the painter
        break;
      case BoundaryStyle.animated:
        // Animation would be handled in the painter
        break;
    }

    return paint;
  }

  // Bounds calculation utilities
  Rect getLevelBoundsRect(double cellSize, Offset panOffset) {
    return Rect.fromLTWH(
      panOffset.dx,
      panOffset.dy,
      _configuration.levelBounds.width * cellSize,
      _configuration.levelBounds.height * cellSize,
    );
  }

  Rect getVisualBoundsRect(double cellSize, Offset panOffset) {
    return Rect.fromLTWH(
      panOffset.dx,
      panOffset.dy,
      _configuration.visualBounds.width * cellSize,
      _configuration.visualBounds.height * cellSize,
    );
  }

  // Position conversion utilities
  Offset gridToScreen(int row, int col, double cellSize, Offset panOffset) {
    return Offset(
      col * cellSize + panOffset.dx,
      row * cellSize + panOffset.dy,
    );
  }

  GridPosition? screenToGrid(Offset screenPos, double cellSize, Offset panOffset) {
    final adjustedX = screenPos.dx - panOffset.dx;
    final adjustedY = screenPos.dy - panOffset.dy;

    final col = (adjustedX / cellSize).round();
    final row = (adjustedY / cellSize).round();

    // Validate against visual bounds for coordinate conversion
    if (_isWithinBounds(row, col, _configuration.visualBounds)) {
      return GridPosition(row: row, col: col);
    }

    return null;
  }
}

// Freezed-compatible GridPosition class
class GridPosition {
  final int row;
  final int col;

  const GridPosition({
    required this.row,
    required this.col,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'GridPosition(row: $row, col: $col)';
}