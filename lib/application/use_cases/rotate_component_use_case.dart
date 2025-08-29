import '../game_engine_state.dart';
import 'base_use_case.dart';
import 'component_action.dart';

class RotateComponentUseCase extends UseCase<RotateComponentAction> {
  const RotateComponentUseCase();

  @override
  Future<GameEngineState> executeInternal(
      GameEngineState state, RotateComponentAction action) async {
    final component = state.grid.componentsById[action.componentId];
    if (component == null) {
      throw Exception('Component not found');
    }

    final updatedComponent = component.copyWith(rotation: action.rotation);
    final newGrid = state.grid.copyWithUpdatedComponent(updatedComponent);

    return state.copyWith(grid: newGrid);
  }
}
