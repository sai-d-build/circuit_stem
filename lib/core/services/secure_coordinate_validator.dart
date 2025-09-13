import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/debug/structured_logger.dart';

/// Secure coordinate validator to prevent overflow attacks and ensure boundary compliance
class SecureCoordinateValidator {
  static const double maxGridWidth = 1000;
  static const double maxGridHeight = 1000;
  static const double minGridWidth = 1;
  static const double minGridHeight = 1;
  static const double cellSize = 50; // Standard cell size

  /// Sanitize a single coordinate position
  static Offset sanitizePosition(Offset position) {
    final sanitized = Offset(
      _clampCoordinate(position.dx),
      _clampCoordinate(position.dy),
    );

    // Log if sanitization occurred
    if (sanitized != position) {
      StructuredLogger.warning('🛡️ Coordinate sanitization applied', context: {
        'originalPosition': position.toString(),
        'sanitizedPosition': sanitized.toString(),
        'dxClamped': position.dx != sanitized.dx,
        'dyClamped': position.dy != sanitized.dy,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    return sanitized;
  }

  /// Sanitize multiple positions at once
  static List<Offset> sanitizePositions(List<Offset> positions) {
    return positions.map(sanitizePosition).toList();
  }

  /// Validate grid dimensions
  static Size sanitizeGridDimensions(Size dimensions) {
    final sanitized = Size(
      math.max(minGridWidth, math.min(maxGridWidth, dimensions.width)),
      math.max(minGridHeight, math.min(maxGridHeight, dimensions.height)),
    );

    if (sanitized != dimensions) {
      StructuredLogger.warning('🛡️ Grid dimensions sanitized', context: {
        'originalDimensions': dimensions.toString(),
        'sanitizedDimensions': sanitized.toString(),
        'widthClamped': dimensions.width != sanitized.width,
        'heightClamped': dimensions.height != sanitized.height,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    return sanitized;
  }

  /// Check if position is within safe bounds
  static bool isPositionSafe(Offset position, Size gridDimensions) {
    final sanitizedGrid = sanitizeGridDimensions(gridDimensions);
    final gridBounds = Rect.fromLTWH(
        0, 0, sanitizedGrid.width * cellSize, sanitizedGrid.height * cellSize);

    return gridBounds.contains(position);
  }

  /// Validate drag data for security (placeholder - implement when ComponentDragData is available)
  static bool validateDragData(dynamic dragData) {
    try {
      // Basic null check for now
      if (dragData == null) {
        StructuredLogger.error('🛡️ Invalid drag data: null data', context: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        return false;
      }

      // TODO: Implement full validation when ComponentDragData class is available
      StructuredLogger.debug('🛡️ Drag data validation placeholder', context: {
        'dataType': dragData.runtimeType.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      return true;
    } catch (e) {
      StructuredLogger.error('🛡️ Drag data validation failed with exception',
          context: {
            'error': e.toString(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
      return false;
    }
  }

  /// Sanitize scale factor to prevent rendering issues
  static double sanitizeScale(double scale) {
    const minScale = 0.1;
    const maxScale = 10.0;

    final sanitized = math.max(minScale, math.min(maxScale, scale));

    if (sanitized != scale) {
      StructuredLogger.warning('🛡️ Scale factor sanitized', context: {
        'originalScale': scale,
        'sanitizedScale': sanitized,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    return sanitized;
  }

  /// Sanitize pan offset to prevent excessive panning
  static Offset sanitizePanOffset(Offset panOffset, Size canvasSize) {
    const maxPanDistance = 10000.0; // Maximum pan distance from origin

    final distance = panOffset.distance;

    if (distance > maxPanDistance) {
      final normalized = panOffset / distance;
      final clamped = normalized * maxPanDistance;

      StructuredLogger.warning(
          '🛡️ Pan offset clamped to prevent excessive panning',
          context: {
            'originalOffset': panOffset.toString(),
            'clampedOffset': clamped.toString(),
            'originalDistance': distance,
            'maxDistance': maxPanDistance,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });

      return clamped;
    }

    return panOffset;
  }

  /// Internal coordinate clamping function
  static double _clampCoordinate(double value) {
    // Check for NaN or infinite values
    if (value.isNaN || value.isInfinite) {
      StructuredLogger.error('🛡️ Invalid coordinate detected', context: {
        'value': value,
        'isNaN': value.isNaN,
        'isInfinite': value.isInfinite,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return 0;
    }

    // Clamp to reasonable grid bounds
    const maxCoordinate = maxGridWidth * cellSize;
    final clamped = math.max(0.0, math.min(maxCoordinate, value));

    if (clamped != value) {
      StructuredLogger.warning('🛡️ Coordinate clamped', context: {
        'originalValue': value,
        'clampedValue': clamped,
        'maxAllowed': maxCoordinate,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }

    return clamped;
  }

  /// Validate coordinate context for security (placeholder - implement when CoordinateContext is available)
  static bool validateCoordinateContext(dynamic context) {
    try {
      // Basic validation for now
      if (context == null) {
        StructuredLogger.error('🛡️ Invalid coordinate context: null context',
            context: {
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            });
        return false;
      }

      // TODO: Implement full validation when CoordinateContext class is available
      StructuredLogger.debug('🛡️ Coordinate context validation placeholder',
          context: {
            'contextType': context.runtimeType.toString(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });

      return true;
    } catch (e) {
      StructuredLogger.error('🛡️ Coordinate context validation failed',
          context: {
            'error': e.toString(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
      return false;
    }
  }
}

/// Extension methods for secure coordinate validation
extension SecureOffsetExtension on Offset {
  /// Return a sanitized version of this offset
  Offset sanitized() => SecureCoordinateValidator.sanitizePosition(this);

  /// Check if this offset is within safe bounds
  bool isSafe(Size gridDimensions) =>
      SecureCoordinateValidator.isPositionSafe(this, gridDimensions);
}

extension SecureSizeExtension on Size {
  /// Return sanitized grid dimensions
  Size sanitized() => SecureCoordinateValidator.sanitizeGridDimensions(this);
}

extension SecureDoubleExtension on double {
  /// Return sanitized scale factor
  double sanitizedScale() => SecureCoordinateValidator.sanitizeScale(this);
}

// Note: ComponentDragData, ComponentType, and CoordinateContext are imported from their respective modules
// This file provides security validation utilities for coordinate operations
