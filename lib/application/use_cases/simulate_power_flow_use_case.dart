import '../game_engine_state.dart';
import '../services/power_simulation_service.dart';
import 'base_use_case.dart';
import 'component_action.dart';
import '../../domain/entities/grid.dart';

class SimulatePowerFlowUseCase extends UseCase<SimulatePowerFlowAction, Grid> {
  final PowerSimulationService _simulationService;
  
  const SimulatePowerFlowUseCase(this._simulationService);
  
  @override
  Grid executeInternal(GameEngineState state, SimulatePowerFlowAction action) {
    return _simulationService.simulatePowerFlow(state.grid);
  }
}