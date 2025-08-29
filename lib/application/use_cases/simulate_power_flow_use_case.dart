import '../game_engine_state.dart';
import '../services/power_simulation_service.dart';
import 'base_use_case.dart';
import 'simulate_power_flow_action.dart';

class SimulatePowerFlowUseCase extends UseCase<SimulatePowerFlowAction> {
  // Removed Grid TResult
  final PowerSimulationService _simulationService;

  const SimulatePowerFlowUseCase(this._simulationService);

  @override
  Future<GameEngineState> executeInternal(
      GameEngineState state, SimulatePowerFlowAction action) async {
    final newGrid = _simulationService.simulatePowerFlow(state.grid);
    return state.copyWith(grid: newGrid); // Return state with updated grid
  }
}
