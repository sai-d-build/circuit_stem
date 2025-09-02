import 'package:flutter/material.dart';
import 'component.dart';
import 'resistor.dart';
import 'bulb.dart';
import 'switch_entity.dart';
import 'wire.dart';
import 'battery.dart';
import 'buzzer.dart';

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

  /// Set property value
  void setProperty(String key, dynamic value) {
    properties[key] = value;
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
      default:
        throw UnsupportedError('Unsupported component type: ${model.type}');
    }
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