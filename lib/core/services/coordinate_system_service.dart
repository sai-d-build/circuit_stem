import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'secure_coordinate_validator.dart';
import 'unified_coordinate_service.dart';

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
    return row >= 0 &&
        row < gridDimensions.height.toInt() &&
        col >= 0 &&
        col < gridDimensions.width.toInt();
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
  }) =>
      CoordinateValidationResult(
        isValid: true,
        gridPosition: gridPosition,
        warnings: warnings,
        level:
            warnings.isEmpty ? ValidationLevel.info : ValidationLevel.warning,
      );

  factory CoordinateValidationResult.failure({
    required String errorMessage,
    ValidationLevel level = ValidationLevel.error,
  }) =>
      CoordinateValidationResult(
        isValid: false,
        errorMessage: errorMessage,
        level: level,
      );
}

enum ValidationLevel { info, warning, error }

abstract class ICoordinateService {
  GridPosition? screenToGrid(Offset screenPosition, CoordinateContext context,
      {RenderBox? renderBox});
  CoordinateValidationResult validateDropPosition(
      Offset screenPosition, CoordinateContext context,
      {RenderBox? renderBox, Set<GridPosition>? occupiedPositions});
  Offset gridToLocal(GridPosition gridPosition, CoordinateContext context);
  Offset globalToLocal(Offset globalPosition, {RenderBox? renderBox});
}

class CoordinateSystemService implements ICoordinateService {
  static final CoordinateSystemService _instance = CoordinateSystemService._(); // ignore: cascade_invocations
  factory CoordinateSystemService() => _instance;
  CoordinateSystemService._(); // ignore: cascade_invocations

  final _cache = <String, dynamic>{};

  @override
  Offset globalToLocal(Offset globalPosition, {RenderBox? renderBox}) {
    if (renderBox == null || !renderBox.attached) {
      // Return position unchanged if no RenderBox provided or not attached
      return globalPosition;
    }
    return renderBox.globalToLocal(globalPosition);
  }

  Offset localToGrid(Offset localPosition, CoordinateContext context) {
    // 🎯 PHASE 1: Remove legacy inline math, delegate to UnifiedCoordinateService
    final unifiedService = UnifiedCoordinateService();
    final config = GridConfiguration.fromCanvas(
      rows: context.gridDimensions.height.toInt(),
      cols: context.gridDimensions.width.toInt(),
      cellSize: context.cellSize,
      scale: context.scale,
      panOffset: context.panOffset,
    );

    // Adjust for padding before conversion
    final adjustedPosition = Offset(
      localPosition.dx - context.padding.left,
      localPosition.dy - context.padding.top,
    );

    return unifiedService.screenToGrid(adjustedPosition, config);
  }

  @override
  Offset gridToLocal(GridPosition gridPosition, CoordinateContext context) {
    return gridToLocalFromOffset(gridPosition.toOffset(), context);
  }

  Offset gridToLocalFromOffset(Offset gridOffset, CoordinateContext context) {
    // 🎯 PHASE 1: Remove legacy inline math, delegate to UnifiedCoordinateService
    final unifiedService = UnifiedCoordinateService();
    final config = GridConfiguration.fromCanvas(
      rows: context.gridDimensions.height.toInt(),
      cols: context.gridDimensions.width.toInt(),
      cellSize: context.cellSize,
      scale: context.scale,
      panOffset: context.panOffset,
    );

    final screenPos = unifiedService.gridToScreen(gridOffset, config);

    // Add padding after conversion
    return Offset(
      screenPos.dx + context.padding.left,
      screenPos.dy + context.padding.top,
    );
  }

  GridPosition? localToGridPosition(
      Offset localPosition, CoordinateContext context) {
    final gridOffset = localToGrid(localPosition, context);

    // For edge cases, allow positions outside bounds but still return a valid GridPosition
    // This prevents null returns for extreme coordinate values
    return GridPosition.fromOffset(gridOffset);
  }

  @override
  GridPosition? screenToGrid(Offset screenPosition, CoordinateContext context,
      {RenderBox? renderBox}) {
    final cacheKey =
        '${screenPosition.dx}_${screenPosition.dy}_${context.hashCode}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey] as GridPosition?;

    try {
      // 🔧 FIX: Delegate to UnifiedCoordinateService to eliminate duplicate logic
      final unifiedService = UnifiedCoordinateService();
      final config = GridConfiguration.fromCanvas(
        rows: context.gridDimensions.height.toInt(),
        cols: context.gridDimensions.width.toInt(),
        cellSize: context.cellSize,
        scale: context.scale,
        panOffset: context.panOffset,
      );

      final gridOffset = unifiedService.screenToGrid(screenPosition, config,
          renderBox: renderBox);

      // Convert Offset to GridPosition for backward compatibility
      final position = GridPosition.fromOffset(gridOffset);
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
    CoordinateContext context, {
    RenderBox? renderBox,
    Set<GridPosition>? occupiedPositions,
    bool requireEmptyCell = true,
  }) {
    try {
      // 🛡️ SECURITY: Basic coordinate context validation
      if (context.gridDimensions.width <= 0 ||
          context.gridDimensions.height <= 0) {
        return CoordinateValidationResult.failure(
          errorMessage: 'Invalid grid dimensions - security violation',
        );
      }

      // Handle edge case: zero-sized grid
      if (context.gridDimensions.width <= 0 ||
          context.gridDimensions.height <= 0) {
        return CoordinateValidationResult.failure(
          errorMessage: 'Invalid grid dimensions',
        );
      }

      // 🛡️ SECURITY: Sanitize input position to prevent overflow attacks
      final sanitizedPosition =
          SecureCoordinateValidator.sanitizePosition(screenPosition);

      // Use sanitized position without clamping - let bounds validation handle out-of-bounds
      final clampedPosition = sanitizedPosition;

      final gridPosition =
          screenToGrid(clampedPosition, context, renderBox: renderBox);

      if (gridPosition == null) {
        return CoordinateValidationResult.failure(
          errorMessage: 'Unable to calculate grid position',
        );
      }

      // Strictly enforce bounds checking - reject out-of-bounds positions
      final isWithinBounds =
          gridPosition.isWithinBounds(context.gridDimensions);

      if (!isWithinBounds) {
        return CoordinateValidationResult.failure(
          errorMessage:
              'Drop position outside grid boundaries (row: ${gridPosition.row}, col: ${gridPosition.col}, grid: ${context.gridDimensions.height.toInt()}x${context.gridDimensions.width.toInt()})',
        );
      }

      final warnings = <String>[];
      final sanitizedOccupied = occupiedPositions
              ?.where((pos) => pos.isWithinBounds(context.gridDimensions))
              .toSet() ??
          <GridPosition>{};

      if (requireEmptyCell && sanitizedOccupied.contains(gridPosition)) {
        return CoordinateValidationResult.failure(
            errorMessage:
                'Grid position already occupied by another component');
      }

      if (_isNearBoundary(gridPosition, context)) {
        warnings.add('Near grid boundary - may cause visual clipping');
      }

      return CoordinateValidationResult.success(
        gridPosition: gridPosition,
        warnings: warnings,
      );
    } catch (e) {
      debugPrint('Coordinate validation failed: $e');
      return CoordinateValidationResult.failure(
          errorMessage: 'Invalid coordinate input');
    }
  }

  bool _isNearBoundary(GridPosition position, CoordinateContext context) {
    const boundaryTolerance = 1;
    return position.row < boundaryTolerance ||
        position.row >=
            context.gridDimensions.height.toInt() - boundaryTolerance ||
        position.col < boundaryTolerance ||
        position.col >=
            context.gridDimensions.width.toInt() - boundaryTolerance;
  }

  /// Get snapped and validated grid position for component placement
  GridPosition? getSnappedValidPosition(
    Offset screenPosition,
    CoordinateContext context, {
    RenderBox? renderBox,
    Set<GridPosition>? occupiedPositions,
    bool requireEmptyCell = true,
  }) {
    final validation = validateDropPosition(
      screenPosition,
      context,
      renderBox: renderBox,
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
