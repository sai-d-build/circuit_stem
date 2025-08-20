
import '../models/goal.dart';
import '../models/grid.dart';

abstract class GoalCheckingBehavior {
  bool isMet(Grid grid, Goal goal);
}
