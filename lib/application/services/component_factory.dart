import '../../domain/entities/component.dart' as component_domain;
import '../../domain/entities/circuit_component.dart';

import './component_registry.dart';

class ComponentFactory {
  final Map<Type, Function> _behaviorFactories = {};
  final Map<String, List<Type>> _behaviors = {};
  final Map<String, bool> _draggable = {};
  final Map<String, String> _displayNames = {};

  ComponentFactory() {
    _registerAllGameEntities();
  }

  void registerBehavior<T>(T Function() factory) {
    _behaviorFactories[T] = factory;
  }

  dynamic _getBehaviorByType(Type type) {
    final factory = _behaviorFactories[type];
    if (factory == null) {
      return null;
    }
    return factory();
  }

  void _registerAllGameEntities() {
    ComponentRegistry.registerAll(this);
  }

  void register({
    required String type,
    required List<Type> behaviors,
    required String displayName,
    bool isDraggable = false,
  }) {
    _behaviors[type] = behaviors;
    _draggable[type] = isDraggable;
    _displayNames[type] = displayName;
  }

  String getDisplayName(String type) {
    return _displayNames[type] ?? 'Unknown';
  }

  CircuitComponent create({
    required String type,
    required String id,
    required int r,
    required int c,
    int rotation = 0,
    bool isPowered = false,
  }) {
    return _createWithBehaviors(
      type: type,
      id: id,
      r: r,
      c: c,
      rotation: rotation,
      isPowered: isPowered,
      state: {},
    );
  }

  CircuitComponent createFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final r = (json['position']?['r'] ?? json['r']) as int;
    final c = (json['position']?['c'] ?? json['c']) as int;
    final id = json['id'] as String;
    final rotation = json['rotation'] as int? ?? 0;
    final isPowered = json['isPowered'] as bool? ?? false;
    final state = json['state'] as Map<String, dynamic>? ?? {};

    return _createWithBehaviors(
      type: type,
      id: id,
      r: r,
      c: c,
      rotation: rotation,
      isPowered: isPowered,
      state: state,
    );
  }

  /// Create instance from template (V2 API compatibility)
  CircuitComponent createInstanceFromTemplate(
    component_domain.ComponentModel template,
    int row,
    int col,
  ) {
    // Generate new unique ID
    final newId = '${template.type.toString().split('.').last}_${DateTime.now().millisecondsSinceEpoch}';

    // Convert ComponentModel to CircuitComponent using factory method
    final circuitComponent = CircuitComponent.fromComponentModel(template.copyWith(
      id: newId,
      row: row,
      col: col,
    ));

    return circuitComponent;
  }

  CircuitComponent _createWithBehaviors({
    required String type,
    required String id,
    required int r,
    required int c,
    int rotation = 0,
    bool isPowered = false,
    Map<String, dynamic>? state,
  }) {
    final componentType = component_domain.ComponentType.values.firstWhere(
      (e) => e.toString() == 'ComponentType.$type',
      orElse: () => component_domain.ComponentType.wire,
    );

    // Create ComponentModel first, then convert to CircuitComponent
    final componentModel = component_domain.ComponentModel(
      id: id,
      type: componentType,
      row: r,
      col: c,
      rotation: rotation,
      properties: state ?? {},
      state: isPowered ? component_domain.ComponentState.powered : component_domain.ComponentState.normal,
    );

    // Use factory method to create appropriate CircuitComponent subclass
    return CircuitComponent.fromComponentModel(componentModel);
  }
}