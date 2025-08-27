import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/application/game_context.dart';

/// Defines the contract for all component behaviors.
/// Behaviors are functional: they take a component, an action, and context,
/// and return a *new* ComponentModel if the state changes, or null otherwise.
abstract class ComponentBehavior {
  const ComponentBehavior();

  String
      get behaviorType; // e.g., 'interaction', 'power_conduction', 'movement'

  /// Handles a specific action for a component.
  /// Returns a new ComponentModel if the component's state changes,
  /// otherwise returns null.
  ComponentModel? handle(
      ComponentModel component, String action, GameContext context);
}
