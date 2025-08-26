import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/domain/entities/goal.dart';

class GoalCheckingService {
  const GoalCheckingService();

  bool isLevelComplete(Grid grid, LevelDefinition level) {
    if (level.goals.isEmpty) {
      return true; // No goals, level is complete
    }

    for (final goal in level.goals) {
      switch (goal.type) {
        case 'power':
          final targetComponent = grid.componentsById[goal.targetId];
          if (targetComponent == null || !targetComponent.isPowered) {
            return false; // Target component not powered
          }
          break;
        case 'unpower':
          final targetComponent = grid.componentsById[goal.targetId];
          if (targetComponent == null || targetComponent.isPowered) {
            return false; // Target component is powered
          }
          break;
        // Add other goal types here
        default:
          // Unknown goal type, consider it not met or log a warning
          return false;
      }
    }
    return true; // All goals met
  }
}