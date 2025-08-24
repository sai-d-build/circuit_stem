
import '../entities/component.dart';
import '../entities/grid.dart';

/// Defines the interface for a component's circuit evaluation logic.
abstract class LogicBehavior {
  void evaluate(Grid grid, ComponentModel component);
}
