import 'package:sparkcircuit/domain/entities/entities.dart';

import '../../application/services/power_simulation_service.dart';
import '../../common/logger.dart';

/// Service for validating educational objectives and learning progress
class EducationalValidator {
  final PowerSimulationService _simulationEngine;

  EducationalValidator(this._simulationEngine);

  /// Validate if a circuit meets educational objectives
  bool validateCircuit(Grid grid, Map<String, dynamic> objectives) {
    Logger.log(
        'EducationalValidator: Validating circuit with ${objectives.length} objectives');

    // Run simulation to get current state
    final simulatedGrid = _simulationEngine.simulatePowerFlow(grid);

    // Check basic connectivity
    if (!hasConnectedCircuit(simulatedGrid)) {
      Logger.log('EducationalValidator: Circuit is not properly connected');
      return false;
    }

    // Check if lights are powered (basic objective)
    if (!hasPoweredLights(simulatedGrid)) {
      Logger.log('EducationalValidator: No powered lights found');
      return false;
    }

    Logger.log('EducationalValidator: Circuit validation passed');
    return true;
  }

  /// Check if circuit has proper connections
  bool hasConnectedCircuit(Grid grid) {
    // Simple check - ensure there are components and connections
    return grid.getComponentCount() > 0 && grid.getConnections('').isNotEmpty;
  }

  /// Check if any lights are powered
  bool hasPoweredLights(Grid grid) {
    return grid.getAllComponents().any((component) =>
        component.type == ComponentType.bulb && component.isPowered);
  }

  /// Get learning feedback for the current circuit
  Map<String, dynamic> getLearningFeedback(Grid grid) {
    final simulatedGrid = _simulationEngine.simulatePowerFlow(grid);

    return {
      'hasPowerSource':
          grid.getAllComponents().any((c) => c.type == ComponentType.battery),
      'hasLights':
          grid.getAllComponents().any((c) => c.type == ComponentType.bulb),
      'poweredLights': simulatedGrid
          .getAllComponents()
          .where((c) => c.type == ComponentType.bulb && c.isPowered)
          .length,
      'totalComponents': grid.getComponentCount(),
      'isValid': validateCircuit(grid, {}),
    };
  }
}
