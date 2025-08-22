
// lib/behaviors/behavior.dart
// This is a placeholder for a more robust behavior system.
// In a real app, this might use a service locator or a more formal
// dependency injection system to connect behaviors.

abstract class Behavior {
  final Map<Type, Behavior> _behaviors = {};

  void attachBehavior<T extends Behavior>(T behavior) {
    _behaviors[T] = behavior;
  }

  T? getBehavior<T extends Behavior>() {
    return _behaviors[T] as T?;
  }
}
