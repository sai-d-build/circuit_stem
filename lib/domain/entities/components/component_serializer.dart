// lib/domain/entities/components/component_serializer.dart
import 'circuit_component.dart';

/// Utility class for serializing CircuitComponents to JSON
class ComponentSerializer {
  /// Get common fields that all components share
  static Map<String, dynamic> getCommonFields(CircuitComponent component) {
    return {
      'id': component.id,
      'type': component.type.toString(),
      'row': component.row,
      'col': component.col,
      'state': component.state.toString(),
      'properties': component.properties,
      'rotation': component.rotation,
    };
  }

  /// Serialize a component using common fields plus component-specific fields
  static Map<String, dynamic> serialize(
      CircuitComponent component, Map<String, dynamic> additionalFields) {
    final common = getCommonFields(component);
    common.addAll(additionalFields);
    return common;
  }
}
