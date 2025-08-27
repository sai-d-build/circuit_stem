import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/application/services/goal_checking_service.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'base_use_case.dart';

class UpdateComponentUseCase extends UseCase<UpdateComponentAction, GameEngineState> {
  final PowerSimulationService _simulation;
  final GoalCheckingService _goalChecker;

  const UpdateComponentUseCase(this._simulation, this._goalChecker);

  @override
  GameEngineState executeInternal(GameEngineState currentState, UpdateComponentAction action) {
    final component = currentState.grid.componentsById[action.componentId];

    if (component == null) {
      throw Exception('Component not found');
    }

    final updatedComponent = component.copyWith(state: action.newState);

    var newGrid = currentState.grid.copyWithUpdatedComponent(updatedComponent);
    newGrid = _simulation.simulatePowerFlow(newGrid);
    final isWin = _goalChecker.isLevelComplete(newGrid, currentState.currentLevel!); // Check win condition

    return currentState.copyWith(grid: newGrid, isWin: isWin);
  }
}
