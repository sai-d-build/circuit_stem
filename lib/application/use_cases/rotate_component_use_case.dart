
import '../core/result.dart';
import '../game_engine_state.dart';
import 'base_use_case.dart';
import 'component_action.dart';

class RotateComponentUseCase extends UseCase<RotateComponentAction, GameEngineState> {
  const RotateComponentUseCase();

  @override
  Result<GameEngineState> execute(GameEngineState state, RotateComponentAction action) {
    final component = state.grid.componentsById[action.componentId];
    if (component == null) {
      return const Failure('Component not found');
    }

    final updatedComponent = component.copyWith(rotation: action.rotation);
    final newGrid = state.grid.copyWithUpdatedComponent(updatedComponent);
    
    return Success(state.copyWith(grid: newGrid));
  }
}
