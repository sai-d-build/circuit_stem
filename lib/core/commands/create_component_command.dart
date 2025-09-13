import 'package:sparkcircuit/domain/entities/entities.dart';
import '../../application/states/game_state.dart';
import 'game_command.dart';

/// A command to create and place a new component on the grid.
class CreateComponentCommand extends GameCommand {
  final ComponentModel component;

  CreateComponentCommand(this.component);

  @override
  GameState execute(GameState state) {
    final newGrid = state.grid.placeComponent(component);
    return state.copyWith(grid: newGrid);
  }

  @override
  GameState undo(GameState state) {
    final newGrid = state.grid.removeComponent(component.id);
    return state.copyWith(grid: newGrid);
  }
}
