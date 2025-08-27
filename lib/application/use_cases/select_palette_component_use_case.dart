import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'base_use_case.dart';

class SelectPaletteComponentUseCase
    extends UseCase<SelectPaletteComponentAction> {
  // Removed GameEngineState TResult
  const SelectPaletteComponentUseCase();

  @override
  Future<GameEngineState> executeInternal(
      GameEngineState currentState, SelectPaletteComponentAction action) async {
    return currentState.copyWith(selectedComponentId: action.componentId);
  }
}
