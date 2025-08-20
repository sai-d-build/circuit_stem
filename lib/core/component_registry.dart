import '../models/component.dart';
import '../common/logger.dart';

// A map to hold factories for behaviors, keyed by their type.
// This would typically be integrated with a proper DI/service locator framework.
final Map<Type, Function> _behaviorFactories = {};

void registerBehavior<T>(T Function() factory) {
  _behaviorFactories[T] = factory;
  Logger.log('ComponentRegistry: Registered behavior factory for type: $T');
}

/// Retrieve a behavior instance by runtime [type]. This avoids relying on generic
/// type parameters at the call-site (which are erased at runtime) and lets callers
/// request an instance for a specific Type.
dynamic getBehaviorByType(Type type) {
  final factory = _behaviorFactories[type];
  if (factory == null) {
    Logger.log('ComponentRegistry: ERROR: Behavior factory for type $type not registered.');
    return null;
  }
  Logger.log('ComponentRegistry: Retrieved behavior factory for type: $type');
  return factory();
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
    required int r,
    required int c,
    int rotation = 0,
    bool isPowered = false,
  }) {
    final behaviorTypes = _behaviors[type];
    if (behaviorTypes == null) throw Exception('Unknown component type: $type');

    // Instantiate behavior instances using the runtime type -> factory map.
    final behaviorInstances = behaviorTypes.map((t) {
      final instance = getBehaviorByType(t);
      if (instance == null) {
        Logger.log('ComponentRegistry: No factory for behavior type: \$t');
      }
      return instance;
    }).toList();

    return ComponentModel(
      id: id,
      r: r,
      c: c,
      type: type,
      behaviors: behaviorInstances,
      isDraggable: _draggable[type] ?? false,
      rotation: rotation,
      isPowered: isPowered,
    );
  }
}
