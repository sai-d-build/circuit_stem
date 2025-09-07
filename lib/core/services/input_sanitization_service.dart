import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/debug/structured_logger.dart';
import 'secure_coordinate_validator.dart';

/// Complete input sanitization service for all drag-and-drop operations
/// Provides comprehensive validation and sanitization of user inputs
class InputSanitizationService {
  static final InputSanitizationService _instance = InputSanitizationService._();
  factory InputSanitizationService() => _instance;
  InputSanitizationService._();

  // Validation cache for performance
  final Map<String, _ValidationResult> _validationCache = {};
  static const int _maxCacheSize = 200;

  /// Sanitize and validate drag data
  DragDataValidationResult sanitizeDragData(dynamic dragData) {
    final cacheKey = 'drag_${dragData.hashCode}';
    final cached = _validationCache[cacheKey];
    if (cached != null) {
      return cached.result;
    }

    try {
      final result = _validateAndSanitizeDragData(dragData);
      _validationCache[cacheKey] = _ValidationResult(result, DateTime.now());
      _manageCacheSize();

      return result;
    } catch (e) {
      StructuredLogger.error('InputSanitizationService: Drag data sanitization failed', context: {
        'error': e.toString(),
        'dragDataType': dragData.runtimeType.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      return DragDataValidationResult.invalid('Sanitization failed: $e');
    }
  }

  DragDataValidationResult _validateAndSanitizeDragData(dynamic dragData) {
    // Handle null data
    if (dragData == null) {
      return DragDataValidationResult.invalid('Drag data is null');
    }

    // Handle different drag data types
    if (dragData is Map<String, dynamic>) {
      return _sanitizeMapDragData(dragData);
    } else if (dragData is String) {
      return _sanitizeStringDragData(dragData);
    } else {
      // Try to extract meaningful data from unknown type
      return _sanitizeGenericDragData(dragData);
    }
  }

  DragDataValidationResult _sanitizeMapDragData(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    final warnings = <String>[];

    // Required fields validation
    final componentType = data['componentType'];
    if (componentType == null) {
      return DragDataValidationResult.invalid('Missing componentType');
    }

    // Sanitize component type
    final sanitizedType = _sanitizeComponentType(componentType);
    if (sanitizedType == null) {
      return DragDataValidationResult.invalid('Invalid componentType: $componentType');
    }
    sanitized['componentType'] = sanitizedType;

    // Sanitize component name
    final componentName = data['componentName'] ?? '';
    final sanitizedName = _sanitizeString(componentName, maxLength: 100);
    if (sanitizedName.isEmpty) {
      warnings.add('Component name was empty or invalid');
    }
    sanitized['componentName'] = sanitizedName;

    // Sanitize cost
    final cost = data['cost'];
    if (cost != null) {
      final sanitizedCost = _sanitizeNumeric(cost, min: 0, max: 10000);
      if (sanitizedCost == null) {
        return DragDataValidationResult.invalid('Invalid cost: $cost');
      }
      sanitized['cost'] = sanitizedCost;
    }

    // Sanitize additional properties
    final properties = data['properties'];
    if (properties is Map<String, dynamic>) {
      sanitized['properties'] = _sanitizeProperties(properties);
    }

    return DragDataValidationResult.valid(sanitized, warnings: warnings);
  }

  DragDataValidationResult _sanitizeStringDragData(String data) {
    try {
      // Try to parse as JSON
      final jsonData = json.decode(data);
      if (jsonData is Map<String, dynamic>) {
        return _sanitizeMapDragData(jsonData);
      }
    } catch (e) {
      // Not JSON, treat as component name
      final sanitizedName = _sanitizeString(data, maxLength: 100);
      if (sanitizedName.isEmpty) {
        return DragDataValidationResult.invalid('Invalid component name');
      }

      return DragDataValidationResult.valid({
        'componentType': 'unknown',
        'componentName': sanitizedName,
        'cost': 0,
      }, warnings: ['Parsed as simple component name']);
    }

    return DragDataValidationResult.invalid('Cannot parse string drag data');
  }

  DragDataValidationResult _sanitizeGenericDragData(dynamic data) {
    // Extract meaningful information from unknown objects
    final sanitized = <String, dynamic>{};

    try {
      // Try to get component type
      final componentType = _extractComponentType(data);
      if (componentType != null) {
        sanitized['componentType'] = componentType;
      }

      // Try to get component name
      final componentName = _extractComponentName(data);
      if (componentName != null && componentName.isNotEmpty) {
        sanitized['componentName'] = componentName;
      }

      // Try to get cost
      final cost = _extractCost(data);
      if (cost != null) {
        sanitized['cost'] = cost;
      }

      if (sanitized.isEmpty) {
        return DragDataValidationResult.invalid('No valid data extracted from drag object');
      }

      return DragDataValidationResult.valid(sanitized, warnings: ['Extracted from generic object']);
    } catch (e) {
      return DragDataValidationResult.invalid('Failed to extract data: $e');
    }
  }

  String? _sanitizeComponentType(dynamic type) {
    if (type is String) {
      final lowerType = type.toLowerCase().trim();
      // Allow only known component types
      const validTypes = [
        'resistor', 'capacitor', 'inductor', 'bulb', 'battery',
        'switch', 'wire', 'buzzer', 'diode', 'transistor'
      ];

      if (validTypes.contains(lowerType)) {
        return lowerType;
      }
    }

    return null;
  }

  String _sanitizeString(dynamic value, {int maxLength = 1000}) {
    if (value == null) return '';

    final str = value.toString().trim();

    // Remove potentially dangerous characters
    final sanitized = str.replaceAll(RegExp(r'[<>"/\\]'), '');

    // Limit length
    if (sanitized.length > maxLength) {
      return sanitized.substring(0, maxLength);
    }

    return sanitized;
  }

  num? _sanitizeNumeric(dynamic value, {num? min, num? max}) {
    if (value == null) return null;

    num? number;

    if (value is num) {
      number = value;
    } else if (value is String) {
      number = num.tryParse(value);
    }

    if (number == null) return null;

    // Check bounds
    if (min != null && number < min) return null;
    if (max != null && number > max) return null;

    // Check for special values
    if (number.isNaN || number.isInfinite) return null;

    return number;
  }

  Map<String, dynamic> _sanitizeProperties(Map<String, dynamic> properties) {
    final sanitized = <String, dynamic>{};

    for (final entry in properties.entries) {
      final key = _sanitizeString(entry.key, maxLength: 50);
      if (key.isEmpty) continue;

      final value = entry.value;

      // Sanitize different value types
      if (value is num) {
        final sanitizedValue = _sanitizeNumeric(value, min: -1000000, max: 1000000);
        if (sanitizedValue != null) {
          sanitized[key] = sanitizedValue;
        }
      } else if (value is String) {
        sanitized[key] = _sanitizeString(value, maxLength: 500);
      } else if (value is bool) {
        sanitized[key] = value;
      }
      // Skip other types for security
    }

    return sanitized;
  }

  String? _extractComponentType(dynamic data) {
    // Try common property names
    final possibleKeys = ['componentType', 'type', 'component_type', 'kind'];

    for (final key in possibleKeys) {
      if (data is Map && data.containsKey(key)) {
        return _sanitizeComponentType(data[key]);
      }
    }

    // Try object properties
    try {
      final type = data.componentType ?? data.type ?? data.kind;
      return _sanitizeComponentType(type);
    } catch (e) {
      // Ignore property access errors
    }

    return null;
  }

  String? _extractComponentName(dynamic data) {
    final possibleKeys = ['componentName', 'name', 'component_name', 'label'];

    for (final key in possibleKeys) {
      if (data is Map && data.containsKey(key)) {
        return _sanitizeString(data[key], maxLength: 100);
      }
    }

    try {
      final name = data.componentName ?? data.name ?? data.label;
      return _sanitizeString(name, maxLength: 100);
    } catch (e) {
      // Ignore property access errors
    }

    return null;
  }

  num? _extractCost(dynamic data) {
    final possibleKeys = ['cost', 'price', 'value'];

    for (final key in possibleKeys) {
      if (data is Map && data.containsKey(key)) {
        return _sanitizeNumeric(data[key], min: 0, max: 10000);
      }
    }

    try {
      final cost = data.cost ?? data.price ?? data.value;
      return _sanitizeNumeric(cost, min: 0, max: 10000);
    } catch (e) {
      // Ignore property access errors
    }

    return null;
  }

  /// Sanitize coordinate data
  Offset sanitizeCoordinates(Offset coordinates) {
    return SecureCoordinateValidator.sanitizePosition(coordinates);
  }

  /// Validate gesture input
  GestureValidationResult validateGesture(String gestureType, Map<String, dynamic> data) {
    try {
      switch (gestureType.toLowerCase()) {
        case 'drag':
          return _validateDragGesture(data);
        case 'pan':
          return _validatePanGesture(data);
        case 'scale':
          return _validateScaleGesture(data);
        case 'tap':
          return _validateTapGesture(data);
        default:
          return GestureValidationResult.invalid('Unknown gesture type: $gestureType');
      }
    } catch (e) {
      return GestureValidationResult.invalid('Gesture validation failed: $e');
    }
  }

  GestureValidationResult _validateDragGesture(Map<String, dynamic> data) {
    final startPosition = data['startPosition'];
    final currentPosition = data['currentPosition'];

    if (startPosition is! Offset || currentPosition is! Offset) {
      return GestureValidationResult.invalid('Invalid drag positions');
    }

    final sanitizedStart = sanitizeCoordinates(startPosition);
    final sanitizedCurrent = sanitizeCoordinates(currentPosition);

    // Check for suspicious drag patterns
    final distance = (sanitizedCurrent - sanitizedStart).distance;
    if (distance > 10000) { // Unreasonably long drag
      return GestureValidationResult.invalid('Drag distance too large');
    }

    return GestureValidationResult.valid({
      'startPosition': sanitizedStart,
      'currentPosition': sanitizedCurrent,
      'distance': distance,
    });
  }

  GestureValidationResult _validatePanGesture(Map<String, dynamic> data) {
    final delta = data['delta'];
    if (delta is! Offset) {
      return GestureValidationResult.invalid('Invalid pan delta');
    }

    final sanitizedDelta = sanitizeCoordinates(delta);

    // Limit pan speed
    if (sanitizedDelta.distance > 1000) {
      return GestureValidationResult.invalid('Pan delta too large');
    }

    return GestureValidationResult.valid({'delta': sanitizedDelta});
  }

  GestureValidationResult _validateScaleGesture(Map<String, dynamic> data) {
    final scale = data['scale'];
    if (scale is! double) {
      return GestureValidationResult.invalid('Invalid scale value');
    }

    final sanitizedScale = SecureCoordinateValidator.sanitizeScale(scale);

    return GestureValidationResult.valid({'scale': sanitizedScale});
  }

  GestureValidationResult _validateTapGesture(Map<String, dynamic> data) {
    final position = data['position'];
    if (position is! Offset) {
      return GestureValidationResult.invalid('Invalid tap position');
    }

    final sanitizedPosition = sanitizeCoordinates(position);

    return GestureValidationResult.valid({'position': sanitizedPosition});
  }

  void _manageCacheSize() {
    if (_validationCache.length > _maxCacheSize) {
      // Remove oldest entries
      final entries = _validationCache.entries.toList()
        ..sort((a, b) => a.value.timestamp.compareTo(b.value.timestamp));

      final toRemove = entries.take(_validationCache.length - _maxCacheSize + 20);
      for (final entry in toRemove) {
        _validationCache.remove(entry.key);
      }
    }
  }

  void clearCache() {
    _validationCache.clear();
  }
}

/// Validation result classes
class DragDataValidationResult {
  final bool isValid;
  final Map<String, dynamic>? sanitizedData;
  final String? errorMessage;
  final List<String> warnings;

  const DragDataValidationResult._({
    required this.isValid,
    this.sanitizedData,
    this.errorMessage,
    this.warnings = const [],
  });

  factory DragDataValidationResult.valid(Map<String, dynamic> data, {List<String> warnings = const []}) {
    return DragDataValidationResult._(
      isValid: true,
      sanitizedData: data,
      warnings: warnings,
    );
  }

  factory DragDataValidationResult.invalid(String error) {
    return DragDataValidationResult._(
      isValid: false,
      errorMessage: error,
    );
  }
}

class GestureValidationResult {
  final bool isValid;
  final Map<String, dynamic>? sanitizedData;
  final String? errorMessage;

  const GestureValidationResult._({
    required this.isValid,
    this.sanitizedData,
    this.errorMessage,
  });

  factory GestureValidationResult.valid(Map<String, dynamic> data) {
    return GestureValidationResult._(
      isValid: true,
      sanitizedData: data,
    );
  }

  factory GestureValidationResult.invalid(String error) {
    return GestureValidationResult._(
      isValid: false,
      errorMessage: error,
    );
  }
}

class _ValidationResult {
  final DragDataValidationResult result;
  final DateTime timestamp;

  const _ValidationResult(this.result, this.timestamp);
}