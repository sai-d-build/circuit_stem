import '../../application/states/game_state.dart';
import 'game_command.dart';

/// A command to move a component from one position to another.
class MoveComponentCommand extends GameCommand {
  final String componentId;
  final int oldRow;
  final int oldCol;
  final int newRow;
  final int newCol;

  MoveComponentCommand({
    required this.componentId,
    required this.oldRow,
    required this.oldCol,
    required this.newRow,
    required this.newCol,
  });

  @override
  GameState execute(GameState state) {
    final newGrid = state.grid.moveComponent(componentId, newRow, newCol);
    return state.copyWith(grid: newGrid);
  }

  @override
  GameState undo(GameState state) {
    final newGrid = state.grid.moveComponent(componentId, oldRow, oldCol);
    return state.copyWith(grid: newGrid);
  }
}
