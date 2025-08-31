
import '../../application/enhanced_game_state.dart';
import 'game_command.dart';

/// A command to add a connection between two components.
class AddConnectionCommand extends GameCommand {
  final String fromComponentId;
  final String toComponentId;

  AddConnectionCommand({
    required this.fromComponentId,
    required this.toComponentId,
  });

  @override
  GameState execute(GameState state) {
    final newGrid = state.grid.addConnection(fromComponentId, toComponentId);
    return state.copyWith(grid: newGrid);
  }

  @override
  GameState undo(GameState state) {
    final newGrid = state.grid.removeConnection(fromComponentId, toComponentId);
    return state.copyWith(grid: newGrid);
  }
}
