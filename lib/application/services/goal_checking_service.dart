import 'package:sparkcircuit/domain/entities/entities.dart';

// Abstract base class for goal validation
abstract class GoalValidator {
  bool validate(LevelGoal goal, Grid grid);
}

// Concrete validators for each goal type
class PowerGoalValidator extends GoalValidator {
  @override
  bool validate(LevelGoal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.conditions?['targetId']];
    if (targetComponent == null) return false;

    final requiredPower = goal.conditions?['minPower'] ?? 0;
    return targetComponent.isPowered &&
        (targetComponent.state['power'] ?? 0) >= requiredPower;
  }
}

class UnpowerGoalValidator extends GoalValidator {
  @override
  bool validate(LevelGoal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.conditions?['targetId']];
    if (targetComponent == null) return false;

    return !targetComponent.isPowered;
  }
}

class ConnectGoalValidator extends GoalValidator {
  @override
  bool validate(LevelGoal goal, Grid grid) {
    final sourceId = goal.conditions?['sourceId'];
    final targetId = goal.conditions?['targetId'];

    if (sourceId == null || targetId == null) return false;

    return _performConnectivityCheck(sourceId, targetId, grid);
  }

  bool _performConnectivityCheck(String sourceId, String targetId, Grid grid) {
    final source = grid.componentsById[sourceId];
    final target = grid.componentsById[targetId];

    if (source == null || target == null) return false;

    // BFS connectivity check
    final visited = <String>{};
    final toVisit = [sourceId];

    for (int i = 0; i < toVisit.length; i++) {
      final currentId = toVisit[i];

      if (visited.contains(currentId)) continue;
      visited.add(currentId);

      if (currentId == targetId) return true;

      final current = grid.componentsById[currentId];
      if (current == null) continue;

      // Add neighbors to visit list
      final neighbors = _findNeighbors(current, grid);
      for (final neighborId in neighbors) {
        if (!visited.contains(neighborId)) {
          toVisit.add(neighborId);
        }
      }
    }

    return false;
  }

  List<String> _findNeighbors(ComponentModel component, Grid grid) {
    final neighbors = <String>[];

    // Simplified neighbor finding - check adjacent cells
    final directions = [
      (-1, 0), // North
      (1, 0),  // South
      (0, -1), // West
      (0, 1),  // East
    ];

    for (final (dr, dc) in directions) {
      final nextR = component.row + dr;
      final nextC = component.col + dc;

      final neighbor = grid.componentAt(nextR, nextC);
      if (neighbor != null) {
        neighbors.add(neighbor.id);
      }
    }

    return neighbors;
  }
}

class VoltageGoalValidator extends GoalValidator {
  @override
  bool validate(LevelGoal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.conditions?['targetId']];
    if (targetComponent == null) return false;

    final requiredVoltage = goal.conditions?['voltage'] ?? 0;
    final actualVoltage = targetComponent.state['voltage'] ?? 0;

    return (actualVoltage - requiredVoltage).abs() < 0.1;
  }
}

class CurrentGoalValidator extends GoalValidator {
  @override
  bool validate(LevelGoal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.conditions?['targetId']];
    if (targetComponent == null) return false;

    final requiredCurrent = goal.conditions?['current'] ?? 0;
    final actualCurrent = targetComponent.state['current'] ?? 0;

    return (actualCurrent - requiredCurrent).abs() < 0.01;
  }
}

// Main service using factory pattern
class GoalCheckingService {
  const GoalCheckingService();

  // Factory map for goal validators
  static final Map<String, GoalValidator> _validators = {
    'power': PowerGoalValidator(),
    'unpower': UnpowerGoalValidator(),
    'connect': ConnectGoalValidator(),
    'voltage': VoltageGoalValidator(),
    'current': CurrentGoalValidator(),
  };

  bool isLevelComplete(Grid grid, LevelDefinition level) {
    if (level.goals.isEmpty) {
      return true; // No goals, level is complete
    }

    try {
      return level.goals.every((levelGoal) => _validateGoal(levelGoal, grid));
    } catch (e) {
      return false; // If goal checking fails, level is not complete
    }
  }

  bool _validateGoal(LevelGoal levelGoal, Grid grid) {
    final validator = _validators[levelGoal.type];
    if (validator == null) {
      return false; // Unknown goal type
    }

    return validator.validate(levelGoal, grid);
  }
}