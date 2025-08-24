import '../../domain/entities/component.dart';
import '../../domain/entities/grid.dart';

class SimulationManager {
  SimulationManager();

  /// Pure function: returns updated grid
  Grid simulatePowerFlow(Grid grid) {
    final components = grid.components.map((e) => e.copyWith(isPowered: false)).toList();

    for (var i = 0; i < components.length; i++) {
      var comp = components[i];
      if (comp.type == 'battery') {
        _propagatePower(comp, grid, [], components);
      }
    }
    return grid.copyWith(components: components);
  }

  void _propagatePower(
      ComponentModel current, Grid grid, List<String> visited, List<ComponentModel> components) {
    if (visited.contains(current.id)) return;
    visited.add(current.id);

    final index = components.indexWhere((e) => e.id == current.id);
    if (index != -1) {
      components[index] = current.copyWith(isPowered: true);
    }

    for (final terminal in current.terminals) {
      final terminalR = current.r + terminal.offset.r;
      final terminalC = current.c + terminal.offset.c;

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

      final connected = grid.componentAt(nextR, nextC);
      if (connected != null) {
        _propagatePower(connected, grid, visited, components);
      }
    }
  }
}
