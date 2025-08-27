import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/application/services/component_factory.dart';
import 'base_use_case.dart'; // Import base_use_case.dart

class CreateComponentFromTemplateUseCase
    extends UseCase<CreateComponentFromTemplateAction> {
  final PowerSimulationService _simulation;
  final ComponentFactory _factory;

  CreateComponentFromTemplateUseCase(this._simulation, this._factory);

  @override
  Future<GameEngineState> executeInternal(GameEngineState currentState,
      CreateComponentFromTemplateAction action) async {
    final template =
        currentState.paletteManager.getTemplateById(action.templateId);

    if (template == null) {
      // Template not found, return original state
      return currentState;
    }

    // Create a new instance from the template with a new ID and position
    final newInstance =
        _factory.createInstanceFromTemplate(template, action.row, action.col);

    // Add the new instance to the grid
    var newGrid = currentState.grid.copyWith(
      components: [...currentState.grid.components, newInstance],
    );

    // Simulate power flow on the new grid
    newGrid = _simulation.simulatePowerFlow(newGrid);

    // Return the new state, keeping the palette unchanged
    return currentState.copyWith(grid: newGrid);
  }
}
