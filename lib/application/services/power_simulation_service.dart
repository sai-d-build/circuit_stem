import '../../domain/entities/component.dart';
import '../../domain/entities/grid.dart';
// Import Terminal and Dir

class PowerSimulationService {
  const PowerSimulationService();

  /// Pure function: returns updated grid with power simulation results
  Grid simulatePowerFlow(Grid grid) {
    try {
      final components =
          grid.components.map((e) => e.copyWith(isPowered: false)).toList();
      final powerSources = components.where((c) => _isPowerSource(c)).toList();

      // Multi-pass simulation for complex circuits
      bool hasChanges = true;
      int passCount = 0;
      const maxPasses = 100; // Prevent infinite loops

      while (hasChanges && passCount < maxPasses) {
        hasChanges = false;

        for (final source in powerSources) {
          if (_propagatePower(source, grid, [], components)) {
            hasChanges = true;
          }
        }

        passCount++;
      }

      return grid.copyWith(components: components);
    } catch (e) {
      // Return original grid if simulation fails
      return grid;
    }
  }

  bool _isPowerSource(ComponentModel component) {
    return component.type == 'battery' ||
        component.type == 'generator' ||
        (component.type == 'switch' && component.isPowered);
  }

  bool _propagatePower(ComponentModel current, Grid grid, List<String> visited,
      List<ComponentModel> components) {
    if (visited.contains(current.id)) return false;
    visited.add(current.id);

    bool changed = false;
    final index = components.indexWhere((e) => e.id == current.id);
    if (index != -1 && !components[index].isPowered) {
      components[index] = current.copyWith(isPowered: true);
      changed = true;
    }

    // Handle different component behaviors
    if (!_canTransmitPower(current)) {
      return changed;
    }

    for (final terminal in current.terminals) {
      final connectedComponent =
          _getConnectedComponent(current, terminal, grid);
      if (connectedComponent != null &&
          _canReceivePower(connectedComponent, current, grid)) {
        if (_propagatePower(
            connectedComponent, grid, [...visited], components)) {
          changed = true;
        }
      }
    }

    return changed;
  }

  bool _canTransmitPower(ComponentModel component) {
    switch (component.type) {
      case 'battery':
      case 'generator':
        return true;
      case 'wire':
        return component.isPowered;
      case 'switch':
        return component.state['closed'] == true;
      case 'resistor':
        return component.isPowered &&
            (component.state['resistance'] ?? 0) < 1000;
      default:
        return component.isPowered;
    }
  }

  bool _canReceivePower(
      ComponentModel component, ComponentModel source, Grid grid) {
    switch (component.type) {
      case 'diode':
        return _checkDiodeDirection(component, source, grid);
      case 'capacitor':
        return !component.state['charged'] == true;
      default:
        return true;
    }
  }

  bool _checkDiodeDirection(
      ComponentModel diode, ComponentModel source, Grid grid) {
    // A diode allows power to flow from anode to cathode.
    // We need to determine which terminal of the diode is connected to the source
    // and if that terminal is the anode.

    // This is a simplified example. A real implementation would need to know
    // which terminal is the anode and which is the cathode based on the
    // component's definition.
    if (diode.terminals.isEmpty) return false;

    // Assuming the first terminal is the anode and the second is the cathode
    final anodeTerminal = diode.terminals[0];

    // Check if the source is connected to the anode
    final connectedToAnode =
        _getConnectedComponent(diode, anodeTerminal, grid) == source;

    return connectedToAnode;
  }

  ComponentModel? _getConnectedComponent(
      ComponentModel current, TerminalSpec terminal, Grid grid) {
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

    return grid.componentAt(nextR, nextC);
  }
}
