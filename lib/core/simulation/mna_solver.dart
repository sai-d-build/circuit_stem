import 'dart:math' as math;
import 'circuit_netlist.dart';
import '../validation/circuit_validator.dart';

// Missing classes for simulation results
class SimulationResult {
  final Map<String, double> nodeVoltages;
  final Map<String, double> branchCurrents;
  final Map<String, ComponentState> componentStates;
  final List<SimulationDiagnostic> diagnostics;
  final DateTime timestamp;
  final bool isValid;

  SimulationResult({
    required this.nodeVoltages,
    required this.branchCurrents,
    required this.componentStates,
    required this.diagnostics,
    required this.timestamp,
    required this.isValid,
  });

  static SimulationResult error(List<SimulationDiagnostic> diagnostics) {
    return SimulationResult(
      nodeVoltages: {},
      branchCurrents: {},
      componentStates: {},
      diagnostics: diagnostics,
      timestamp: DateTime.now(),
      isValid: false,
    );
  }
}

class SimulationDiagnostic {
  final String code;
  final String message;
  final DiagnosticSeverity severity;
  final Map<String, dynamic> details;

  SimulationDiagnostic({
    required this.code,
    required this.message,
    required this.severity,
    required this.details,
  });
}

enum DiagnosticSeverity {
  info,
  warning,
  error,
}

class ComponentState {
  final String componentId;
  final double voltage;
  final double current;
  final bool isPowered;

  ComponentState({
    required this.componentId,
    required this.voltage,
    required this.current,
    required this.isPowered,
  });
}

/// Basic Modified Nodal Analysis (MNA) Solver
class BasicMNASolver {
  final double tolerance;
  final int maxIterations;

  BasicMNASolver({
    this.tolerance = 1e-9,
    this.maxIterations = 1000,
  });

  /// Solve DC steady-state circuit using MNA
  Future<SimulationResult> solveDC(CircuitNetlist netlist) async {
    try {
      // Build system matrices
      final matrices = _buildSystemMatrices(netlist);

      // Solve system Ax = b
      final solution = _solveSystem(matrices.a, matrices.b);

      // Extract results
      final result = _extractResults(netlist, solution);

      return result;
    } catch (e) {
      return SimulationResult.error([
        SimulationDiagnostic(
          code: 'MNA_SOLVE_FAILED',
          message: 'Failed to solve circuit: ${e.toString()}',
          severity: DiagnosticSeverity.error,
          details: {'error': e.toString()},
        ),
      ]);
    }
  }

  /// Build MNA system matrices
  SystemMatrices _buildSystemMatrices(CircuitNetlist netlist) {
    final nodeCount = netlist.nodes.length;
    final voltageSourceCount = netlist.components
        .where((comp) => comp.type == ComponentType.voltageSource)
        .length;

    final matrixSize = nodeCount + voltageSourceCount;

    // Initialize matrices using Lists
    final a = List.generate(matrixSize, (_) => List<double>.filled(matrixSize, 0.0));
    final b = List<double>.filled(matrixSize, 0.0);

    // Build conductance matrix (G part)
    _buildConductanceMatrix(netlist, a);

    // Build voltage source matrix (B and C parts)
    _buildVoltageSourceMatrix(netlist, a);

    // Build current source vector
    _buildCurrentSourceVector(netlist, b);

    return SystemMatrices(a, b);
  }

  void _buildConductanceMatrix(CircuitNetlist netlist, List<List<double>> a) {
    // For each component, add conductance to appropriate matrix positions
    for (final component in netlist.components) {
      switch (component.type) {
        case ComponentType.resistor:
          _addResistorToMatrix(component, a);
          break;
        case ComponentType.capacitor:
          // For DC analysis, capacitors are open circuits
          break;
        case ComponentType.inductor:
          // For DC analysis, inductors are short circuits
          _addShortCircuit(component, a);
          break;
        case ComponentType.diode:
          // Simplified diode model for DC
          _addDiodeToMatrix(component, a);
          break;
        default:
          // Other components don't contribute to conductance matrix for DC
          break;
      }
    }
  }

  void _addResistorToMatrix(SimComponent resistor, List<List<double>> a) {
    final resistance = resistor.parameters['resistance'] ?? 1000.0;
    final conductance = 1.0 / resistance;

    // Get node indices (simplified - would need proper node mapping)
    final node1 = _getNodeIndex(resistor.terminals[0]);
    final node2 = _getNodeIndex(resistor.terminals[1]);

    if (node1 >= 0 && node2 >= 0) {
      // Add conductance to diagonal elements
      a[node1][node1] += conductance;
      a[node2][node2] += conductance;

      // Add negative conductance to off-diagonal
      a[node1][node2] -= conductance;
      a[node2][node1] -= conductance;
    }
  }

  void _addShortCircuit(SimComponent component, List<List<double>> a) {
    // For short circuit (ideal inductor in DC), connect nodes directly
    final node1 = _getNodeIndex(component.terminals[0]);
    final node2 = _getNodeIndex(component.terminals[1]);

    if (node1 >= 0 && node2 >= 0) {
      // This is a simplified representation
      // In practice, this would require more sophisticated handling
      a[node1][node2] = -1.0;
      a[node2][node1] = -1.0;
    }
  }

  void _addDiodeToMatrix(SimComponent diode, List<List<double>> a) {
    // Simplified diode model using piecewise linear approximation
    final node1 = _getNodeIndex(diode.terminals[0]);
    final node2 = _getNodeIndex(diode.terminals[1]);

    if (node1 >= 0 && node2 >= 0) {
      // Simplified forward conductance
      final forwardConductance = 0.01; // Simplified value
      a[node1][node1] += forwardConductance;
      a[node2][node2] += forwardConductance;
      a[node1][node2] -= forwardConductance;
      a[node2][node1] -= forwardConductance;
    }
  }

  void _buildVoltageSourceMatrix(CircuitNetlist netlist, List<List<double>> a) {
    // Add B and C matrices for voltage sources
    int voltageSourceIndex = netlist.nodes.length; // Start after node variables

    for (final component in netlist.components) {
      if (component.type == ComponentType.voltageSource) {
        final node1 = _getNodeIndex(component.terminals[0]);
        final node2 = _getNodeIndex(component.terminals[1]);

        if (node1 >= 0 && node2 >= 0) {
          // B matrix: connect voltage source to nodes
          a[node1][voltageSourceIndex] = 1.0;
          a[node2][voltageSourceIndex] = -1.0;

          // C matrix: connect nodes to voltage source
          a[voltageSourceIndex][node1] = 1.0;
          a[voltageSourceIndex][node2] = -1.0;
        }

        voltageSourceIndex++;
      }
    }
  }

  void _buildCurrentSourceVector(CircuitNetlist netlist, List<double> b) {
    // Add current sources to b vector
    for (final component in netlist.components) {
      if (component.type == ComponentType.currentSource) {
        final current = component.parameters['current'] ?? 0.0;
        final node1 = _getNodeIndex(component.terminals[0]);
        final node2 = _getNodeIndex(component.terminals[1]);

        if (node1 >= 0) b[node1] += current;
        if (node2 >= 0) b[node2] -= current;
      }
    }

    // Add voltage sources to b vector
    int voltageSourceIndex = netlist.nodes.length;
    for (final component in netlist.components) {
      if (component.type == ComponentType.voltageSource) {
        final voltage = component.parameters['voltage'] ?? 0.0;
        b[voltageSourceIndex] = voltage;
        voltageSourceIndex++;
      }
    }
  }

  /// Solve system Ax = b using Gaussian elimination
  List<double> _solveSystem(List<List<double>> a, List<double> b) {
    // Simple Gaussian elimination (for educational purposes)
    // In production, would use more robust numerical methods
    final n = a.length;
    final augmented = List.generate(n, (_) => List<double>.filled(n + 1, 0.0));

    // Create augmented matrix [A|b]
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        augmented[i][j] = a[i][j];
      }
      augmented[i][n] = b[i];
    }

    // Forward elimination
    for (int p = 0; p < n; p++) {
      // Find pivot row
      int max = p;
      for (int i = p + 1; i < n; i++) {
        if (augmented[i][p].abs() > augmented[max][p].abs()) {
          max = i;
        }
      }

      // Swap rows
      final temp = augmented[p];
      augmented[p] = augmented[max];
      augmented[max] = temp;

      // Check for singular matrix
      if (augmented[p][p].abs() < tolerance) {
        throw Exception('Singular matrix - circuit may be improperly connected');
      }

      // Eliminate column
      for (int i = p + 1; i < n; i++) {
        final alpha = augmented[i][p] / augmented[p][p];
        for (int j = p; j < n + 1; j++) {
          augmented[i][j] -= alpha * augmented[p][j];
        }
      }
    }

    // Back substitution
    final x = List<double>.filled(n, 0.0);
    for (int i = n - 1; i >= 0; i--) {
      x[i] = augmented[i][n];
      for (int j = i + 1; j < n; j++) {
        x[i] -= augmented[i][j] * x[j];
      }
      x[i] /= augmented[i][i];
    }

    return x;
  }

  SimulationResult _extractResults(CircuitNetlist netlist, List<double> solution) {
    final nodeCount = netlist.nodes.length;

    // Extract node voltages
    final nodeVoltages = <String, double>{};
    for (int i = 0; i < nodeCount; i++) {
      final nodeId = netlist.nodes.keys.elementAt(i);
      nodeVoltages[nodeId] = solution[i];
    }

    // Extract branch currents (simplified)
    final branchCurrents = <String, double>{};
    for (final component in netlist.components) {
      if (component.type == ComponentType.resistor) {
        final node1 = component.terminals[0];
        final node2 = component.terminals[1];
        final v1 = nodeVoltages[node1] ?? 0.0;
        final v2 = nodeVoltages[node2] ?? 0.0;
        final resistance = component.parameters['resistance'] ?? 1000.0;
        final current = (v1 - v2) / resistance;

        branchCurrents[component.id] = current;
      }
    }

    // Component states (simplified)
    final componentStates = <String, ComponentState>{};
    for (final component in netlist.components) {
      final isPowered = _isComponentPowered(component, nodeVoltages);
      componentStates[component.id] = ComponentState(
        componentId: component.id,
        voltage: _getComponentVoltage(component, nodeVoltages),
        current: branchCurrents[component.id] ?? 0.0,
        isPowered: isPowered,
      );
    }

    return SimulationResult(
      nodeVoltages: nodeVoltages,
      branchCurrents: branchCurrents,
      componentStates: componentStates,
      diagnostics: [],
      timestamp: DateTime.now(),
      isValid: true,
    );
  }

  int _getNodeIndex(String terminal) {
    // Simplified node index mapping
    // In practice, this would use a proper node mapping from the netlist
    return int.tryParse(terminal) ?? -1;
  }

  bool _isComponentPowered(SimComponent component, Map<String, double> nodeVoltages) {
    // Simplified power check
    for (final terminal in component.terminals) {
      final voltage = nodeVoltages[terminal] ?? 0.0;
      if (voltage.abs() > 0.1) return true; // Threshold for "powered"
    }
    return false;
  }

  double _getComponentVoltage(SimComponent component, Map<String, double> nodeVoltages) {
    // Simplified voltage calculation
    if (component.terminals.length >= 2) {
      final v1 = nodeVoltages[component.terminals[0]] ?? 0.0;
      final v2 = nodeVoltages[component.terminals[1]] ?? 0.0;
      return (v1 - v2).abs();
    }
    return 0.0;
  }
}

/// System matrices for MNA
class SystemMatrices {
  final List<List<double>> a;
  final List<double> b;

  SystemMatrices(this.a, this.b);
}