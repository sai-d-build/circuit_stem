
import 'package:collection/collection.dart';
import '../behaviors/goal_checking_behavior.dart';
import '../core/component_registry.dart';
import '../core/goal_registry.dart';
import '../engine/game_engine_state.dart';
import '../models/goal.dart';

class PowerBulbGoalBehavior implements GoalCheckingBehavior {
  final Goal goal;
  PowerBulbGoalBehavior(this.goal);

  @override
  bool isMet(GameEngineState state) {
    final component = state.grid.componentsById.values
        .firstWhereOrNull((c) => c.id == goal.targetId);
    if (component == null) return false;

    return state.renderState?.evaluationResult.poweredComponentIds.contains(component.id) ?? false;
  }
}

void registerPowerBulbGoal() {
  registerBehavior<PowerBulbGoalBehavior>(() => PowerBulbGoalBehavior(const Goal(type: 'Goal.PowerBulb')));

  GoalRegistry.register(
    type: "Goal.PowerBulb",
    behaviors: [PowerBulbGoalBehavior],
  );
}
