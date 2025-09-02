import '../behaviors/goal_checking_behavior.dart';
import '../entities/goal.dart';
import '../entities/grid.dart';

import '../../application/services/component_factory.dart';
import '../../common/logger.dart';

class PowerBulbGoalBehavior implements GoalCheckingBehavior {
  @override
  bool isMet(Grid grid, Goal goal) {
    Logger.log('PowerBulbGoalBehavior: Checking if goal \${goal.type} is met.');
    final targetId = goal.targetId;
    if (targetId == null) {
      Logger.log('PowerBulbGoalBehavior: Goal targetId is null.');
      return false;
    }

    final component = grid.componentsById[targetId];
    if (component == null || component.type != 'Component.Bulb') {
      Logger.log(
          'PowerBulbGoalBehavior: Target component \$targetId not found or not a bulb.');
      return false;
    }

    Logger.log(
        'PowerBulbGoalBehavior: Bulb \${component.id} isPowered: \${component.isPowered}');
    return component.isPowered;
  }
}

void registerPowerBulbGoal(ComponentFactory factory) {
  Logger.log('registerPowerBulbGoal() called.');
  factory.registerBehavior<PowerBulbGoalBehavior>(() => PowerBulbGoalBehavior());

  factory.register(
    type: 'Goal.PowerBulb',
    displayName: 'Power the Bulb',
    behaviors: [PowerBulbGoalBehavior],
  );
  Logger.log('registerPowerBulbGoal() completed.');
}
