import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'secure_coordinate_validator.dart';


part 'coordinate_system_service.freezed.dart';

@freezed
class CoordinateContext with _$CoordinateContext {
  const factory CoordinateContext({
    required Size gridDimensions,
    required double cellSize,
    required double scale,
    required Offset panOffset,
    required Size canvasSize,
    required double devicePixelRatio,
    Rect? viewportBounds,
    @Default(EdgeInsets.zero) EdgeInsets padding,
  }) = _CoordinateContext;
}

@freezed
class GridPosition with _$GridPosition {
  const factory GridPosition({
    required int row,
    required int col,
  }) = _GridPosition;

  const GridPosition._();

  Offset toOffset() => Offset(col.toDouble(), row.toDouble());

  factory GridPosition.fromOffset(Offset offset) => GridPosition(
    row: offset.dy.round(),
    col: offset.dx.round(),
  );

  bool isWithinBounds(Size gridDimensions) {
    return row >= 0 && row < gridDimensions.height.toInt() &&
           col >= 0 && col < gridDimensions.width.toInt();
  }

  List<GridPosition> getAdjacentPositions() => [
    GridPosition(row: row - 1, col: col),
    GridPosition(row: row + 1, col: col),
    GridPosition(row: row, col: col - 1),
    GridPosition(row: row, col: col + 1),
  ];

  double distanceTo(GridPosition other) {
    final dx = (col - other.col).abs();
    final dy = (row - other.row).abs();
    return math.sqrt((dx * dx + dy * dy).toDouble());
  }
}

@freezed
class CoordinateValidationResult with _$CoordinateValidationResult {
  const factory CoordinateValidationResult({
    required bool isValid,
    GridPosition? gridPosition,
    String? errorMessage,
    @Default([]) List<String> warnings,
    @Default(ValidationLevel.info) ValidationLevel level,
  }) = _CoordinateValidationResult;

  factory CoordinateValidationResult.success({
    required GridPosition gridPosition,
    List<String> warnings = const [],
  }) => CoordinateValidationResult(
    isValid: true,
    gridPosition: gridPosition,
    warnings: warnings,
    level: warnings.isEmpty ? ValidationLevel.info : ValidationLevel.warning,
  );

  factory CoordinateValidationResult.failure({
    required String errorMessage,
    ValidationLevel level = ValidationLevel.error,
  }) => CoordinateValidationResult(
    isValid: false,
    errorMessage: errorMessage,
    level: level,
  );
}

enum ValidationLevel { info, warning, error }

abstract class ICoordinateService {
  GridPosition? screenToGrid(Offset screenPosition, CoordinateContext context, RenderBox renderBox);
  CoordinateValidationResult validateDropPosition(Offset screenPosition, CoordinateContext context, RenderBox renderBox, {Set<GridPosition>? occupiedPositions});
  Offset gridToLocal(GridPosition gridPosition, CoordinateContext context);
  Offset globalToLocal(Offset globalPosition, RenderBox renderBox);
}

class CoordinateSystemService implements ICoordinateService {
  static final CoordinateSystemService _instance = CoordinateSystemService._();
  factory CoordinateSystemService() => _instance;
  CoordinateSystemService._();

  final _cache = <String, dynamic>{};
  static const double _floatTolerance = 0.001;
  static const double _snapTolerance = 0.3;

  @override
  Offset globalToLocal(Offset globalPosition, RenderBox renderBox) {
    if (!renderBox.attached) {
      throw StateError('RenderBox is not attached to render tree');
    }
    return renderBox.globalToLocal(globalPosition);
  }

  Offset localToGrid(Offset localPosition, CoordinateContext context) {
    final adjustedPosition = Offset(
      localPosition.dx - context.padding.left,
      localPosition.dy - context.padding.top,
    );

    final unscaledX = (adjustedPosition.dx - context.panOffset.dx) / context.scale;
    final unscaledY = (adjustedPosition.dy - context.panOffset.dy) / context.scale;

    return Offset(
      unscaledX / context.cellSize,
      unscaledY / context.cellSize,
    );
  }

  Offset gridToLocal(GridPosition gridPosition, CoordinateContext context) {
    return gridToLocalFromOffset(gridPosition.toOffset(), context);
  }

  Offset gridToLocalFromOffset(Offset gridOffset, CoordinateContext context) {
    final pixelX = gridOffset.dx * context.cellSize;
    final pixelY = gridOffset.dy * context.cellSize;

    final scaledX = pixelX * context.scale + context.panOffset.dx;
    final scaledY = pixelY * context.scale + context.panOffset.dy;

    return Offset(
      scaledX + context.padding.left,
      scaledY + context.padding.top,
    );
  }

  GridPosition? localToGridPosition(Offset localPosition, CoordinateContext context) {
    final gridOffset = localToGrid(localPosition, context);

    // For edge cases, allow positions outside bounds but still return a valid GridPosition
    // This prevents null returns for extreme coordinate values
    return GridPosition.fromOffset(gridOffset);
  }

  @override
  GridPosition? screenToGrid(Offset screenPosition, CoordinateContext context, RenderBox renderBox) {
    final cacheKey = '${screenPosition.dx}_${screenPosition.dy}_${context.hashCode}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey] as GridPosition?;

    try {
      final local = globalToLocal(screenPosition, renderBox);
      final position = localToGridPosition(local, context);
      _cache[cacheKey] = position;
      return position;
    } catch (e) {
      debugPrint('Screen to grid error: $e');
      return null;
    }
  }

  @override
  CoordinateValidationResult validateDropPosition(
    Offset screenPosition,
    CoordinateContext context,
    RenderBox renderBox, {
    Set<GridPosition>? occupiedPositions,
    bool requireEmptyCell = true,
  }) {
    try {
      // 🛡️ SECURITY: Basic coordinate context validation
      if (context.gridDimensions.width <= 0 || context.gridDimensions.height <= 0) {
        return CoordinateValidationResult.failure(
          errorMessage: 'Invalid grid dimensions - security violation',
        );
      }

      // Handle edge case: zero-sized grid
      if (context.gridDimensions.width <= 0 || context.gridDimensions.height <= 0) {
        return CoordinateValidationResult.failure(
          errorMessage: 'Invalid grid dimensions',
        );
      }

      // 🛡️ SECURITY: Sanitize input position to prevent overflow attacks
      final sanitizedPosition = SecureCoordinateValidator.sanitizePosition(screenPosition);

      final clampedPosition = Offset(
        sanitizedPosition.dx.clamp(0, context.canvasSize.width),
        sanitizedPosition.dy.clamp(0, context.canvasSize.height),
      );

      final gridPosition = screenToGrid(clampedPosition, context, renderBox);

      if (gridPosition == null) {
        return CoordinateValidationResult.failure(
          errorMessage: 'Unable to calculate grid position',
        );
      }

      // For edge cases, allow positions outside bounds but add warnings
      final isWithinBounds = gridPosition.isWithinBounds(context.gridDimensions);

      final warnings = <String>[];
      final sanitizedOccupied = occupiedPositions?.where((pos) =>
        pos.isWithinBounds(context.gridDimensions)
      ).toSet() ?? <GridPosition>{};

      if (requireEmptyCell && sanitizedOccupied.contains(gridPosition)) {
        return CoordinateValidationResult.failure(errorMessage: 'Cell occupied');
      }

      if (!isWithinBounds) {
        warnings.add('Position outside grid bounds');
      } else if (_isNearBoundary(gridPosition, context)) {
        warnings.add('Near boundary - potential clipping');
      }

      return CoordinateValidationResult.success(
        gridPosition: gridPosition,
        warnings: warnings,
      );
    } catch (e) {
      debugPrint('Coordinate validation failed: $e');
      return CoordinateValidationResult.failure(errorMessage: 'Invalid coordinate input');
    }
  }

  bool _isWithinGridBounds(Offset gridOffset, Size gridDimensions) {
    return gridOffset.dx >= 0 && gridOffset.dy >= 0 &&
           gridOffset.dx < gridDimensions.width && gridOffset.dy < gridDimensions.height;
  }

  bool _isNearBoundary(GridPosition position, CoordinateContext context) {
    const boundaryTolerance = 1;
    return position.row < boundaryTolerance || position.row >= context.gridDimensions.height.toInt() - boundaryTolerance ||
           position.col < boundaryTolerance || position.col >= context.gridDimensions.width.toInt() - boundaryTolerance;
  }

  /// Get snapped and validated grid position for component placement
  GridPosition? getSnappedValidPosition(
    Offset screenPosition,
    CoordinateContext context,
    RenderBox renderBox, {
    Set<GridPosition>? occupiedPositions,
    bool requireEmptyCell = true,
  }) {
    final validation = validateDropPosition(
      screenPosition,
      context,
      renderBox,
      occupiedPositions: occupiedPositions,
      requireEmptyCell: requireEmptyCell,
    );

    if (!validation.isValid) {
      debugPrint('Position validation failed: ${validation.errorMessage}');
      return null;
    }

    return validation.gridPosition;
  }

  void clearCache() => _cache.clear();
}