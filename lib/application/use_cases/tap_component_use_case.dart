import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/application/services/goal_checking_service.dart';
import 'package:circuit_stem/domain/behaviors/behavior.dart';
import 'package:circuit_stem/application/game_context.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'base_use_case.dart'; // Import base_use_case.dart

class TapComponentUseCase extends UseCase<TapComponentAction> {
  final PowerSimulationService _simulation;
  final GoalCheckingService _goalChecker;

  const TapComponentUseCase(this._simulation, this._goalChecker);

  @override
  Future<GameEngineState> executeInternal(
      GameEngineState currentState, TapComponentAction action) async {
    final component = currentState.grid.componentsById[action.componentId];

    if (component == null) {
      return currentState; // Component not found
    }

    ComponentModel? updatedComponent;
    final gameContext = GameContext.from(currentState);

    // Iterate through behaviors associated with the component
    for (final behavior in component.behaviors.whereType<ComponentBehavior>()) {
      final result = behavior.handle(component, 'tap', gameContext);
      if (result != null) {
        updatedComponent = result;
        break; // Assuming only one behavior handles a 'tap' action
      }
    }

    if (updatedComponent != null) {
      var newGrid =
          currentState.grid.copyWithUpdatedComponent(updatedComponent);
      newGrid = _simulation.simulatePowerFlow(newGrid);
      final isWin = _goalChecker.isLevelComplete(
          newGrid, currentState.currentLevel!); // Check win condition
      return currentState.copyWith(grid: newGrid, isWin: isWin);
    }

    return currentState; // No change
  }
}
