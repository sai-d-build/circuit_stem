import '../entities/goal.dart';
import '../entities/core/grid.dart';

abstract class GoalCheckingBehavior {
  bool isMet(Grid grid, Goal goal);
}
