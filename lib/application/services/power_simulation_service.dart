import 'package:sparkcircuit/domain/entities/entities.dart';

import '../../common/logger.dart';

/// Basic implementation of power simulation service
class PowerSimulationService {
    Grid simulatePowerFlow(Grid grid) {
    Logger.log('PowerSimulationService: Simulating power flow on ${grid.getComponentCount()} components');

    // Create a copy of the grid to modify
    final newComponents = Map<String, ComponentModel>.from(grid.components);

    // Find power sources (batteries)
    final batteries = grid.getAllComponents()
        .where((component) => component.type == ComponentType.battery)
        .toList();

    // Simple power propagation algorithm
    for (final battery in batteries) {
      _propagatePower(grid, battery, newComponents);
    }

    // Update grid with new component states
    final updatedGrid = grid.copyWith(components: newComponents);
    Logger.log('PowerSimulationService: Power simulation complete');

    return updatedGrid;
  }

  void _propagatePower(Grid grid, ComponentModel source, Map<String, ComponentModel> components) {
    // Simple power propagation - mark source as powered
    if (components.containsKey(source.id)) {
      components[source.id] = source.copyWith(state: ComponentState.powered);
    }

    // Find connected components and propagate power
    final connections = grid.getConnections(source.id);
    for (final connectedId in connections) {
      final connectedComponent = components[connectedId];
      if (connectedComponent != null && connectedComponent.state != ComponentState.powered) {
        // Propagate to connected component
        components[connectedId] = connectedComponent.copyWith(state: ComponentState.powered);
        // Recursively propagate further
        _propagatePower(grid, connectedComponent, components);
      }
    }
  }
}