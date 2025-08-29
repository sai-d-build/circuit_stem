import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/application/game_context.dart';
import 'package:circuit_stem/domain/behaviors/behavior.dart';

/// A behavior that handles user interactions like tapping to toggle a switch.
class ToggleBehavior implements ComponentBehavior {
  const ToggleBehavior();
  @override
  String get behaviorType => 'interaction';

  @override
  ComponentModel? handle(
      ComponentModel component, String action, GameContext context) {
    // Only handle 'tap' action for 'switch' type components
    if (action == 'tap' && component.type == 'switch') {
      final currentState = component.state['closed'] as bool? ?? false;
      final newState = Map<String, dynamic>.from(component.state);
      newState['closed'] = !currentState;
      return component.copyWith(state: newState);
    }
    return null;
  }
}
