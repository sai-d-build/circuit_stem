import 'package:sparkcircuit/core/simulation/circuit_netlist.dart';
import 'package:sparkcircuit/core/simulation/simulation_result.dart';

abstract class SimulationEngine {
  Future<SimulationResult> solveDC(CircuitNetlist netlist);
}
