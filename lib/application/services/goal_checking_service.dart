import '../../domain/entities/grid.dart';
import '../../domain/entities/level_definition.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/component.dart' as component_domain;
import '../../domain/entities/refactored_domain.dart';

// Abstract base class for goal validation
abstract class GoalValidator {
  bool validate(Goal goal, Grid grid);
}

// Concrete validators for each goal type
class PowerGoalValidator extends GoalValidator {
  @override
  bool validate(Goal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.targetId];
    if (targetComponent == null) return false;

    final requiredPower = goal.parameters?['minPower'] ?? 0;
    return targetComponent.isPowered &&
        (targetComponent.state['power'] ?? 0) >= requiredPower;
  }
}

class UnpowerGoalValidator extends GoalValidator {
  @override
  bool validate(Goal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.targetId];
    if (targetComponent == null) return false;

    return !targetComponent.isPowered;
  }
}

class ConnectGoalValidator extends GoalValidator {
  @override
  bool validate(Goal goal, Grid grid) {
    // Validate sourceId from parameters
    final params = goal.parameters ?? {};
    final sourceParam = params['sourceId'];

    // Multiple validation layers for sourceId
    if (sourceParam == null) return false;
    if (sourceParam is! String) return false;
    if (sourceParam.isEmpty) return false;

    // Validate targetId from goal
    if (goal.targetId == null) return false;
    if (goal.targetId!.isEmpty) return false;

    // Both sourceId and targetId are now confirmed to be non-null, non-empty strings
    final String confirmedSourceId = sourceParam;
    final String confirmedTargetId = goal.targetId!;

    return _performConnectivityCheck(
        confirmedSourceId, confirmedTargetId, grid);
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

  List<String> _findNeighbors(component_domain.ComponentModel component, Grid grid) {
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
  bool validate(Goal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.targetId];
    if (targetComponent == null) return false;

    final requiredVoltage = goal.parameters?['voltage'] ?? 0;
    final actualVoltage = targetComponent.state['voltage'] ?? 0;

    return (actualVoltage - requiredVoltage).abs() < 0.1;
  }
}

class CurrentGoalValidator extends GoalValidator {
  @override
  bool validate(Goal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.targetId];
    if (targetComponent == null) return false;

    final requiredCurrent = goal.parameters?['current'] ?? 0;
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
    // For now, use a simplified goal checking based on validation rules
    // In a full implementation, this would parse level.validationRules
    final goals = _extractGoalsFromValidationRules(level.validationRules);

    if (goals.isEmpty) {
      return true; // No goals, level is complete
    }

    try {
      return goals.every((goal) => _validateGoal(goal, grid));
    } catch (e) {
      return false; // If goal checking fails, level is not complete
    }
  }

  bool _validateGoal(Goal goal, Grid grid) {
    final validator = _validators[goal.type];
    if (validator == null) {
      return false; // Unknown goal type
    }

    return validator.validate(goal, grid);
  }

  // Extract goals from validation rules (simplified implementation)
  List<Goal> _extractGoalsFromValidationRules(Map<String, dynamic> validationRules) {
    final goals = <Goal>[];

    // Simple goal extraction - in a real implementation this would be more sophisticated
    if (validationRules.containsKey('powerBulb')) {
      goals.add(Goal(
        type: 'power',
        targetId: validationRules['powerBulb']['targetId'] ?? '',
        parameters: validationRules['powerBulb'],
      ));
    }

    return goals;
  }
}
