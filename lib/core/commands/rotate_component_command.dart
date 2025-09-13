import '../../application/states/game_state.dart';
import 'game_command.dart';

/// A command to rotate a component.
class RotateComponentCommand extends GameCommand {
  final String componentId;
  final int oldRotation;
  final int newRotation;

  RotateComponentCommand({
    required this.componentId,
    required this.oldRotation,
    required this.newRotation,
  });

  @override
  GameState execute(GameState state) {
    final component = state.grid.getComponentById(componentId);
    if (component == null) return state;

    final updatedComponent = component.copyWith(rotation: newRotation);
    final newGrid = state.grid.copyWithUpdatedComponent(updatedComponent);

    return state.copyWith(grid: newGrid);
  }

  @override
  GameState undo(GameState state) {
    final component = state.grid.getComponentById(componentId);
    if (component == null) return state;

    final updatedComponent = component.copyWith(rotation: oldRotation);
    final newGrid = state.grid.copyWithUpdatedComponent(updatedComponent);

    return state.copyWith(grid: newGrid);
  }
}
