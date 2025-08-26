import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';

class SelectPaletteComponentUseCase {
  const SelectPaletteComponentUseCase();

  GameEngineState execute(GameEngineState currentState, SelectPaletteComponentAction action) {
    return currentState.copyWith(selectedComponentId: action.componentId);
  }
}
