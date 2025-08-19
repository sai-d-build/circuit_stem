
import '../models/component.dart';
import '../models/position.dart';
import 'package:meta/meta.dart';

// A map to hold factories for behaviors, keyed by their type.
// This would typically be integrated with a proper DI/service locator framework.
final Map<Type, Function> _behaviorFactories = {};

void registerBehavior<T>(T Function() factory) {
  _behaviorFactories[T] = factory;
}

T getBehavior<T>() {
  final factory = _behaviorFactories[T];
  if (factory == null) {
    throw Exception('Behavior of type $T not registered.');
  }
  return factory() as T;
}


class ComponentRegistry {
  static final Map<String, List<Type>> _behaviors = {};
  static final Map<String, bool> _draggable = {};
  static final Map<String, String> _displayNames = {};

  static void register({
    required String type,
    required List<Type> behaviors,
    required String displayName,
    bool isDraggable = false,
  }) {
    _behaviors[type] = behaviors;
    _draggable[type] = isDraggable;
    _displayNames[type] = displayName;
  }

  static String getDisplayName(String type) {
    return _displayNames[type] ?? 'Unknown';
  }

  static ComponentModel create({
    required String type,
    required String id,
    required Position position,
    int rotation = 0,
    bool isPowered = false,
  }) {
    final behaviorTypes = _behaviors[type];
    if (behaviorTypes == null) throw Exception('Unknown component type: $type');

    final behaviorInstances = behaviorTypes.map((t) => getBehavior<dynamic>()).toList();

    return ComponentModel(
      id: id,
      position: position,
      type: type,
      behaviors: behaviorInstances,
      isDraggable: _draggable[type] ?? false,
      rotation: rotation,
      isPowered: isPowered,
    );
  }
}
