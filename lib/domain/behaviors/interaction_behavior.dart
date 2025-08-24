import 'package:circuit_stem/domain/behaviors/behavior.dart';
import 'package:circuit_stem/domain/entities/component_entity.dart';
import 'package:circuit_stem/domain/value_objects/action_context.dart';

class ToggleBehavior extends Behavior {
  @override
  String get type => 'interaction';

  @override
  bool canExecute(ComponentEntity component, String action) {
    return action == 'tap';
  }

  @override
  ComponentEntity execute(ComponentEntity component, String action, ActionContext context) {
    if (action == 'tap') {
      final currentClosedState = component.state['closed'] as bool? ?? false;
      final newState = Map<String, dynamic>.from(component.state)
        ..['closed'] = !currentClosedState;
      return component.copyWith(state: newState);
    }
    return component;
  }
}
