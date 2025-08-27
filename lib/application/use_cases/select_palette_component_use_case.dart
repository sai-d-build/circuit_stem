import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'base_use_case.dart';

class SelectPaletteComponentUseCase extends UseCase<SelectPaletteComponentAction, GameEngineState> {
  const SelectPaletteComponentUseCase();

  @override
  GameEngineState executeInternal(GameEngineState currentState, SelectPaletteComponentAction action) {
    return currentState.copyWith(selectedComponentId: action.componentId);
  }
}
