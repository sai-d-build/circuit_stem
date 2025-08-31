import 'package:flutter/material.dart';
import 'package:sparkcircuit/domain/entities/component.dart';

// Dummy CircuitComponent for the painter, will be replaced by a proper model
class CircuitComponent {
  final String id;
  final String type;
  final double posX;
  final double posY;
  final bool isActive;
  final Map<String, dynamic> properties;

  CircuitComponent({
    required this.id,
    required this.type,
    required this.posX,
    required this.posY,
    required this.isActive,
    required this.properties,
  });

  factory CircuitComponent.fromComponentModel(ComponentModel component) {
    return CircuitComponent(
      id: component.id,
      type: component.type.toString().split('.').last, // Convert enum to string
      posX: component.col.toDouble(),
      posY: component.row.toDouble(),
      isActive: component.state == ComponentState.powered,
      properties: component.properties,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircuitComponent &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          posX == other.posX &&
          posY == other.posY &&
          isActive == other.isActive &&
          mapEquals(properties, other.properties);

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      posX.hashCode ^
      posY.hashCode ^
      isActive.hashCode ^
      properties.hashCode;
}

// Dummy CircuitWire for the painter, will be replaced by a proper model
class CircuitWire {
  final String id;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final bool isActive;

  CircuitWire({
    required this.id,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.isActive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircuitWire &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startX == other.startX &&
          startY == other.startY &&
          endX == other.endX &&
          endY == other.endY &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      startX.hashCode ^
      startY.hashCode ^
      endX.hashCode ^
      endY.hashCode ^
      isActive.hashCode;
}

bool mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (a == b) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) {
      return false;
    }
  }
  return true;
}
