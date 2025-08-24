import 'package:collection/collection.dart';
import 'package:circuit_stem/domain/behaviors/behavior.dart';
import 'package:circuit_stem/domain/value_objects/position.dart';
import 'package:circuit_stem/domain/value_objects/action_context.dart';
import 'package:circuit_stem/domain/value_objects/component_type.dart';

class ComponentEntity {
  final String id;
  final ComponentType type;
  final Position position;
  final Map<String, dynamic> state;
  final List<Behavior> behaviors;

  ComponentEntity({
    required this.id,
    required this.type,
    required this.position,
    required this.state,
    required this.behaviors,
  });

  // Helper to get a specific behavior
  T? getBehavior<T extends Behavior>() {
    return behaviors.whereType<T>().firstOrNull;
  }

  // The core logic for executing an action
  ComponentEntity executeAction(String action, ActionContext context) {
    ComponentEntity result = this;
    for (final behavior in behaviors) {
      if (behavior.canExecute(this, action)) {
        result = behavior.execute(result, action, context);
      }
    }
    return result;
  }

  // CopyWith for immutable updates
  ComponentEntity copyWith({
    Position? position,
    Map<String, dynamic>? state,
  }) {
    return ComponentEntity(
      id: id,
      type: type,
      position: position ?? this.position,
      state: state ?? this.state,
      behaviors: behaviors,
    );
  }
}
