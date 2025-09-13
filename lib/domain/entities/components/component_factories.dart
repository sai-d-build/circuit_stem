// lib/domain/entities/components/component_factories.dart
import '../core/component.dart';

/// Utility functions for creating CircuitComponents from ComponentModels
class ComponentFactoryUtilities {
  /// Common logic for extracting standard properties from ComponentModel
  static Map<String, dynamic> extractProperties(
      Map<String, dynamic>? modelProperties) {
    return modelProperties != null
        ? Map<String, dynamic>.from(modelProperties)
        : {};
  }

  /// Common constructor parameters for creating components from ComponentModel
  static Map<String, dynamic> getCommonConstructorArgs(String id, int row,
      int col, ComponentState state, Map<String, dynamic> properties) {
    return {
      'id': id,
      'row': row,
      'col': col,
      'state': state,
      'properties': Map<String, dynamic>.from(properties),
      'rotation': properties['rotation'] ?? 0,
    };
  }
}
