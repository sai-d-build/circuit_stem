import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/models/grid.dart';
import 'package:circuit_stem/models/port.dart';
import 'game_engine_notifier.dart';

class SimulationManager {
  final GameEngineNotifierV2 _notifier;

  SimulationManager(this._notifier);

  void simulatePowerFlow() {
    final grid = _notifier.state.grid;
    final components = grid.components.map((e) => e.copyWith(isPowered: false)).toList(); // Reset power state for all components

    // Identify power sources and start propagation
    for (var i = 0; i < components.length; i++) {
      var comp = components[i];
      if (comp.type == 'battery') { // Assuming battery is the power source
        _propagatePower(comp, grid, [], components);
      }
    }
    _notifier.updateGrid(Grid(rows: grid.rows, cols: grid.cols, components: components)); // Update the grid in the notifier
  }

  void _propagatePower(ComponentModel current, Grid grid, List<String> visited, List<ComponentModel> components) {
    if (visited.contains(current.id)) return;
    visited.add(current.id);

    current = current.copyWith(isPowered: true); // Update current component's power state
    final index = components.indexWhere((element) => element.id == current.id);
    if (index != -1) {
      components[index] = current; // Update the component in the list
    }

    for (final port in current.terminals) { // Changed ports to terminals
      final connectedComponent = grid.getComponentAt(port.offset.r, port.offset.c); // Changed port.connectedTo to port.offset
      if (connectedComponent != null) {
        _propagatePower(connectedComponent, grid, visited, components);
      }
    }
  }
}