import '../entities/core/grid.dart';
import '../entities/goal.dart';

abstract class GoalCheckingBehavior {
  bool isMet(Grid grid, Goal goal);
}
