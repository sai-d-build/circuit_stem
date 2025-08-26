import '../../domain/entities/grid.dart';
import '../../domain/entities/level_definition.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/component.dart';

class GoalCheckingService {
  const GoalCheckingService();

  bool isLevelComplete(Grid grid, LevelDefinition level) {
    if (level.goals.isEmpty) {
      return true; // No goals, level is complete
    }

    try {
      return level.goals.every((goal) => _checkGoal(goal, grid));
    } catch (e) {
      return false; // If goal checking fails, level is not complete
    }
  }

  bool _checkGoal(Goal goal, Grid grid) {
    switch (goal.type) {
      case 'power':
        return _checkPowerGoal(goal, grid);
      case 'unpower':
        return _checkUnpowerGoal(goal, grid);
      case 'connect':
        return _checkConnectGoal(goal, grid);
      case 'voltage':
        return _checkVoltageGoal(goal, grid);
      case 'current':
        return _checkCurrentGoal(goal, grid);
      default:
        return false; // Unknown goal type
    }
  }

  bool _checkPowerGoal(Goal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.targetId];
    if (targetComponent == null) return false;
    
    final requiredPower = goal.parameters?['minPower'] ?? 0;
    return targetComponent.isPowered && 
           (targetComponent.state['power'] ?? 0) >= requiredPower;
  }

  bool _checkUnpowerGoal(Goal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.targetId];
    if (targetComponent == null) return false;
    
    return !targetComponent.isPowered;
  }

  bool _checkConnectGoal(Goal goal, Grid grid) {
    final sourceId = goal.parameters?['sourceId'];
    final targetId = goal.targetId;
    
    if (sourceId == null) return false;
    
    return _areComponentsConnected(sourceId, targetId, grid);
  }

  bool _checkVoltageGoal(Goal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.targetId];
    if (targetComponent == null) return false;
    
    final requiredVoltage = goal.parameters?['voltage'] ?? 0;
    final actualVoltage = targetComponent.state['voltage'] ?? 0;
    
    return (actualVoltage - requiredVoltage).abs() < 0.1; // Allow small tolerance
  }

  bool _checkCurrentGoal(Goal goal, Grid grid) {
    final targetComponent = grid.componentsById[goal.targetId];
    if (targetComponent == null) return false;
    
    final requiredCurrent = goal.parameters?['current'] ?? 0;
    final actualCurrent = targetComponent.state['current'] ?? 0;
    
    return (actualCurrent - requiredCurrent).abs() < 0.01; // Allow small tolerance
  }

  bool _areComponentsConnected(String sourceId, String targetId, Grid grid) {
    final source = grid.componentsById[sourceId];
    final target = grid.componentsById[targetId];
    
    if (source == null || target == null) return false;
    
    // Use BFS to check connectivity
    final visited = <String>{};
    final queue = <String>[sourceId];
    
    while (queue.isNotEmpty) {
      final currentId = queue.removeAt(0);
      if (visited.contains(currentId)) continue;
      visited.add(currentId);
      
      if (currentId == targetId) return true;
      
      final current = grid.componentsById[currentId];
      if (current == null) continue;
      
      // Add connected components to queue
      for (final neighbor in _getConnectedComponentIds(current, grid)) {
        if (!visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
    
    return false;
  }

  List<String> _getConnectedComponentIds(ComponentModel component, Grid grid) {
    final connected = <String>[];
    
    for (final terminal in component.terminals) {
      final terminalR = component.r + terminal.offset.r;
      final terminalC = component.c + terminal.offset.c;

      int nextR = terminalR;
      int nextC = terminalC;
      
      switch (terminal.direction) {
        case Dir.north:
          nextR--;
          break;
        case Dir.east:
          nextC++;
          break;
        case Dir.south:
          nextR++;
          break;
        case Dir.west:
          nextC--;
          break;
      }

      final neighbor = grid.componentAt(nextR, nextC);
      if (neighbor != null) {
        connected.add(neighbor.id);
      }
    }
    
    return connected;
  }
}
