
import '../entities/goal.dart';
import '../entities/grid.dart';

abstract class GoalCheckingBehavior {
  bool isMet(Grid grid, Goal goal);
}
