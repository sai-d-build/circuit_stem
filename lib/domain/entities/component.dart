// Core component entity for SparkCircuit
// This defines the basic structure for all circuit components

import 'package:flutter/material.dart';
import '../../common/logger.dart';

enum ComponentType {
  battery,
  resistor,
  capacitor,
  inductor,
  diode,
  transistor,
  switch_,
  bulb,
  buzzer,
  timer,
  wire,
  ground,
}

enum ComponentState {
  normal,
  powered,
  error,
  selected,
  dragging,
}

// Extension to add map-like access to ComponentState
extension ComponentStateExtension on ComponentState {
  dynamic operator [](String key) {
    // This is a simplified implementation
    // In a real implementation, you'd want to store state data separately
    return null;
  }

  void operator []=(String key, dynamic value) {
    // This is a simplified implementation
    // In a real implementation, you'd want to store state data separately
  }
}

class ComponentModel {
  final String id;
  final ComponentType type;
  final int row;
  final int col;
  final ComponentState state;
  final Map<String, dynamic> properties;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Component behaviors (simplified for now)
  final List<String> behaviors;

  // Rotation angle in degrees
  final int rotation;

  ComponentModel({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    List<String>? behaviors,
    int? rotation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
    state = state ?? ComponentState.normal,
    properties = properties ?? {},
    behaviors = behaviors ?? [],
    rotation = rotation ?? 0,
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  ComponentModel copyWith({
    String? id,
    ComponentType? type,
    int? row,
    int? col,
    ComponentState? state,
    Map<String, dynamic>? properties,
    List<String>? behaviors,
    int? rotation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComponentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      row: row ?? this.row,
      col: col ?? this.col,
      state: state ?? this.state,
      properties: properties ?? this.properties,
      behaviors: behaviors ?? this.behaviors,
      rotation: rotation ?? this.rotation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Legacy compatibility properties
  bool get isPowered => state == ComponentState.powered;
  bool get isSelected => state == ComponentState.selected;

  // Position as Offset for Flutter compatibility
  Offset get position => Offset(row.toDouble(), col.toDouble());

  // Component-specific properties
  double get resistance => properties['resistance'] ?? 0.0;
  double get voltage => properties['voltage'] ?? 0.0;
  double get capacitance => properties['capacitance'] ?? 0.0;
  double get inductance => properties['inductance'] ?? 0.0;
  bool get isOn => properties['isOn'] ?? false;

  // Utility methods
  bool isAtPosition(int r, int c) => row == r && col == c;

  void logState() {
    Logger.logComponentEvent(id, 'state_changed', {
      'type': type.toString(),
      'state': state.toString(),
      'position': '($row, $col)',
      'properties': properties,
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComponentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'row': row,
      'col': col,
      'state': state.toString(),
      'properties': properties,
      'behaviors': behaviors,
      'rotation': rotation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    return ComponentModel(
      id: json['id'],
      type: ComponentType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      row: json['row'],
      col: json['col'],
      state: ComponentState.values.firstWhere(
        (e) => e.toString() == json['state'],
        orElse: () => ComponentState.normal,
      ),
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      behaviors: List<String>.from(json['behaviors'] ?? []),
      rotation: json['rotation'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  String toString() {
    return 'ComponentModel(id: $id, type: $type, position: ($row, $col), state: $state)';
  }
}

// Component definition for creating new instances
class ComponentDefinition {
  final ComponentType type;
  final String name;
  final String description;
  final Map<String, dynamic> defaultProperties;
  final List<String> requiredConnections;

  const ComponentDefinition({
    required this.type,
    required this.name,
    required this.description,
    this.defaultProperties = const {},
    this.requiredConnections = const [],
  });

  ComponentModel createInstance(String id, int row, int col) {
    return ComponentModel(
      id: id,
      type: type,
      row: row,
      col: col,
      properties: Map.from(defaultProperties),
    );
  }
}

// Predefined component definitions
class ComponentDefinitions {
  static const battery = ComponentDefinition(
    type: ComponentType.battery,
    name: 'Battery',
    description: 'Power source for the circuit',
    defaultProperties: {'voltage': 9.0},
    requiredConnections: ['positive', 'negative'],
  );

  static const resistor = ComponentDefinition(
    type: ComponentType.resistor,
    name: 'Resistor',
    description: 'Limits current flow in the circuit',
    defaultProperties: {'resistance': 1000.0},
    requiredConnections: ['a', 'b'],
  );

  static const bulb = ComponentDefinition(
    type: ComponentType.bulb,
    name: 'Light Bulb',
    description: 'Lights up when current flows through it',
    defaultProperties: {'resistance': 100.0},
    requiredConnections: ['positive', 'negative'],
  );

  static const switch_ = ComponentDefinition(
    type: ComponentType.switch_,
    name: 'Switch',
    description: 'Controls current flow in the circuit',
    defaultProperties: {'isOn': false},
    requiredConnections: ['input', 'output'],
  );

  static const wire = ComponentDefinition(
    type: ComponentType.wire,
    name: 'Wire',
    description: 'Connects components in the circuit',
    requiredConnections: ['start', 'end'],
  );

  static ComponentDefinition getDefinition(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
        return battery;
      case ComponentType.resistor:
        return resistor;
      case ComponentType.bulb:
        return bulb;
      case ComponentType.switch_:
        return switch_;
      case ComponentType.wire:
        return wire;
      default:
        return ComponentDefinition(
          type: type,
          name: type.toString(),
          description: 'Generic component',
        );
    }
  }
}