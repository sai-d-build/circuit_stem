// lib/domain/entities/components/circuit_component.dart
import 'package:flutter/material.dart';
// Note: Keeping imports minimal for Phase 1 MVP - caching foundation established but simplified
// Phase 2 integration: full theme and painter system
import '../../../presentation/core/theme/app_theme.dart';
import '../../../presentation/features/game/painters/component_painter.dart';
import '../../../core/performance/component_cache_manager.dart';
import '../../../core/debug/structured_logger.dart';
import '../core/component.dart';
import 'resistor.dart';
import 'bulb.dart';
import 'switch_entity.dart';
import 'wire.dart';
import 'battery.dart';
import 'buzzer.dart';
import 'capacitor.dart';
import 'inductor.dart';

// Forward declaration to avoid circular imports
// class CircuitPainter; // Commented out - not needed for Phase 1 MVP

/// Abstract base class for all circuit components
/// Provides common properties and methods for circuit simulation and rendering
abstract class CircuitComponent {
  final String id;
  final ComponentType type;
  final int row;
  final int col;
  final ComponentState state;
  final Map<String, dynamic> properties;
  final int rotation;

  CircuitComponent({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    int? rotation,
  }) :
    state = state ?? ComponentState.normal,
    properties = properties ?? {},
    rotation = rotation ?? 0;

  /// Position as Offset for Flutter compatibility
  Offset get position => Offset(col.toDouble(), row.toDouble());

  /// Check if component is at specific position
  bool isAtPosition(int r, int c) => row == r && col == c;

  /// Get property value with default
  T getProperty<T>(String key, T defaultValue) {
    final value = properties[key];
    return value is T ? value : defaultValue;
  }

  /// Set property value with cache invalidation
  void setProperty(String key, dynamic value) {
    properties[key] = value;
    invalidateRenderCache(); // Invalidate cache when properties change
  }

  /// Update component state with cache invalidation
  void updateState(ComponentState newState) {
    if (state != newState) {
      (this as dynamic).state = newState;
      invalidateRenderCache();
    }
  }

  /// Copy with modifications
  CircuitComponent copyWith({
    String? id,
    ComponentType? type,
    int? row,
    int? col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    int? rotation,
  });

  /// Convert to ComponentModel for backward compatibility
  ComponentModel toComponentModel() {
    return ComponentModel(
      id: id,
      type: type,
      row: row,
      col: col,
      state: state,
      properties: Map.from(properties),
      rotation: rotation,
    );
  }

  /// Factory method to create CircuitComponent from ComponentModel
  static CircuitComponent fromComponentModel(ComponentModel model) {
    switch (model.type) {
      case ComponentType.resistor:
        return Resistor.fromComponentModel(model);
      case ComponentType.bulb:
        return Bulb.fromComponentModel(model);
      case ComponentType.switch_:
        return SwitchEntity.fromComponentModel(model);
      case ComponentType.wire:
        return Wire.fromComponentModel(model);
      case ComponentType.battery:
        return Battery.fromComponentModel(model);
      case ComponentType.buzzer:
        return Buzzer.fromComponentModel(model);
      case ComponentType.inductor:
        return Inductor.fromComponentModel(model);
      case ComponentType.capacitor:
        return Capacitor.fromComponentModel(model);
      default:
        throw UnsupportedError('Unsupported component type: ${model.type}');
    }
  }

  /// Unified cached rendering for performance - now using ComponentCacheManager
  void renderToCanvas(
    Canvas canvas,
    Rect bounds,
    CircuitColorScheme colors,
    bool isSelected,
    ComponentPainter painter,
  ) {
    // Get cached picture from cache manager
    final ComponentCacheManager cacheManager = ComponentCacheManager();
    final cachedPicture = cacheManager.getComponentPicture(
      this,
      colors,
      bounds,
      painter.scale,
      isSelected,
    );

    if (cachedPicture != null) {
      // Draw cached picture directly (more efficient)
      canvas.drawPicture(cachedPicture);
    } else {
      // Fallback - render directly if cache unavailable
      StructuredLogger.debug('Component cache miss, rendering directly', context: {
        'componentId': id,
        'componentType': type.toString(),
      });

      final center = bounds.center;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      if (rotation != 0) {
        canvas.rotate(rotation * (3.141592653589793 / 180.0));
      }
      canvas.translate(-center.dx, -center.dy);

      painter.drawComponentDetails(canvas, this, bounds);
      canvas.restore();
    }
  }


  /// Invalidate render cache
  void invalidateRenderCache() {
    // Cache invalidation handled by ComponentCacheManager
  }

  /// Cleanup resources
  void dispose() {
    // Resources are managed by ComponentCacheManager
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson();

  /// Get component-specific behavior type
  String get behaviorType;

  /// Get required connections for this component
  List<String> get requiredConnections;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircuitComponent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return '$runtimeType(id: $id, type: $type, position: ($row, $col), state: $state)';
  }
}